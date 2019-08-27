HTML_FILES = $(shell find src -type f | grep -v /_ | grep -E '\.pug' | tr '\n' ' ' | sed 's/\.pug/.html/g' | sed 's/\.md/.html/g' | sed 's/src\//dist\//g')
STYLE_FILES = $(shell find src/styles -type f | grep -v /_ | tr '\n' ' ' | sed 's/src\//dist\//g' | sed 's/\.styl/\.css/g')
ASSET_FILES = $(shell find src/assets -type f | grep -v /_ | tr '\n' ' ' | sed 's/src\//dist\//g')
NODEPATH = $(shell npm bin)
all: first html assets styles
first:
	mkdir -p dist/help/
html: $(HTML_FILES)
styles: $(STYLE_FILES)
assets: $(ASSET_FILES)
dist/%.html: src/%.pug src/_template.pug src/help/_template.pug
	$(NODEPATH)/pug -O "{pretty:true}" -p $< < $< > $@
dist/assets/%: src/assets/%
	mkdir -p $(shell dirname $@)
	cp $< $@
dist/styles/%.css: src/styles/%.styl
	mkdir -p $(shell dirname $@)
	$(NODEPATH)/stylus $< -o $@
clean:
	rm -rf dist/
	mkdir dist
	touch dist/.gitkeep
upload: clean all
	$(NODEPATH)/gh-pages -d dist