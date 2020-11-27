generate: download addanno epub

download:
	go run dl-anno.go

addanno:
	mime add-anno.mime

epub:
	ebookmaker \
		--make epub.images \
		--output-file ../4300-h/4300-h-annotated.epub \
		--cover ../cover.jpg \
		../4300-h/4300-h-annotated.htm
