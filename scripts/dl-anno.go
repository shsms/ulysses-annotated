// Command dl-anno downloads the Joyce Project annotations and writes them in
// the on-disk layout that add-anno.mime consumes.
//
// The Joyce Project replaced its old PHP site (which dl-anno used to crawl via
// ideacrawler) with a JSON API.  See issue #16.  Each chapter is now served at
// /api/chapters/<id> with an html_source field whose annotation references are
// inline anchors carrying the note id in href and the colour in data-color:
//
//	<a href="<note-id>" data-color="RRGGBB" data-tag="..." data-type="annotation">text</a>
//
// and each note at /api/notes/<id> with an html_source split into "In brief"
// and "At more length" sections.  We reshape these into the files the mime
// script already understands:
//
//	<outdir>/index.php-<slug>.htm   one per chapter, anchors rewritten to
//	                                href="notes/<id>.htm" + data-color
//	<outdir>/notes/<id>.htm         <title>, <div id="note"> (brief) and an
//	                                optional <div id="expandednote"> (at length)
//
// Fetches are sequential with a delay between network calls so we stay gentle
// on the Joyce Project's server, and raw API responses are cached so reruns
// don't refetch.
package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"time"

	"golang.org/x/net/html"
	"golang.org/x/net/html/atom"
)

const apiBase = "https://joyceproject.com/api"
const userAgent = "ulysses-annotated weekly build (+https://github.com/shsms/ulysses-annotated)"

// chapter number (1-based) -> output slug, matching add-anno.mime's chapters[].
var slugs = []string{
	"telem", "nestor", "proteus", "calypso", "lotus", "hades", "aeolus", "lestry",
	"scylla", "wrocks", "sirens", "cyclops", "nausicaa", "oxen", "circe", "eumaeus",
	"ithaca", "penelope",
}

var (
	annoRe   = regexp.MustCompile(`<a\s+href="([^"]+)"\s+data-color="([^"]*)"\s+data-tag="[^"]*"\s+data-type="annotation"\s*>`)
	markerRe = regexp.MustCompile(`(<a href="notes/[^"]+\.htm" data-color="[^"]*">)\[(\d+)\]</a>`)
)

type chapterMeta struct {
	ID     string `json:"id"`
	Number int    `json:"number"`
	Title  string `json:"title"`
}

type document struct {
	ID         string `json:"id"`
	Title      string `json:"title"`
	HTMLSource string `json:"html_source"`
}

type downloader struct {
	client   *http.Client
	cacheDir string
	delay    time.Duration
}

func main() {
	delay := flag.Duration("delay", 500*time.Millisecond, "pause between network requests")
	cacheDir := flag.String("cache", "", "directory for caching raw API responses (default <outdir>/.api-cache)")
	flag.Parse()
	if flag.NArg() != 1 {
		fmt.Fprintln(os.Stderr, "usage: dl-anno [-delay d] [-cache dir] <outdir>")
		os.Exit(2)
	}
	outDir := flag.Arg(0)
	if *cacheDir == "" {
		*cacheDir = filepath.Join(outDir, ".api-cache")
	}

	d := &downloader{
		client:   &http.Client{Timeout: 60 * time.Second},
		cacheDir: *cacheDir,
		delay:    *delay,
	}
	if err := d.run(outDir); err != nil {
		fmt.Fprintln(os.Stderr, "error:", err)
		os.Exit(1)
	}
}

func (d *downloader) run(outDir string) error {
	if err := os.MkdirAll(filepath.Join(outDir, "notes"), 0o755); err != nil {
		return err
	}

	var chapters []chapterMeta
	if err := d.getJSON("chapters/", "chapters-index", &chapters); err != nil {
		return fmt.Errorf("chapter index: %w", err)
	}
	if len(chapters) != len(slugs) {
		fmt.Fprintf(os.Stderr, "warning: API returned %d chapters, expected %d\n", len(chapters), len(slugs))
	}

	// Write every chapter file first, collecting the set of referenced notes.
	noteIDs := map[string]bool{}
	for _, meta := range chapters {
		var ch document
		if err := d.getJSON("chapters/"+meta.ID, "chapter-"+meta.ID, &ch); err != nil {
			return fmt.Errorf("chapter %d (%s): %w", meta.Number, meta.Title, err)
		}
		doc, refs := buildChapter(ch.HTMLSource, ch.Title)
		for _, id := range refs {
			noteIDs[id] = true
		}
		name := fmt.Sprintf("index.php-%s.htm", slugFor(meta.Number))
		if err := os.WriteFile(filepath.Join(outDir, name), []byte(doc), 0o644); err != nil {
			return err
		}
		fmt.Printf("chapter %2d %-22s %d notes\n", meta.Number, meta.Title, len(refs))
	}

	// Then fetch and reshape each distinct note.
	total := len(noteIDs)
	fmt.Printf("fetching %d distinct notes...\n", total)
	var missing, failed, done int
	for id := range noteIDs {
		done++
		if done%100 == 0 || done == total {
			fmt.Printf("notes: %d/%d (%d%%)\n", done, total, done*100/total)
		}
		var n document
		ok, err := d.getJSONOptional("notes/"+id, "note-"+id, &n)
		if err != nil {
			// A note that persistently errors (e.g. a 500 from a malformed note
			// on the server) shouldn't sink the whole build; warn and carry on
			// without it, just as with a 404.
			fmt.Fprintf(os.Stderr, "warning: skipping note %s: %v\n", id, err)
			failed++
			continue
		}
		if !ok {
			missing++
			continue // 404: leave the file out; the mime script skips it gracefully
		}
		body := buildNote(n.Title, n.HTMLSource)
		if err := os.WriteFile(filepath.Join(outDir, "notes", id+".htm"), []byte(body), 0o644); err != nil {
			return err
		}
	}
	fmt.Printf("done: %d chapters, %d notes (%d not found, %d failed)\n",
		len(chapters), total-missing-failed, missing, failed)
	return nil
}

