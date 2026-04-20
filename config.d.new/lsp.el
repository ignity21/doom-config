;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/lsp.el

(when (modulep! :tools lsp +lsp)
  (setopt
   lsp-inlay-hint-enable t
   lsp-keymap-prefix "C-c ;"
   lsp-format-buffer-on-save t))
