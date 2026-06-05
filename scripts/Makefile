MIME ?= mime
MAX_UNMATCHED_PCT ?= 10

.PHONY: download addanno epub

download:
	go run dl-anno.go annotations-raw/

date=$(shell bash -c "LC_ALL=en_GB.utf8 date '+%B %d, %Y'")
addanno:
	${MIME} run upd-epub-to-jp.tl --infile ../4300-h/4300-h.htm --outfile /tmp/updated-to-jp.htm </dev/null
	${MIME} run add-anno.tl --infile /tmp/updated-to-jp.htm --anno_path annotations-raw --date "${date}" --outfile /tmp/annotated.htm --colour_outfile /tmp/colour_annotated.htm --max_unmatched_pct ${MAX_UNMATCHED_PCT} --with_badges </dev/null

epub:
	ebookmaker \
		--make epub.images \
		--title Ulysses \
		--author "James Joyce" \
		--output-file ../ulysses-annotated-monochrome.epub \
		--cover ../cover-monochrome.jpg \
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
