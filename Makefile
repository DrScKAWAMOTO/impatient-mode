# Clone the two dependencies of this package in sibling directories:
#   $ git clone https://github.com/hniksic/emacs-htmlize ../htmlize
#   $ git clone https://github.com/skeeto/emacs-web-server ../simple-httpd
#
# Or set LDFLAGS to point at these packages elsewhere:
#     $ make LDFLAGS='-L path/to/htmlize -L path/to/simple-httpd'
.POSIX:
.SUFFIXES: .el .elc
CURL    = curl -L -o
EMACS   = emacs
LDFLAGS = -L ../simple-httpd -L ../htmlize
VERSION = 1.1
GITHUB  = https://raw.githubusercontent.com

DIST = README.md index.html index.css impatient-mode.js

all: compile

compile: impatient-mode.elc

package: impatient-mode-$(VERSION).tar

impatient-mode-$(VERSION).tar: impatient-mode.el $(DIST)
	rm -rf impatient-mode-$(VERSION)/
	mkdir impatient-mode-$(VERSION)/
	cp impatient-mode.el $(DIST) impatient-mode-$(VERSION)/
	tar cf $@ impatient-mode-$(VERSION)/
	rm -rf impatient-mode-$(VERSION)/

clean:
	rm -f impatient-mode-$(VERSION).tar impatient-mode.elc \
          github-markdown.css markdown-it.min.js simple-httpd.el \
          mermaid.min.js mermaid.min.js.map highlight.pack.min.js \
          highlight.github.min.css mathjax.zip
	rm -rf MathJax-master
	rm -f result.html remove.html struct.html result.json work.cmd work.cmd~


run: impatient-mode.elc
	$(EMACS) -Q $(LDFLAGS) -l impatient-mode.elc \
		 impatient-mode.el \
		 -f impatient-mode -f httpd-start

.el.elc:
	$(EMACS) -Q -batch $(LDFLAGS) -f batch-byte-compile $<

get:
	# CSS
	$(CURL) github-markdown.css      https://cdn.jsdelivr.net/npm/github-markdown-css@5.2.0/github-markdown.min.css
	$(CURL) highlight.github.min.css https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/styles/github.min.css
	# JS
	$(CURL) markdown-it.min.js       https://cdn.jsdelivr.net/npm/markdown-it@13.0.1/dist/markdown-it.min.js
	$(CURL) simple-httpd.el          $(GITHUB)/skeeto/emacs-web-server/master/simple-httpd.el
	$(CURL) mermaid.min.js           https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js
	$(CURL) mermaid.min.js.map       https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js.map
	$(CURL) highlight.pack.min.js    https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/highlight.min.js
	# MathJax (zip を展開して配置)
	$(CURL) mathjax.zip              https://github.com/mathjax/MathJax/archive/refs/heads/master.zip
	unzip -o mathjax.zip -d .
	cp MathJax-master/tex-mml-chtml.js .
