;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/langs/web.el

(after! eglot
  (add-to-list
    'eglot-server-programs
    '(web-mode . ("vscode-html-language-server" "--stdio"))))
