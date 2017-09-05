HTML_FILES = $(shell find src -type f | grep -v /_ | grep -E '\.pug' | tr '\n' ' ' | sed 's/\.pug/.html/g' | sed 's/\.md/.html/g' | sed 's/src\//dist\//g')
ASSET_FILES = $(shell find src/assets -type f | grep -v /_ | tr '\n' ' ' | sed 's/src\//dist\//g')
NODEPATH = $(shell npm bin)
all: first html assets
first:
	mkdir -p dist/help/
html: $(HTML_FILES)
assets: $(ASSET_FILES)
dist/%.html: src/%.pug
	$(NODEPATH)/pug -O "{pretty:true}" -p $< < $< > $@
dist/assets/%: src/assets/%
	mkdir -p $(shell dirname $@)
	cp $< $@
clean:
	rm -rf dist/
	mkdir dist
	touch dist/.gitkeep
upload: clean all
	$(NODEPATH)/gh-pages -d dist