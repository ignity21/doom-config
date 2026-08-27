;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/langs/python.el

(defcustom cc/python-lsp-backend 'tyruff
  "Python LSP backend.

Possible values are:
- `basedruff': BasedPyright + Ruff
- `tyruff': Ty + Ruff
- `basedpyright': BasedPyright only
- `ty': Ty only

To override this setting for a project, add this to `.dir-locals.el':

  ((nil
    . ((cc/python-lsp-backend . tyruff))))"
  :type '(choice
           (const :tag "BasedPyright + Ruff" basedruff)
           (const :tag "Ty + Ruff" tyruff)
           (const :tag "BasedPyright only" basedpyright)
           (const :tag "Ty only" ty))
  :group 'cc-python)

(put 'cc/python-lsp-backend 'safe-local-variable
  (lambda (value)
    (memq value '(basedruff tyruff basedpyright ty))))

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

(defun cc/python-setup ()
  "Configure Python tooling for the current buffer."
  (setq-local +format-with '(ruff-isort ruff))
  (when (modulep! :tools lsp -eglot)
    (setq-local lsp-enabled-clients
      (pcase cc/python-lsp-backend
        ('basedruff    '(pyright ruff))
        ('tyruff       '(ty-ls ruff))
        ('basedpyright '(pyright))
        ('ty           '(ty-ls))))))

(add-hook 'python-base-mode-hook #'cc/python-setup)

(map! :map python-base-mode-map
  :desc "Disassemble region/buffer" "C-c c d"
  #'cc/python-dis-region-or-buffer)

(when (modulep! :tools lsp -eglot)
  (after! lsp-mode
    (setopt lsp-pyright-langserver-command "basedpyright"
      lsp-pyright-disable-organize-imports t
      lsp-ruff-advertize-fix-all nil)))

(after! eglot
  (add-to-list
    'eglot-server-programs
    `((python-mode python-ts-mode)
       . ,(lambda (_interactive _project)
            (pcase cc/python-lsp-backend
              ('basedruff    '("rass" "basedruff"))
              ('tyruff       '("rass" "python"))
              ('basedpyright '("basedpyright-langserver" "--stdio"))
              ('ty           '("ty" "server")))))))
