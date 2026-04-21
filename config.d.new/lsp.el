;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/lsp.el

(when (modulep! :tools lsp +lsp)
  (setopt
    lsp-inlay-hint-enable t
    lsp-log-io nil
    lsp-keymap-prefix "C-c ;"
    lsp-format-buffer-on-save t
    lsp-auto-guess-root t
    lsp-keep-workspace-alive nil
    ;; UI settings
    lsp-headerline-breadcrumb-enable nil
    lsp-ui-doc-enable nil
    lsp-ui-sideline-enable t
    lsp-ui-sideline-delay 2
    lsp-modeline-diagnostics-enable t
    lsp-enable-on-type-formatting nil
    ))
