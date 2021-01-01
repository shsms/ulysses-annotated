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

The provided [go](https://golang.org/) program uses [ideacrawler](https://github.com/shsms/ideacrawler) to download the annotations.  To run,

- install a recent go compiler from https://golang.org

- start the ideacrawler server:

		git clone https://github.com/shsms/ideacrawler
		cd ideacrawler
		make build
		build/ideacrawler

- run the download client in a second terminal:

		cd ulysses-annotated/scripts
		go get github.com/shsms/ideacrawler/goclient
		make download

This would take some time,  but the files will get downloaded into `ulysses-annotated/scripts/annotations-raw`

### Download and build mime

[Mime](https://github.com/shsms/mime) is a text processing framework that we use for adding annotations to the epub source file,  from the joyceproject files downloaded in the previous step.  Mime is written in C++ and you need a C++ compiler to build it.  It currently works only on linux.

Follow the instructions in the mime [Getting started](https://mime.dev/getting-started.html) page to build mime.


### Run the provided mime scripts

	cd ulysses-annotated/scripts
	make addanno

This step would generate an annotated html file in `/tmp/annotated.htm` that the next stage would pick up.

### Generate epub from the annotated html file

For this step,  we use the [ebookmaker](https://github.com/gutenbergtools/ebookmaker) tool from Project Gutenberg.  Along with ebookmaker,  we also have to install its prerequisites.  On Manjaro,  these can be installed using:

	sudo pacman -S tidy calibre
	pip install ebookmaker pytidylib

Then you can generate the epub using the below command:

	make epub

This step is likely to print a number of warnings related to proprietary tags in the source file.  These tags are required for the pop-up footnotes we use to display the annotations.  It will also print warnings about the presence of URLs to external sites.  These are URLs to annotations pages on joyceproject.com,  that we can visit to read more and for pictures relating to any annotation.

The generated epub file will be in: `ulysses-annotated/ulysses-annotated.epub`.
