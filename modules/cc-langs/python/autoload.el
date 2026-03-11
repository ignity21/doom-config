;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc-langs/python/autoload.el

;;;###autoload
(defun cc/python-set-default-capf ()
  "Set the `completion-at-point-functions' for Python mode."
  (setq-local completion-at-point-functions
              '(yasnippet-capf
                cape-file
                t)))

;;;###autoload
(defun cc/python-set-lsp-capf ()
  "Set the `completion-at-point-functions' for Python mode(with lsp-mode)."
  (when (derived-mode-p 'python-mode)
    (setq-local completion-at-point-functions
                `(,(cape-capf-super #'lsp-completion-at-point #'yasnippet-capf)
                  cape-file
                  python-completion-at-point
                  t))))

;;;###autoload
(defun cc/python-dis-region-or-buffer ()
  "Disassemble the Python code in the current region or buffer and show it in a temp buffer."
  (interactive)
  (let* ((start (if (region-active-p) (region-beginning) (point-min)))
         (end (if (region-active-p) (region-end) (point-max)))
         (code (buffer-substring-no-properties start end))
         (temp-file (make-temp-file "python-dis-" nil ".py"))
         (buffer (get-buffer-create "*Python Disassembly*")))
    (unwind-protect
        (progn
          (with-temp-file temp-file
            (insert code))
          (with-current-buffer buffer
            (erase-buffer)
            (call-process "python3" nil buffer nil "-m" "dis" temp-file)
            (goto-char (point-min))
            (let ((map (make-sparse-keymap)))
              (keymap-set map "q" (lambda ()
                                   (interactive)
                                   (quit-window t)))
              (use-local-map map)))
          (+popup-buffer buffer '((side . right) (window-width . 0.4)))
          (select-window (display-buffer buffer)))
      (when (file-exists-p temp-file)
        (delete-file temp-file)))))