func slugFor(number int) string {
	if number >= 1 && number <= len(slugs) {
		return slugs[number-1]
	}
	return strconv.Itoa(number)
}

// buildChapter rewrites the inline annotation anchors to point at local note
// files (keeping their colour) and wraps the prose with the newchapter/footer
// markers add-anno.mime narrows between.  It returns the referenced note ids.
func buildChapter(src, title string) (string, []string) {
	var ids []string
	for _, m := range annoRe.FindAllStringSubmatch(src, -1) {
		ids = append(ids, m[1])
	}
	prose := annoRe.ReplaceAllString(src, `<a href="notes/$1.htm" data-color="$2">`)
	// The chapter-number marker is an annotation whose text is "[N]"; render it
	// the way the mime script's fix_mismatches expects to rewrite into "[ N ]".
	prose = markerRe.ReplaceAllString(prose, `${1}<font size="+2">[$2]</font></a>`)

	var b strings.Builder
	b.WriteString(`<html><head><meta charset="utf-8"><title>`)
	b.WriteString(escapeText(title))
	b.WriteString(`</title></head><body>`)
	b.WriteString(`<center><p class="newchapter"></p></center>`)
	b.WriteString(prose)
	b.WriteString(`<div id="footer"></div></body></html>`)
	return b.String(), ids
}

// buildNote reshapes a note's html_source into the <div id="note"> /
// <div id="expandednote"> structure that insert_footnote parses.
func buildNote(title, src string) string {
	brief, extended := splitNote(src)

	var b strings.Builder
	b.WriteString("<html><head><title>")
	b.WriteString(escapeText(title))
	// Keep the structural divs on their own lines: insert_footnote locates the
	// extended note with the greedy regex <div id="expandednote".*>, which would
	// overshoot a single-line note (e.g. one containing a <blockquote>).
	b.WriteString("</title></head><body>\n")
	b.WriteString("<div id=\"note\">\n")
	b.WriteString(brief)
	b.WriteString("\n</div>\n")
	if strings.TrimSpace(extended) != "" {
		b.WriteString("<div id=\"expandednote\" style=\"display: none;\">\n")
		b.WriteString(extended)
		b.WriteString("\n</div>\n<div id=\"button\"></div>\n")
	}
	b.WriteString("</body></html>")
	return b.String()
}

// splitNote separates a note body into its "In brief" and "At more length"
// sections by the labelled paragraphs (matched on text, since newer notes mark
// them as plain emphasis rather than with the subheader class).  The trailing
// author/year signature is kept with the last section as the note's attribution.
func splitNote(src string) (brief, extended string) {
	body := &html.Node{Type: html.ElementNode, Data: "body", DataAtom: atom.Body}
	nodes, err := html.ParseFragment(strings.NewReader(src), body)
	if err != nil || len(nodes) == 0 {
		return src, ""
	}

	var blocks []*html.Node
	for _, n := range nodes {
		if n.Type == html.ElementNode {
			blocks = append(blocks, n)
		}
	}
	if len(blocks) == 0 {
		return src, ""
	}

	inBrief, atMore := -1, -1
	for i, n := range blocks {
		switch label(n) {
		case "in brief":
			if inBrief < 0 {
				inBrief = i
			}
		case "at more length":
			if atMore < 0 {
				atMore = i
			}
		}
	}
	startBrief := 0
	if inBrief >= 0 {
		startBrief = inBrief + 1
	}
	endBrief := len(blocks)
	if atMore >= 0 {
		endBrief = atMore
	}
	brief = render(blocks, startBrief, endBrief)
	if strings.TrimSpace(stripTags(brief)) == "" { // fallback: keep whole body
		brief = render(blocks, 0, len(blocks))
	}

	if atMore >= 0 {
		// The trailing author/year signature, if present, falls at the end of
		// this last section and stays in as the note's closing attribution.
		extended = render(blocks, atMore+1, len(blocks))
	}
	return brief, extended
}

