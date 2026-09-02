;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc-langs/web/doctor.el

;; Eglot does not auto-install language servers.  `:lang web +lsp' drives
;; `web-mode' (HTML, via the entry added in this module's config.el),
;; `css-mode', and the JS/TS modes.
(when (and (modulep! :lang web)
           (modulep! :tools lsp +eglot))
  (unless (executable-find "vscode-html-language-server")
    (warn! "Couldn't find `vscode-html-language-server' (vscode-langservers-extracted). HTML LSP will not work."))
  (unless (executable-find "vscode-css-language-server")
    (warn! "Couldn't find `vscode-css-language-server' (vscode-langservers-extracted). CSS/SCSS LSP will not work."))
  (unless (executable-find "typescript-language-server")
    (warn! "Couldn't find `typescript-language-server'. JavaScript/TypeScript LSP will not work.")))
