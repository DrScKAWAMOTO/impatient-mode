#! /usr/bin/env ChatGPTWeb-upload --ChatGPTWebAPI --new --loop
instruction:
emacs30 の tkita版 impatient-mode で、markdown-it + mermaid + highlight + mathjax
を xwidget + WbKit でブラウザ表示する。リアルタイムレンダリングしている。
これを、emacs 側で C-c C-e を押すとJSレンダリングが収まるのを待って、DOM の html 文を emacs 側に送信する機能を実装した。
impatient-mode.el と impatient-mode.js の最新版を以下に私が提示する。
inputs:
impatient-mode.js impatient-mode.js
impatient-mode.el impatient-mode.el
instruction:
最重要指示２２箇条を思い出すこと。
C-c C-e に登録された関数は emacs30 では動作しない。
emacs30 では xwidget-list は xwidget オブジェクトのリストだ。
emacs30 では xwidget-type はない。
今の imp--xwidget-webkit-buffer でバッファを限定すれば、そこにある xwidget オブジェクトは webkit 型だ。
きちんと動作するように修正して。
