;;; add-anno notes machinery — prepare-notes-section, cleanup-note,
;;; add_to_notes_map, insert-footnote, add-notes, add-notes-index.
;;;
;;; Buffer model: the epub holds THREE markers — the base-text insert point, the
;;; Annotations append point, and the Index append point — each advanced with
;;; set-marker after its inserts. The per-chapter base-text slice is bounded by an
;;; explicit search bound (a chap-end marker), not a narrowing. The per-chapter
;;; source `b' and each note file are separate buffers entered via
;;; with-current-buffer and read FRESH (generate-new-buffer + insert-file-contents),
;;; because find-file reuses by name and these get modified.

;; ---- small structures -------------------------------------------------------
;; notes-index box: a 1-element list whose car is an alist  letter -> ((title . url)...)
(defun stat-set (box key val) (setcar box (cons (cons key val) (car box))))
(defun stat-get (box key) (cdr (assoc key (car box))))
(defun sort-titles (pairs) (sort pairs (lambda (a b) (string< (car a) (car b)))))

(defun add_to_notes_map (box title url)
  (let* ((letter (substring title 0 1))
         (alist (car box))
         (lp (assoc letter alist)))
    (if lp
        (let ((tp (assoc title (cdr lp))))
          (if tp (setcdr tp url)
            (setcdr lp (cons (cons title url) (cdr lp)))))
      (setcar box (cons (cons letter (list (cons title url))) alist)))))

;; ---- Annotations section ----------------------------------------------------
;; Replace the trailing Gutenberg licence <pre> with the Annotations heading,
;; leaving NOTES-MARK at the append point. Returns the section's start position
;; (where the base text ends) for bounding the body reorders.
(defun prepare-notes-section (notes-mark)
  (goto-char (point-min))
  (search-forward "End of the Project Gutenberg EBook of Ulysses, by James Joyce")
  (search-backward "<pre")
  (let ((start (point)))
    (search-forward "</pre>")
    (delete-region start (point)))
  (let ((end-pos (point)))
    (insert (concat pagebreak "\n\n<h2>Annotations</h2>"))
    (insert "<a name=\"link2H_4_annotations\" id=\"link2H_4_annotations\"> </a>\n")
    (set-marker notes-mark (point))
    end-pos))

;; ---- note-file cleanup (operates on the CURRENT note buffer) -----------------
(defun cleanup-note ()
  (goto-char (point-min))
  (while (search-forward "<a" nil t)
    (backward-char 2)
    (let ((start (point)))
      (search-forward ">")
      (delete-region start (point))))
  (goto-char (point-min)) (replace-string "</a>" "")
  (goto-char (point-min)) (replace-string "<em><em>" "<em>")
  (goto-char (point-min)) (replace-string "</em></em>" "</em>")
  (goto-char (point-min)) (replace-string "<br>" "")
  (goto-char (point-min)) (replace-string "—" "&mdash;")
  ;; some files have extra nested divs
  (goto-char (point-min))
  (replace-string "<div id=\"note2\">" "")
  (replace-string "<div id=\"note\">" "")
  (replace-string "<div>" "")
  (replace-string "</div>" "")
  (goto-char (point-min))
  (when (not (re-search-forward "<p[ >]" nil t))
    (insert "<p>")
    (goto-char (point-max))
    (insert "</p>"))
  (goto-char (point-min))
  (when (not (search-forward "</p>" nil t))
    (goto-char (point-max))
    (insert "</p>"))
  (goto-char (point-min))
  (when (search-forward "<meta" nil t)
    (backward-char 5)
    (let ((start (point)))
      (search-forward ">")
      (delete-region start (point))))
  (goto-char (point-min)) (replace-string "</meta>" ""))

;; ---- note files: read + clean once, cache the components by filename ---------
;; Reading and cleaning a note file is the pipeline's hottest work, and the ~1195
;; distinct notes are each cited many times across the two (mono/colour) runs and
;; the index, so we cache the per-file components. The cache persists process-wide.
(setq *note-cache* (list nil))

;; Read FILENAME's note and return (HAS-TITLE TITLE PRE POST EXT-FOUND EXT-BODY):
;; PRE/POST are the cleaned note body split at its last </p> (the per-call backlink
;; goes between them); EXT-BODY is the cleaned extended note (or ""). Returns
;; 'failed for an empty/unreadable/malformed note.
(defun compute-note-components (filename)
  (let ((note-b (generate-new-buffer "note")) (result 'failed))
    (unwind-protect
        (catch 'done
          (with-current-buffer note-b
            ;; a missing/unreadable note file reads as empty and is treated as a
            ;; failed annotation by the caller.
            (condition-case e (insert-file-contents (concat basepath "/" filename)) (error nil))
            (goto-char (point-min))
            (when (= (point-min) (point-max)) (throw 'done nil))
            (let ((title "(title unknown)") (has-title nil))
              (if (search-forward "<title>" nil t)
                  (let ((ts (point)))
                    (if (search-forward "</title>" nil t)
                        (progn (setq title (buffer-substring ts (match-beginning 0))) (setq has-title t))
                      (message (concat "error: title end tag not found: " filename))
                      (throw 'done nil)))
                (message (concat "warning: unable to find title for note: " filename)))
              (goto-char (point-min))
              (when (not (search-forward "<div id=\"note\">" nil t))
                (message (concat "error: couldn't find starting point of note: " filename))
                (throw 'done nil))
              (let ((body-start (point)))
                (search-forward "</div>")
                (narrow-to-region body-start (match-beginning 0)))
              (cleanup-note)
              ;; split the cleaned body at its last </p>; the backlink lands there
              (goto-char (point-max))
              (search-backward "</p>")
              (let ((pre (buffer-substring (point-min) (point)))
                    (post (buffer-substring (point) (point-max)))
                    (ext-found t) (ext-body ""))
                ;; widen past the note body to look for an extended note
                (goto-char (point-max))
                (widen)
                (if (not (re-search-forward "<div id=\"expandednote\".*>" nil t))
                    (progn
                      (message (concat "error: couldn't find extended note: " filename))
                      (setq ext-found nil))
                  (let ((ext-start (point)))
                    (if (not (search-forward "<div id=\"button\"" nil t))
                        (progn
                          (message (concat "error: couldn't find end of extended note: " filename))
                          (setq ext-found nil))
                      (search-backward "</div>")
                      (narrow-to-region ext-start (point))
                      (cleanup-note)
                      (goto-char (point-min))
                      (if (search-forward "<div id=\"return\">" nil t)
                          (let ((rs (match-beginning 0)))
                            (search-forward "</div>")
                            (delete-region rs (point)))
                        (goto-char (point-min))
                        (when (re-search-forward "<p>JH 20[0-9][0-9]</p>" nil t)
                          (delete-region (match-beginning 0) (match-end 0))))
                      (setq ext-body (buffer-substring (point-min) (point-max))))))
                (setq result (list has-title title pre post ext-found ext-body))))))
      (kill-buffer note-b))
    result))

(defun note-components (filename)
  (let ((hit (assoc filename (car *note-cache*))))
    (if hit
        (cdr hit)
      (let ((result (compute-note-components filename)))
        (setcar *note-cache* (cons (cons filename result) (car *note-cache*)))
        result))))

;; ---- one footnote: assemble from the (cached) components, append to epub ------
(defun insert-footnote (filename note-id note-ref-id epub notes-mark notes-box)
  (let ((nc (note-components filename)))
    (if (eq nc 'failed)
        nil
      (let ((has-title (nth 0 nc)) (title (nth 1 nc)) (pre (nth 2 nc))
            (post (nth 3 nc)) (ext-found (nth 4 nc)) (ext-body (nth 5 nc)))
        (when has-title (add_to_notes_map notes-box title filename))
        (let ((note (concat "<font size=\"+1\"><em>"
                            (if (string= note-id "") title (concat note-id ". " title))
                            "</em></font>\n" pre
                            " <a href=\"#jpref" note-ref-id "\" role=\"doc-backlink\" title=\"Go to note reference\">⤶</a>"
                            post)))
          (with-current-buffer epub
            (goto-char notes-mark)
            (insert pagebreak)
            (if (not ext-found)
                (insert (concat "<div role=\"doc-footnote\" epub:type=\"footnote\" id=\"jpnote" note-ref-id "\">"
                                note
                                "Back to <a href=\"#jpref" note-ref-id "\" role=\"doc-backlink\" title=\"Go to note reference\">text</a>.</div>\n"))
              (insert (concat "<div role=\"doc-footnote\" epub:type=\"footnote\" id=\"jpnote" note-ref-id "\">"
                              note "<br/><u><em>Read more</em></u>" ext-body
                              "Back to <a href=\"#jpref" note-ref-id "\" role=\"doc-backlink\" title=\"Go to note reference\">text</a>.</div>\n")))
            (set-marker notes-mark (point))
            t))))))

;; ---- per-chapter annotation links, extracted once and cached -----------------
;; A chapter's (url colour text) triples (in document order) are identical across
;; the two builds, so extract them once (read + fix-mismatches + scan the body)
;; and cache; the second build then never touches the chapter source buffers.
(setq *chapter-links* (list nil))

(defun extract-chapter-links (chapter)
  (let ((b (generate-new-buffer "chap")) (links nil))
    (with-current-buffer b
      (insert-file-contents (concat basepath (nth chapter chapters)))
      (goto-char (point-min))
      (fix-mismatches chapter)
      ;; narrow the chapter source to its body (drop trailing nav links)
      (goto-char (point-min))
      (search-forward "class=\"newchapter\"")
      (search-forward ">")
      (let ((body-start (point)))
        (search-forward "<div id=\"footer\">")
        (narrow-to-region body-start (point)))
      (goto-char (point-min))
      (catch 'done
        (while t
          (when (not (search-forward "href=\"" nil t)) (throw 'done nil))
          (let (url colour text)
            (let ((s (point))) (search-forward "\"") (setq url (buffer-substring s (match-beginning 0))))
            (search-forward "data-color=\"")
            (let ((s (point))) (search-forward "\"") (setq colour (buffer-substring s (match-beginning 0))))
            (search-forward ">")
            (let ((s (point))) (search-forward "</a>") (setq text (buffer-substring s (match-beginning 0))))
            ;; precompute the fuzzy-search regex once (reused by both builds)
            (setq links (cons (list url colour text (fuzzy-regex text)) links))))))
    (kill-buffer b)
    (reverse links)))

(defun chapter-links (chapter)
  (let ((hit (assoc chapter (car *chapter-links*))))
    (if hit (cdr hit)
      (let ((links (extract-chapter-links chapter)))
        (setcar *chapter-links* (cons (cons chapter links) (car *chapter-links*)))
        links))))

;; ---- walk every chapter, attach a footnote per matched annotation ------------
;; MAIN-MARK tracks the base-text insert point; NOTES-MARK the Annotations append
;; point; both are markers in the epub. The per-chapter base-text slice is bounded
;; by an explicit CHAP-END marker rather than a narrowing.
(defun add-notes (epub main-mark notes-mark use-colour notes-box stats)
  (let ((total 0) (found 0) (not-found 0) (annotation-failures 0) (chapter 0))
    (while (< chapter 18)
      ;; the chapter's "[ N ]" heading into the Annotations section
      (with-current-buffer epub
        (goto-char notes-mark)
        (insert (concat pagebreak "<h3>[ " (number-to-string (1+ chapter)) " ]</h3>"))
        (set-marker notes-mark (point)))
      (let ((note-num 1) chap-end)
        ;; locate this chapter's base-text slice [ N ] .. [ N+1 ]; chap-end bounds
        ;; the fuzzy search (replacing main_cur's per-chapter narrowing)
        (with-current-buffer epub
          (goto-char (point-min))
          (search-forward (concat "[ " (number-to-string (1+ chapter)) " ]"))
          (set-marker main-mark (match-beginning 0))
          (if (< chapter 17)
              (search-forward (concat "[ " (number-to-string (+ chapter 2)) " ]"))
            (search-forward "<h2>Annotations</h2>"))
          (setq chap-end (copy-marker (match-beginning 0)))
          (when (= chapter 9)         ; Wandering Rocks: render <hr /> as "* * *"
            (goto-char main-mark)
            (while (search-forward "<hr />" (marker-position chap-end) t)
              (replace-match "<p style=\"text-align: center; margin: 1.5em 0; font-size: 1.3em;\">* * *</p>"))))
        ;; each annotation link in the chapter, in document order
        (dolist (link (chapter-links chapter))
          (let ((url (nth 0 link)) (colour (nth 1 link)) (text (nth 2 link)) (regex (nth 3 link)))
            (setq total (1+ total))
            (if (with-current-buffer epub
                  (goto-char main-mark)
                  (when (re-search-forward regex (marker-position chap-end) t) (set-marker main-mark (point)) t))
                (let ((note-str (number-to-string note-num))
                      (note-ref-str (number-to-string found)))
                  (if (insert-footnote url note-str note-ref-str epub notes-mark notes-box)
                      (progn
                        (with-current-buffer epub
                          (goto-char main-mark)
                          (if (and use-colour (not (string= colour "")))
                              (insert (concat "<sup><a id=\"jpref" note-ref-str "\" style=\"color:#" colour "\" role=\"doc-noteref\" epub:type=\"noteref\" href=\"#jpnote" note-ref-str "\">" note-str "</a></sup>"))
                            (insert (concat "<sup><a id=\"jpref" note-ref-str "\" role=\"doc-noteref\" epub:type=\"noteref\" href=\"#jpnote" note-ref-str "\">" note-str "</a></sup>")))
                          (set-marker main-mark (point)))
                        (setq found (1+ found))
                        (setq note-num (1+ note-num)))
                    (message (concat "annotation_failed-" (nth chapter chapters) ": " text))
                    (setq annotation-failures (1+ annotation-failures))))
              (with-current-buffer epub
                (goto-char main-mark)
                (let ((ctx (buffer-substring (point) (min (point-max) (+ (point) 100)))))
                  (message (concat "text_not_found-" (nth chapter chapters) ": " text " || base: " ctx))))
              (setq not-found (1+ not-found))))))
      (setq chapter (1+ chapter)))
    (message (concat "total:" (number-to-string total)))
    (message (concat "found:" (number-to-string found)))
    (message (concat "not_found:" (number-to-string not-found)))
    (stat-set stats "total" total)
    (stat-set stats "found" found)
    (stat-set stats "not_found" not-found)
    (stat-set stats "broken_links" annotation-failures)))

;; ---- alphabetical "Index of Notes" ------------------------------------------
(defun add-notes-index (epub notes-box index-mark notes-mark stats)
  ;; index-mark and notes-mark both start at the end of the Annotations section;
  ;; inserting the "Notes" subheading at notes-mark lands it just before the
  ;; "Index of Notes" heading at index-mark, exactly as the two cursors did.
  (with-current-buffer epub
    (goto-char index-mark)
    (insert pagebreak)
    (insert "<h2>Index of Notes</h2>")
    (insert "<a name=\"link2H_4_index_titles\" id=\"link2H_4_index_titles\"> </a>\n")
    (insert "<p>All of the notes posted so far are listed here alphabetically by title. Click to go directly to a note without locating its appearances in the text of the novel.</p>")
    (set-marker index-mark (point))
    (goto-char notes-mark)
    (insert pagebreak)
    (insert "<h3>Notes</h3>")
    (set-marker notes-mark (point)))
  (let ((count 0)
        (index (car notes-box)))
    (let ((letters (sort (mapcar (lambda (lp) (car lp)) index) (lambda (a b) (string< a b)))))
      (dolist (letter letters)
        (when (not (string= letter "Ü"))
          (with-current-buffer epub
            (goto-char index-mark)
            (insert (concat "<h3>" letter "</h3>"))
            (set-marker index-mark (point)))
          (let ((notes nil))
            (when (and (string= letter "U") (assoc "Ü" index))
              (setq notes (append notes (sort-titles (cdr (assoc "Ü" index))))))
            (setq notes (append notes (sort-titles (cdr (assoc letter index)))))
            (dolist (note notes)
              (let ((note-ref-str (concat "iot-" (number-to-string count))))
                (when (insert-footnote (cdr note) "" note-ref-str epub notes-mark (list nil))
                  (with-current-buffer epub
                    (goto-char index-mark)
                    (insert (concat "<a id=\"jpref" note-ref-str "\" role=\"doc-noteref\" epub:type=\"noteref\" href=\"#jpnote" note-ref-str "\">" (car note) "</a><br />"))
                    (set-marker index-mark (point)))
                  (setq count (1+ count)))))))))
    (message (concat "distinct_notes: " (number-to-string count)))
    (stat-set stats "distinct_notes" count)))
