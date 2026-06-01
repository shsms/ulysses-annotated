# Steps to generate the annotated epub

## Use Docker

Use the below commands to generate the annotated epub on any OS.  You need to install [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [docker](https://docs.docker.com/get-docker/) first.

	git clone https://github.com/shsms/ulysses-annotated
    cd ulysses-annotated
	docker build -t ulysses-annotated:latest .
	
	mkdir anno
	datadir=$(pwd)/anno
	
	docker run -v ${datadir}:/datadir -it ulysses-annotated:latest  download
	docker run -v ${datadir}:/datadir -it ulysses-annotated:latest  generate
	
The build and download steps could be a bit	slow.  Once the steps are complete,  the annotated epub file will be in the `anno` directory.

## Build from source
All these steps below were verified to work on [Manjaro](https://manjaro.org/),  but they are likely to work on other Linux based OS as well.

### Download files from joyceproject

The provided [go](https://golang.org/) program downloads the annotations from the Joyce Project's JSON API.  To run,

- install a recent go compiler from https://golang.org

- run the downloader:

		cd ulysses-annotated/scripts
		make download

This fetches each chapter and note over the API (sequentially, to stay gentle on the server) into `ulysses-annotated/scripts/annotations-raw`.  Raw API responses are cached under `annotations-raw/.api-cache`,  so reruns don't refetch.

### Download mime

[mime-rs](https://github.com/shsms/mime-rs) is the scriptable text-editing engine we use to add the annotations to the EPUB source,  from the joyceproject files downloaded in the previous step.  Download the prebuilt Linux x86_64 binary into the repository root:

	cd ulysses-annotated
	curl -fOL https://github.com/shsms/mime-rs/releases/download/v0.1.0/mime-linux-x86_64.tar.gz
	tar -xzf mime-linux-x86_64.tar.gz
	chmod +x mime


### Run the provided scripts

	cd ulysses-annotated/scripts
	make addanno MIME=../mime

This step would generate an annotated html file in `/tmp/annotated.htm` that the next stage would pick up.

### Generate epub from the annotated html file

For this step,  we use the [ebookmaker](https://github.com/gutenbergtools/ebookmaker) tool from Project Gutenberg.  Along with ebookmaker,  we also have to install its prerequisites.  On Manjaro,  these can be installed using:

	sudo pacman -S tidy calibre
	pip install ebookmaker pytidylib

Then you can generate the epub using the below command:

	make epub

This step is likely to print a number of warnings related to proprietary tags in the source file.  These tags are required for the pop-up footnotes we use to display the annotations.  It will also print warnings about the presence of URLs to external sites.  These are URLs to annotations pages on joyceproject.com,  that we can visit to read more and for pictures relating to any annotation.

The generated epub file will be in: `ulysses-annotated/ulysses-annotated.epub`.
