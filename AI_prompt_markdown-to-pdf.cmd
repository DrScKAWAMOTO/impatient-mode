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
C-c C-e を入力すると、以下のログまで出た。しかしそれ以降が出ない。原因を究明して。
markdown-to-pdf found xwidget buffer: *xwidget-webkit: 1200兆円の借金.md*
markdown-to-pdf: found xwidget buffers=("*xwidget-webkit: 1200兆円の借金.md*")
markdown-to-pdf: selected buffer=*xwidget-webkit: 1200兆円の借金.md*, xwidget-object=<object>
markdown-to-pdf: pending save-file set to ~/src/MyNotes/経済関係/dom.html
markdown-to-pdf: execute-script dispatched to xwidget
