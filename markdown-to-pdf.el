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
  (let ((file-path (or (and (boundp 'imp--xwidget-pending-save-file) imp--xwidget-pending-save-file)
                       (read-file-name "Save DOM to file: " nil nil nil "dom.html"))))
    (when (buffer-live-p (current-buffer))
      (with-temp-buffer
        (insert html-content)
        (write-region (point-min) (point-max) file-path)
        (message "markdown-to-pdf: DOM content written to %s" file-path)))
    (when (boundp 'imp--xwidget-pending-save-file)
      (setq imp--xwidget-pending-save-file nil))))

(defalias 'markdown-to-pdf-xwidget-message-handler
  'markdown-to-pdf--xwidget-dom-handler
  "別名を登録（xwidget 内で呼び出す用）。")

(defun markdown-to-pdf-export-dom ()
  "現在表示中の xwidget WebKit から DOM を取得して保存する。
保存先は対話的に選択できる。"
  (interactive)
  (if (fboundp 'xwidget-webkit-execute-script)
      (let* ((xwb-list (markdown-to-pdf--xwidget-get-buffer))
             (buf-name (car xwb-list)))
        (if buf-name
            (let* ((buf (get-buffer buf-name))
                   (xwb (car (with-current-buffer buf
                               (cl-remove-if-not
                                (lambda (x) (eq (car x) 'xwidget-webkit))
                                xwidget-list)))))
              (if xwb
                  (let ((save-file (read-file-name "Save DOM to file: " nil nil nil "dom.html")))
                    (setq imp--xwidget-pending-save-file save-file)
                    (xwidget-webkit-execute-script (cdr xwb)
                                                   "if(window._imp_md && document.getElementById('marked')) {
  window.webkit.messageHandlers.impDom.postMessage(
  document.getElementById('marked').innerHTML);
}"))
                (message "markdown-to-pdf: WebKit バッファは表示されていません")))
          (message "markdown-to-pdf: WebKit バッファが見つかりません")))
    (message "markdown-to-pdf: xwidget WebKit 非対応")))

;; C-c C-e にバインド
(define-key impatient-mode-map (kbd "C-c C-e") #'markdown-to-pdf-export-dom)

;; impatient-mode.el から削除した内容
;; ;; ------------------------------
;; ;; DOM取得ショートカット追加 (xwidget用)
;; ;; ------------------------------
;; ;; 修正版：xwidget DOM 取得ショートカット
;; (when imp--enable-xwidget-webkit--p
;;   ;; C-c C-e で現在の xwidget WebKit 表示 DOM を取得
;;   (let ((map impatient-mode-map))
;;     (define-key map (kbd "C-c C-e")
;;                 (lambda ()
;;                   (interactive)
;;                   (if (fboundp 'xwidget-webkit-execute-script)
;;                       (let* ((xwb-list (imp--xwidget-webkit-buffer))
;;                              (buf-name (car xwb-list)))
;;                         (if buf-name
;;                             (let* ((buf (get-buffer buf-name))
;;                                    ;; バッファ内 xwidget オブジェクトを取得
;;                                    (xwb (car (with-current-buffer buf
;;                                                (cl-remove-if-not
;;                                                 (lambda (x) (eq (car x) 'xwidget-webkit))
;;                                                 xwidget-list)))))
;;                               (if xwb
;;                                   (let ((save-file (read-file-name "Save DOM to file: " nil nil nil "dom.html")))
;;                                     (setq imp--xwidget-pending-save-file save-file)
;;                                     (xwidget-webkit-execute-script (cdr xwb)
;;                                                                    "if(window._imp_md && document.getElementById('marked')) {
;;   window.webkit.messageHandlers.impDom.postMessage(
;;   document.getElementById('marked').innerHTML);
;; }"))
;;                                 (message "impatient-mode: WebKit バッファは表示されていません")))
;;                           (message "impatient-mode: WebKit バッファが見つかりません")))
;;                     (message "impatient-mode: xwidget WebKit 非対応")))))
;;   ;; Emacs 側で JS からの postMessage を受信するハンドラ定義
;;   (defun imp--xwidget-dom-handler (html-content)
;;     "JS 側から送られてきた HTML を受け取り、テンポラリバッファ経由で FILE-PATH に保存する。
;; HTML-CONTENT は文字列、FILE-PATH は保存先のフルパス。"
;;     (interactive "sHTML content: ")
;;     (let ((file-path (or (and (boundp 'imp--xwidget-pending-save-file) imp--xwidget-pending-save-file)
;;                          (read-file-name "Save DOM to file: " nil nil nil "dom.html"))))
;;       (when (buffer-live-p (current-buffer))
;;         (with-temp-buffer
;;           (insert html-content)
;;           (write-region (point-min) (point-max) file-path)
;;           (message "impatient-mode: DOM content written to %s" file-path))
;;       (when (boundp 'imp--xwidget-pending-save-file)
;;         (setq imp--xwidget-pending-save-file nil)))))
;;   ;; ハンドラの別名を登録 (xwidget 内で呼び出す用)
;;   (defalias 'imp-xwidget-message-handler 'imp--xwidget-dom-handler))
;;
(provide 'markdown-to-pdf)
;;; markdown-to-pdf.el ends here
