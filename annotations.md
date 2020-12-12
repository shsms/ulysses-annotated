# Steps to generate annotations

All these steps below were verified to work on [Manjaro](https://manjaro.org/),  but they are likely to work on other Linux based OS as well.

## Download files from joyceproject

The provided [go](https://golang.org/) program uses ![ideacrawler](https://github.com/shsms/ideacrawler) to download the annotations.  To run,

- install a recent go compiler from https://golang.org

- start the ideacrawler server:

		git clone https://github.com/shsms/ideacrawler
		cd ideacrawler
		make build
		build/ideacrawler

- run the download client in a second terminal:

		cd ulysses-annotated/scripts
		go get github.com/shsms/ideacrawler/goclient
		go run dl-anno.go    ## (or run: make download)

This would take some time,  but the files will get downloaded into `ulysses-annotated/scripts/annotations-raw`

## Download and build mime

![Mime](https://github.com/shsms/mime) is a text processing framework that we use for adding annotations to the epub source file,  from the joyceproject files downloaded in the previous step.  Mime is written in C++ and you need a C++ compiler to build it.  It currently works only on linux.

    git clone https://github.com/shsms/mime
	cd mime
	make init
	make build install -j

## Run the provided mime script

	cd ulysses-annotated/scripts
    mime add-anno.mime   ## (or run:  make addanno)

This step would generate an annotated html file in `ulysses-annotated/4300-h/4300-h-annotated.htm`

## Generate epub from the annotated html file

For this step,  we use the ![ebookmaker](https://github.com/gutenbergtools/ebookmaker) tool from Project Gutenberg.  Along with ebookmaker,  we also have to install its prerequisites.  On Manjaro,  these can be installed using:

	sudo pacman -S tidy calibre
	pip install ebookmaker pytidylib

Then you can generate the epub using the below command:

	ebookmaker \
		--make epub.images \
		--output-file ../4300-h/4300-h-annotated.epub \
		--cover ../cover.jpg \
		../4300-h/4300-h-annotated.htm

	## (or run: make epub)

This step is likely to print a number of warnings related to proprietary tags in the source file.  These tags are required for the pop-up footnotes we use to display the annotations.  It will also print warnings about the presence of URLs to external sites.  These are URLs to annotations pages on joyceproject.com,  that we can visit to read more and for pictures relating to any annotation.

The generated epub file will be in: `ulysses-annotated/4300-h/4300-h-annotated.epub`.
