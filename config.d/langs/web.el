;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/langs/web.el

(setq-hook! 'css-mode-hook
  css-indent-offset 2)

(after! eglot
  (add-to-list
    'eglot-server-programs
    '(web-mode . ("vscode-html-language-server" "--stdio"))))
