HTML_FILES = $(shell find src -type f | grep -v /_ | grep -E '\.pug' | tr '\n' ' ' | sed 's/\.pug/.html/g' | sed 's/\.md/.html/g' | sed 's/src\//dist\//g')
NODEPATH = $(shell npm bin)
all: first html
first:
	mkdir -p dist/help/
html: $(HTML_FILES)
dist/%.html: src/%.pug
	$(NODEPATH)/pug -O "{pretty:true}" -p $< < $< > $@
clean:
	rm -rf dist/
	mkdir dist
	touch dist/.gitkeep
upload: clean all
	$(NODEPATH)/gh-pages -d dist