// label returns a block's normalised section-label text ("in brief" /
// "at more length"), or "" if it is not a short label paragraph.
func label(n *html.Node) string {
	t := strings.ToLower(strings.TrimRight(nodeText(n), " ."))
	if t == "in brief" || t == "at more length" {
		return t
	}
	return ""
}

func nodeText(n *html.Node) string {
	var b strings.Builder
	var walk func(*html.Node)
	walk = func(n *html.Node) {
		if n.Type == html.TextNode {
			b.WriteString(n.Data)
		}
		for c := n.FirstChild; c != nil; c = c.NextSibling {
			walk(c)
		}
	}
	walk(n)
	return strings.Join(strings.Fields(b.String()), " ")
}

func render(blocks []*html.Node, lo, hi int) string {
	var b bytes.Buffer
	for i := lo; i < hi && i < len(blocks); i++ {
		if b.Len() > 0 {
			b.WriteByte('\n') // keep blocks on separate lines (see buildNote)
		}
		html.Render(&b, blocks[i])
	}
	return b.String()
}

var tagRe = regexp.MustCompile(`<[^>]+>`)

func stripTags(s string) string { return tagRe.ReplaceAllString(s, "") }

// escapeText escapes a string for use as HTML element text (titles).
func escapeText(s string) string {
	s = strings.ReplaceAll(s, "&", "&amp;")
	s = strings.ReplaceAll(s, "<", "&lt;")
	s = strings.ReplaceAll(s, ">", "&gt;")
	return s
}

// getJSON fetches an API path (cached) and unmarshals it; a 404 is an error.
func (d *downloader) getJSON(path, cacheKey string, v any) error {
	ok, err := d.getJSONOptional(path, cacheKey, v)
	if err != nil {
		return err
	}
	if !ok {
		return fmt.Errorf("%s: not found", path)
	}
	return nil
}

// getJSONOptional is like getJSON but reports a 404 as ok=false rather than an
// error, so callers can skip missing notes.
func (d *downloader) getJSONOptional(path, cacheKey string, v any) (bool, error) {
	data, ok, err := d.get(path, cacheKey)
	if err != nil || !ok {
		return false, err
	}
	return true, json.Unmarshal(data, v)
}

func (d *downloader) get(path, cacheKey string) ([]byte, bool, error) {
	cachePath := filepath.Join(d.cacheDir, cacheKey+".json")
	if data, err := os.ReadFile(cachePath); err == nil {
		return data, true, nil
	}

	data, ok, err := d.fetch(apiBase + "/" + path)
	if err != nil || !ok {
		return nil, ok, err
	}
	if err := os.MkdirAll(d.cacheDir, 0o755); err != nil {
		return nil, false, err
	}
	if err := os.WriteFile(cachePath, data, 0o644); err != nil {
		return nil, false, err
	}
	return data, true, nil
}

// fetch performs a single GET with retries/backoff on rate-limit and server
// errors, returning ok=false on 404.
func (d *downloader) fetch(url string) ([]byte, bool, error) {
	const maxAttempts = 4
	for attempt := 1; ; attempt++ {
		req, err := http.NewRequest(http.MethodGet, url, nil)
		if err != nil {
			return nil, false, err
		}
		req.Header.Set("User-Agent", userAgent)
		resp, err := d.client.Do(req)
		if err != nil {
			if attempt < maxAttempts {
				time.Sleep(backoff(attempt))
				continue
			}
			return nil, false, err
		}
		body, _ := io.ReadAll(resp.Body)
		resp.Body.Close()

		switch {
		case resp.StatusCode == http.StatusOK:
			time.Sleep(d.delay) // be gentle between successful network calls
			return body, true, nil
		case resp.StatusCode == http.StatusNotFound:
			return nil, false, nil
		case (resp.StatusCode == http.StatusTooManyRequests || resp.StatusCode >= 500) && attempt < maxAttempts:
			wait := backoff(attempt)
			if ra := resp.Header.Get("Retry-After"); ra != "" {
				if secs, err := strconv.Atoi(strings.TrimSpace(ra)); err == nil {
					wait = time.Duration(secs) * time.Second
				}
			}
			time.Sleep(wait)
		default:
			return nil, false, fmt.Errorf("GET %s: %s", url, resp.Status)
		}
	}
}

func backoff(attempt int) time.Duration {
	return time.Duration(1<<uint(attempt-1)) * time.Second
}
