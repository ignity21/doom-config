;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc-langs/web/config.el

(when (modulep! :lang web)
  (setq-hook! 'css-mode-hook
    css-indent-offset 2)

  (after! eglot
    (add-to-list
      'eglot-server-programs
      '(web-mode . ("vscode-html-language-server" "--stdio")))))
