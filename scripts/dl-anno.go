// +build ignore

package main

import (
	"io/ioutil"
	"log"
	"net/url"
	"os"
	"path"

	"time"

	gc "github.com/shsms/ideacrawler/goclient"
)

func main() {
	w, err := gc.NewWorker("127.0.0.1:2345", nil)
	if err != nil {
		log.Fatal(err)
	}

	ffilter := `joyceproject.com($|\/(index.php\?chapter|notes\/.*html?|scripts\/swap(\/.*js)?))`
	cfilter := `\/(index.php\?chapter|notes\/.*html?|scripts\/swap\/.*js)`

	spec := gc.NewJobSpec(
		gc.Depth(2),
		gc.MaxIdleTime(5),
		gc.CallbackURLRegexp(cfilter),
		gc.FollowURLRegexp(ffilter),
		gc.PageChan(gc.NewPageChan()),
		gc.ThreadsPerSite(2),
		gc.MinDelay(2),
		gc.NoMimeType(),
	)

	z, err := gc.NewCrawlJob(w, spec)
	if err != nil {
		log.Fatal(err)
	}

	z.AddPage("http://www.joyceproject.com/scripts/swap", "")
	z.AddPage("http://joyceproject.com", "")
	for z.IsAlive() {
		select {
		case ph := <-z.PageChan:
			go saveFile(ph)
		default:
			time.Sleep(time.Second)
		}
	}
}

func saveFile(ph *gc.PageHTML) {
	u, err := url.Parse(ph.Url)
	if err != nil {
		log.Print("Error: " + err.Error())
		return
	}
	basedir := os.Args[1]
	filepath := basedir + path.Dir(u.Path)
	suffix :=  u.Query().Get("chapter")
	if len(suffix) > 0 {
		suffix = "-" + suffix + ".htm"
	}
	fn := path.Join(basedir, u.Path + suffix)
	log.Println(ph.Httpstatuscode, fn, ph.UrlDepth)
	os.MkdirAll(filepath, 0755)
	ioutil.WriteFile(fn, ph.Content, 0755)
}
