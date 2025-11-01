#! /usr/bin/env ChatGPTWeb-upload --ChatGPTWebAPI --new --loop
instruction:
emacs30 の tkita版 impatient-mode で、markdown-it + mermaid + highlight + mathjax
を xwidget + WbKit でブラウザ表示する。リアルタイムレンダリングしている。
ソースコードは impatient-mode.el である。
emacs 側で C-c C-e を押すとJSレンダリングが収まるのを待って、DOM の html 文を emacs 側に送信する機能を実装した。
ソースコードは markdown-to-pdf.el である。
inputs:
impatient-mode.el impatient-mode.el
markdown-to-pdf.el markdown-to-pdf.el
instruction:
最重要指示２４箇条を思い出すこと。
markdown-to-pdf.el は emacs30 では動作しない。
emacs30 では xwidget-list は xwidget オブジェクトのリストだ。
emacs30 では xwidget-type も xwidget-id も xwidget-plist-get もない。
今の markdown-to-pdf--xwidget-get-buffer のコードは書き換えてはいけない。
markdown-to-pdf--xwidget-get-buffer でバッファを限定した後、そこにある xwidget オブジェクトは webkit 型だ。
xwidget オブジェクト自体を xwidget-webkit-execute-script に渡すこと。
きちんと動作するように markdown-to-pdf.el を修正して。
最重要指示２４箇条による提示前のチェックも忘れないこと。
