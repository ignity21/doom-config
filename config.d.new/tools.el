;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/tools.el

;; Doom's Docker module starts LSP for `dockerfile-mode`, but +tree-sitter
;; remaps Dockerfiles to `dockerfile-ts-mode`.  Start the same LSP dispatcher
;; for the active tree-sitter mode.
(when (modulep! :tools docker +lsp)
  (add-hook 'dockerfile-ts-mode-hook #'lsp!))
