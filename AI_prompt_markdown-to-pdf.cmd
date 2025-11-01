#! /usr/bin/env ChatGPTWeb-upload --ChatGPTWebAPI --new --loop
instruction:
emacs30 の tkita版 impatient-mode で、markdown-it + mermaid + highlight + mathjax
を xwidget + WbKit でブラウザ表示する。リアルタイムレンダリングしている。
これを、emacs 側で C-c C-e を押すとJSレンダリングが収まるのを待って、DOM の html 文を emacs 側に送信する機能を実装した。
emacs 側のコードが impatient-mode.el である。
inputs:
impatient-mode.el impatient-mode.el
instruction:
最重要指示２４箇条を思い出すこと。
impatient-mode.el からDOM取得関連機能とそれを起動する C-c C-e のキーシーケンス登録をそのまま抜き出して、markdown-to-pdf.el を作成して。
markdown-to-pdf.el に移す関数類はどれも元の機能を完全に再現して。
impatient-mode.el からは、DOM取得関連機能とそれを起動する C-c C-e のキーシーケンス登録を削除して残りはすべてそのまま残して。
markdown-to-pdf.el から impatient-mode.el を require するようにして。
関連するサブルーチン類も必要に応じて markdown-to-pdf.el に移動して。
両方からアクセスするサブルーチンは impatient-mode.el 側に残して、markdown-to-pdf.el 側からは require によって使えるようにして。
出来上がった impatient-mode.el の内容と markdown-to-pdf.el の内容をあわせると、元々の impatient-mode.el のコードにある関数などすべてが残っていることを確認して。
コメントも一切削除していないことも確認して。
すべてが揃っていることが確認できたら、impatient-mode.el の修正後のフルソースコードと、markdown-to-pdf.el の作成後のフルソースコードを提示して。
最重要指示２４箇条による提示前のチェックも忘れないこと。
