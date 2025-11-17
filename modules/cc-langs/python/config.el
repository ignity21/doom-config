;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc-langs/python/config.el
(when (modulep! :lang python)
  (defvar cc/python-indent-offset 4
    "The number of spaces to indent inside python blocks.")

  ;; (after! pyvenv
  ;;   (add-hook! 'python-base-mode-hook #'pyvenv-tracking-mode))

  (setq-hook! 'python-base-mode-hook
    python-indent-offset cc/python-indent-offset)

  (add-hook! 'python-base-mode-hook
             #'cc/python-set-default-capf
             #'whole-line-or-region-local-mode)
  (add-hook! 'lsp-completion-mode-hook #'cc/python-set-lsp-capf)

  ;; set default python interpreter
  (setq! python-shell-interpreter "python3"
         doom-modeline-env-enable-python nil)

  (when (modulep! :ui indent-guides)
    (add-hook! 'python-base-mode-hook
      (defun configure-indent-guides ()
        (setq-local indent-bars-treesit-support t
                    indent-bars-treesit-wrap
                    '((python argument_list parameters
                       list list_comprehension
                       dictionary dictionary_comprehension
                       parenthesized_expression subscript)
                      (python list_comprehension))
                    indent-bars-treesit-ignore-blank-lines-types '("module")))))

  (map! :map python-base-mode-map
        "C-c <TAB> a" nil ; python-add-import
        "C-c <TAB> s" nil
        "C-c <TAB> f" nil
        "C-c <TAB> r" nil
        :desc "Disassemble region/buffer" "C-c c d"
        #'cc/python-dis-region-or-buffer)

  (use-package! sphinx-doc
    :hook (python-mode . sphinx-doc-mode)
    :config
    (setq! sphinx-doc-include-types nil
           sphinx-doc-python-indent cc/python-indent-offset)
    (map! :map sphinx-doc-mode-map
          :desc "Insert docstring" "C-c i d"
          #'sphinx-doc))

  ;; emacs-pet for virtual environment detection
  (use-package! pet
    :defer t
    :init
    (add-hook! 'python-base-mode-hook
               #'pet-mode
               (defun cc/configure-pet-mode ()
                 ;; lsp-pyright
                 (setq-local
                  lsp-pyright-langserver-command "basedpyright"))
               ;;   ;; ;; dap-python
               ;;   ;; (setq-local dap-python-executable python-shell-interpreter)
               ;;   )
               ))
  )

(when (modulep! :lang python +poetry)
  (setq! poetry-tracking-strategy 'projectile)
  (map! :map python-base-mode-map
        :desc "poetry" "C-c l p" #'poetry))

(when (modulep! :lang python +lsp)
  (after! lsp-ruff
    (setq! lsp-ruff-advertize-fix-all nil
           ;; lsp-ruff-advertize-organize-imports t
           ))
  (after! lsp-pyright
    (setq! lsp-pyright-disable-organize-imports nil
           lsp-pyright-langserver-command "basedpyright"
           lsp-pyright-type-checking-mode "standard"
           lsp-pyright-auto-import-completions t
           lsp-pyright-multi-root nil
           lsp-pyright-basedpyright-inlay-hints-generic-types t
           ))
  (map! :map lsp-mode-map
        :desc "Organize imports" "C-c c o"
        #'lsp-organize-imports)
  ;; (add-hook! 'python-base-mode-hook
  ;;   (add-hook! 'before-save-hook
  ;;     (defun cc/python-lsp-format-buffer ()
  ;;       (when (eq major-mode 'python-base-mode)
  ;;         (lsp-organize-imports)
  ;;         (lsp-format-buffer)))
  ;;     nil 'local))
  )

(when (modulep! :tools debugger)
  (add-hook! 'dap-stopped-hook
    (defun cc/dap-hydra (arg)
      (call-interactively #'dap-hydra)))
  (after! dap-python
    ;; HACK pyvenv-tracking-mode will help find the executable
    (defun dap-python--pyenv-executable-find (command)
      (executable-find command))
    (setq! dap-python-debugger 'debugpy)))
