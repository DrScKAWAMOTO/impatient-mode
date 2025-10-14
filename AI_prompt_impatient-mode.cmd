#! /usr/bin/env uploadChatGPT --ChatGPTFreeAPI --new --loop
instruction:
tkita版 impatient-mode で、Web 系 JavaScript, CSS を最新のものに置き換え(make get)て、
markdown の表示、mermaid の表示、highlight の表示が、chrome と xwidget-WebKit で
できるようになった。
問題がある。xwidget-WebKit では、mermaid の表示がソースコードになる。
原因は marked を使っているからだとわかった。
marked を markdown-it へ変更して、Markdown Preview Enhanced と互換性のあるビューアに仕上げたい。
mermaid も mathjax も highlight も markdown-it のプラグインとして実装する。
今から、現状の merked + marmaid + highlight のソースコードを順に私が提示する。
まずは marked を markdown-it に変更する修正をフルソースコードで提示して。
inputs:
impatient-mode.el impatient-mode.el
impatient-mode.js impatient-mode.js
index.html index.html
Makefile Makefile

