;;; markdown-to-pdf.el --- DOM取得・C-c C-e 起動 -*- lexical-binding: t; -*-

(require 'impatient-mode)

(defvar imp--xwidget-pending-save-file nil
  "Pending file path to save DOM content from xwidget.")

(defun markdown-to-pdf--xwidget-get-buffer ()
  "Return a list of all *xwidget-webkit: ...* buffers."
  (let (result)
    (dolist (b (buffer-list))
      (let ((name (buffer-name b)))
        (when (string-match-p "^\\*xwidget-webkit: .+\\*$" name)
          (message "markdown-to-pdf found xwidget buffer: %s" name)
          (push name result))))
    result))

(defun markdown-to-pdf--xwidget-dom-handler (html-content)
  "JS から送られてきた HTML を受け取り、テンポラリバッファ経由で保存する。
HTML-CONTENT は文字列。保存先は `imp--xwidget-pending-save-file`。"
  (interactive "sHTML content: ")
  (message "markdown-to-pdf: DOM handler invoked; content length=%d" (length html-content))
  (let* ((file-path (or (and (boundp 'imp--xwidget-pending-save-file) imp--xwidget-pending-save-file)
                        (read-file-name "Save DOM to file: " nil nil nil "dom.html")))
         (cur-buf (current-buffer)))
    (message "markdown-to-pdf: resolved save-file=%s" file-path)
    (if (not (buffer-live-p cur-buf))
        (message "markdown-to-pdf: current buffer is not live; aborting save")
      (condition-case err
          (progn
            (with-temp-buffer
              (insert html-content)
              (write-region (point-min) (point-max) file-path))
            (message "markdown-to-pdf: DOM content written to %s" file-path))
        (error
         (message "markdown-to-pdf: error writing DOM to %s: %S" file-path err))))
    (when (and (boundp 'imp--xwidget-pending-save-file) imp--xwidget-pending-save-file)
      (setq imp--xwidget-pending-save-file nil)
      (message "markdown-to-pdf: cleared imp--xwidget-pending-save-file"))))

(defalias 'markdown-to-pdf-xwidget-message-handler
  'markdown-to-pdf--xwidget-dom-handler
  "別名を登録（xwidget 内で呼び出す用）。")

;; ------------------------------
;; DOM取得ショートカット (xwidget用)
;; ------------------------------
(defun markdown-to-pdf-export-dom ()
  "現在表示中の xwidget WebKit から DOM を取得して保存する。
保存先は対話的に選択できる。"
  (interactive)
  (if (not (fboundp 'xwidget-webkit-execute-script))
      (message "markdown-to-pdf: xwidget WebKit 非対応")
    (let* ((xwb-list (markdown-to-pdf--xwidget-get-buffer))
           (buf-name (car xwb-list)))
      (message "markdown-to-pdf: found xwidget buffers=%s" (prin1-to-string xwb-list))
      (if (not buf-name)
          (message "markdown-to-pdf: WebKit バッファが見つかりません")
        (let* ((buf (get-buffer buf-name))
               ;; emacs30 では `xwidget-list` はすでに xwidget オブジェクトのリストであり、
               ;; 各要素自体が xwidget オブジェクトです。ここではバッファ内で見つかった
               ;; 最初の xwidget オブジェクトをそのまま取得して `xwidget-webkit-execute-script`
               ;; に渡します（xwidget-id や xwidget-plist-get 等は使用しない）。
               (xwb (with-current-buffer buf
                      (and (boundp 'xwidget-list) xwidget-list
                           (car xwidget-list)))))
          (message "markdown-to-pdf: selected buffer=%s, xwidget-object=%s" buf-name (if xwb "<object>" "nil"))
          (if (not xwb)
              (message "markdown-to-pdf: WebKit バッファは表示されていません")
            (let ((save-file (read-file-name "Save DOM to file: " nil nil nil "dom.html")))
              (setq imp--xwidget-pending-save-file save-file)
              (message "markdown-to-pdf: pending save-file set to %s" save-file)
              ;; xwidget オブジェクトを直接渡す（emacs30 の xwidget-webkit-execute-script に合わせる）
              (condition-case err
                  (progn
                    (xwidget-webkit-execute-script
                     xwb
                     "if(window._imp_md && document.getElementById('marked')) {
  window.webkit.messageHandlers.impDom.postMessage(
  document.getElementById('marked').innerHTML);
}")
                    (message "markdown-to-pdf: execute-script dispatched to xwidget"))
                (error (message "markdown-to-pdf: error executing script: %S" err))))))))))

;; C-c C-e にバインド
(define-key impatient-mode-map (kbd "C-c C-e") #'markdown-to-pdf-export-dom)

(provide 'markdown-to-pdf)
;;; markdown-to-pdf.el ends here
