#! /usr/bin/env uploadChatGPT --ChatGPTFreeAPI --new --loop
instruction:
tkita版 impatient-mode で、Web 系 JavaScript, CSS を最新のものに置き換え(make get)て、
markdown の表示、mermaid の表示、highlight の表示が、chrome と xwidget-WebKit で
できるようになった。
marked を markdown-it へ変更して、Markdown Preview Enhanced と互換性のあるビューアに仕上げた。
mermaid も mathjax も highlight も markdown-it のプラグインとして実装した。
問題点を洗い出して。
inputs:
impatient-mode.el impatient-mode.el
impatient-mode.js impatient-mode.js
index.html index.html
Makefile Makefile

