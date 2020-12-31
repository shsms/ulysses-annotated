generate: download addanno epub

download:
	go run dl-anno.go

date=$(shell bash -c "LC_ALL=en_GB.utf8 date '+%B %d, %Y'")
addanno:
	mime upd-epub-to-jp.mime
	mime add-anno.mime --date "$(date)"

epub:
	ebookmaker \
		--make epub.images \
		--title Ulysses \
		--author "James Joyce" \
		--output-file ../4300-h/4300-h-annotated.epub \
		--cover ../cover.jpg \
		../4300-h/4300-h-annotated.htm

epub-orig:
	ebookmaker \
		--make epub.images \
		--title Ulysses \
		--author "James Joyce" \
		--output-file ../4300-h/4300-h.epub \
		--cover ../cover.jpg \
		../4300-h/4300-h.htm
