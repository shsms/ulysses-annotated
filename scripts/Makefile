MIME ?= mime

.PHONY: download addanno epub

download:
	go run dl-anno.go annotations-raw/

date=$(shell bash -c "LC_ALL=en_GB.utf8 date '+%B %d, %Y'")
addanno:
	${MIME} upd-epub-to-jp.mime --infile ../4300-h/4300-h.htm --outfile /tmp/updated-to-jp.htm
	${MIME} add-anno.mime --date "${date}" --anno_path annotations-raw/ --infile /tmp/updated-to-jp.htm --outfile /tmp/annotated.htm --colour_outfile /tmp/colour_annotated.htm --with_badges

epub:
	ebookmaker \
		--make epub.images \
		--title Ulysses \
		--author "James Joyce" \
		--output-file ../ulysses-annotated-monochrome.epub \
		--cover ../cover.jpg \
		/tmp/annotated.htm
	ebookmaker \
		--make epub.images \
		--title Ulysses \
		--author "James Joyce" \
		--output-file ../ulysses-annotated.epub \
		--cover ../cover.jpg \
		/tmp/colour_annotated.htm
	mv ../ulysses-annotated-monochrome.epub-images-epub.epub ../ulysses-annotated-monochrome.epub
	mv ../ulysses-annotated.epub-images-epub.epub ../ulysses-annotated.epub
