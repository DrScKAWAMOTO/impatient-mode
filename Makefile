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

# DIST に配布/パッケージ化対象ファイルを追加
DIST = README.md index.html index.css impatient-mode.js markdown-it.min.js mermaid.min.js mermaid.min.js.map highlight.pack.min.js highlight.github.min.css mathjax-tex-mml-chtml.js

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
	rm -f impatient-mode-$(VERSION).tar impatient-mode.elc github-markdown.css markdown-it.min.js mermaid.min.js mermaid.min.js.map highlight.pack.min.js highlight.github.min.css mathjax-tex-mml-chtml.js

run: impatient-mode.elc
	$(EMACS) -Q $(LDFLAGS) -l impatient-mode.elc \
		 impatient-mode.el \
		 -f impatient-mode -f httpd-start

.el.elc:
	$(EMACS) -Q -batch $(LDFLAGS) -f batch-byte-compile $<

get:
	# CSS
	$(CURL) github-markdown.css      https://cdn.jsdelivr.net/npm/github-markdown-css@5.2.0/github-markdown.min.css
	# markdown-it (marked の代替)
	$(CURL) markdown-it.min.js       https://cdn.jsdelivr.net/npm/markdown-it/dist/markdown-it.min.js
	# simple-httpd (Emacs 用)
	$(CURL) simple-httpd.el          $(GITHUB)/skeeto/emacs-web-server/master/simple-httpd.el
	# mermaid
	$(CURL) mermaid.min.js           https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js
	$(CURL) mermaid.min.js.map       https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js.map
	# highlight.js
	$(CURL) highlight.pack.min.js    https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/highlight.min.js
	$(CURL) highlight.github.min.css https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/styles/github.min.css
	# MathJax v3 (TeX+MathML+CHTML)
	$(CURL) mathjax-tex-mml-chtml.js  https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js
