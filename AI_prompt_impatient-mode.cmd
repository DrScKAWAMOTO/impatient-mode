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
imp--xwidget-webkit-buffer は、「xwidget-webkit」という名前のバッファを探しているが、これは間違い。
「*xwidget-webkit: XXXX*」という名前のバッファ(XXXXは任意の文字列)を探して、すべて *Messages* にログ出力し、これらのバッファリストを返却して。
最重要指示２２箇条を思い出して、修正案を提示して。
