;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/langs/python.el

(defcustom cc/python-use-ty-p nil
  "Whether to use ty-ls as the default LSP client for Python."
  :type 'boolean
  :group 'cc-python)

(defun cc/python-dis-region-or-buffer ()
  "Disassemble the Python code in the current region or buffer and show it in a temp buffer."
  (interactive)
  (let* ((start (if (region-active-p) (region-beginning) (point-min)))
          (end   (if (region-active-p) (region-end)       (point-max)))
          (code      (buffer-substring-no-properties start end))
          (temp-file (make-temp-file "python-dis-" nil ".py"))
          (buffer    (get-buffer-create "*Python Disassembly*")))
    (unwind-protect
      (progn
        (with-temp-file temp-file
          (insert code))
        (with-current-buffer buffer
          (special-mode)
          (let ((inhibit-read-only t))
            (erase-buffer)
            (call-process "python3" nil buffer nil "-m" "dis" temp-file)
            (goto-char (point-min))))
        (+popup-buffer buffer '((side . right) (window-width . 0.4))))
      (when (file-exists-p temp-file)
        (delete-file temp-file)))))

(add-hook 'python-base-mode-hook
  (defun cc/python-setup-lsp-clients ()
    (setq-local +format-with '(ruff-isort ruff))
    (setq-local lsp-enabled-clients (if cc/python-use-ty-p
                                      '(ty-ls ruff)
                                      '(pyright ruff)))))

(after! lsp-mode
  ;; enable basedpyright+ruff by default
  ;; lsp client choices: pyright, ruff, ty-ls
  ;; add ((python-base-mode . ((lsp-enabled-clients . (ty-ls ruff))))) in .dir-locals.el
  ;; to change the default lsp clients

  (setopt lsp-pyright-langserver-command "basedpyright"
    lsp-pyright-disable-organize-imports t
    lsp-ruff-advertize-fix-all nil
    )
  ;; (advice-add 'lsp-format-buffer :before #'lsp-organize-imports)
  )

(after! eglot
  (add-to-list 'eglot-server-programs
    '(python-base-mode . ("basedpyright-langserver" "--stdio"))))

;; (after! python
;;   (setopt python-shell-interpreter "python3"
;;           python-indent-offset 4))

;; (map! :map python-base-mode-map
;;       "C-c <TAB> a" nil ; python-add-import
;;       "C-c <TAB> s" nil
;;       "C-c <TAB> f" nil
;;       "C-c <TAB> r" nil
;;       :desc "Disassemble region/buffer" "C-c c d"
;;       #'cc/python-dis-region-or-buffer
;;       )
