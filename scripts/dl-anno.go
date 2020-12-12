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

	ffilter := `joyceproject.com($|\/(index.php\?chapter|notes\/.*html?))`
	cfilter := `\/(index.php\?chapter|notes\/.*html?)`

	spec := gc.NewJobSpec(
		gc.Depth(5),
		gc.MaxIdleTime(60),
		//		gc.Chrome(true, "/usr/bin/chromium"),
		gc.CallbackURLRegexp(cfilter),
		gc.FollowURLRegexp(ffilter),
		gc.PageChan(gc.NewPageChan()),
		gc.ThreadsPerSite(5),
		gc.MinDelay(2),
	)

	z, err := gc.NewCrawlJob(w, spec)
	if err != nil {
		log.Fatal(err)
	}

	z.AddPage("http://joyceproject.com", "")

	for z.IsAlive() == true {
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
		return
	}
	filepath := "annotations-raw/" + path.Dir(u.Path)
	suffix :=  u.Query().Get("chapter")
	if len(suffix) > 0 {
		suffix = "-" + suffix + ".htm"
	}
	fn := "annotations-raw/" + u.Path + suffix
	log.Println(ph.Httpstatuscode, u.Path, path.Dir(u.Path), ph.UrlDepth)
	os.MkdirAll(filepath, 0755)
	ioutil.WriteFile(fn, ph.Content, 0755)
}
