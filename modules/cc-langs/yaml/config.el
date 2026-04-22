;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc-langs/yaml/config.el

(when (modulep! :lang yaml)
  (setopt yaml-indent-offset 2)
  (add-to-list 'major-mode-remap-alist '(yaml-mode . yaml-ts-mode))
  (setq-hook! '(yaml-mode-hook yaml-ts-mode-hook)
    tab-width 2)
  (add-hook! '(yaml-mode-hook yaml-ts-mode-hook)
    (spell-fu-mode -1)))

(when (modulep! :lang yaml)
  (use-package! yaml-pro
    :when (modulep! :lang yaml)
    :defer t
    :init
    (add-hook! '(yaml-mode-hook yaml-ts-mode-hook)
      #'yaml-pro-ts-mode)
    :config
    (when (modulep! :lang yaml +lsp)
      (add-hook 'yaml-ts-mode-local-vars-hook #'lsp! 'append))))
