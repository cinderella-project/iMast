HTML_FILES = $(shell find src -type f | grep -v /_ | grep -E '\.(pug|md)' | tr '\n' ' ' | sed 's/\.pug/.html/g' | sed 's/\.md/.html/g' | sed 's/src\//dist\//g')
NODEPATH = $(shell npm bin)
all: first html
first:
	mkdir -p dist/help/
html: $(HTML_FILES)
dist/%.html: src/%.pug
	$(NODEPATH)/pug -O "{pretty:true}" -p $< < $< > $@
dist/help/%.html: src/help/%.md
	$(NODEPATH)/marked $< -o $@.temp
	$(NODEPATH)/pug -O "{pretty:true, content:require('fs').readFileSync('$@.temp')}" -p src/help/_template.pug < src/help/_template.pug > $@
	rm $@.temp
clean:
	rm -rf dist/
	mkdir dist
	touch .gitkeep