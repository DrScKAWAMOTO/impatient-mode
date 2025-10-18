#! /usr/bin/env uploadChatGPT --ChatGPTFreeAPI --new --loop
instruction:
emacs30 の tkita版 impatient-mode で、markdown-it + mermaid + highlight + mathjax
を xwidget + WbKit でブラウザ表示し、DOM が落ち着いた時点 (JSレンダリング完了後) で DOM を elisp 側に取得する修正をして。
impatient-mode.el と impatient-mode.js の最新版は以下のとおり。
inputs:
impatient-mode.el impatient-mode.el
impatient-mode.js impatient-mode.js
instruction:
必要な処理修正は以下の3つ。
1. JS 側でレンダリング完了を検知する。
2. JS から DOM を html 文にして送信する。
3. Elisp 側で html 文を受け取る。
修正対象は impatient-mode.el と impatient-mode.js だ。
まず、impatient-mode.js の修正結果を提示して。
最重要指示は絶対に忘れないで。

