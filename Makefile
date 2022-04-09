.PHONY: default
default:
	dune build

.PHONY: doc
doc:
	pandoc --from gfm --to html --standalone doc/manual.md -o doc/manual.html \
		-M title='Kalandralang User Manual' \
		--toc --toc-depth 5 \
		-c style.css
