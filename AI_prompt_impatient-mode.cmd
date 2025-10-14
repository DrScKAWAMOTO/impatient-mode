#! /usr/bin/env uploadChatGPT --ChatGPTFreeAPI --new --loop
instruction:
tkita版 impatient-mode で、Web 系 JavaScript, CSS を最新のものに置き換え(make get)て、
markdown の表示、mermaid の表示、highlight の表示が、chrome と xwidget-WebKit で
できるようになった。
問題がある。xwidget-WebKit では、mermaid の表示がソースコードになる。
原因は marked を使っているからだとわかった。
marked を markdown-it へ変更して、Markdown Preview Enhanced と互換性のあるビューアに仕上げたい。
mermaid も mathjax も highlight も markdown-it のプラグインとして実装する。
markdown-it に対応させた現状の mrkdown-it + marmaid + highlight のソースコードを順に私が提示する。
この構成で、/imp/static に impatient-mode.js と index.css しか存在しない。
問題点を洗い出して。
inputs:
impatient-mode.el impatient-mode.el
impatient-mode.js impatient-mode.js
index.html index.html
Makefile Makefile

