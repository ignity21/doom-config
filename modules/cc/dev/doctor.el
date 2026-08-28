;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/dev/doctor.el

;; copilot dependencies
(unless (modulep! :tools editorconfig)
  (error! "copilot.el requires the :editor editorconfig module"))

(unless (require 'jsonrpc nil t)
  (error! "copilot.el requires the jsonrpc package"))

;; Eglot language servers for modules that have no private cc-langs module of
;; their own.  Eglot does not auto-install servers, so warn when they're
;; missing.  (Languages with a private module check their own servers in
;; modules/cc-langs/<lang>/doctor.el.)
(when (and (modulep! :lang sh) (modulep! :tools lsp +eglot))
  (unless (executable-find "bash-language-server")
    (warn! "Couldn't find `bash-language-server'. Shell script LSP will not work.")))

(when (and (modulep! :lang markdown) (modulep! :tools lsp +eglot))
  (unless (executable-find "marksman")
    (warn! "Couldn't find `marksman'. Markdown LSP will not work.")))

(when (and (modulep! :lang json) (modulep! :tools lsp +eglot))
  (unless (executable-find "vscode-json-language-server")
    (warn! "Couldn't find `vscode-json-language-server' (vscode-langservers-extracted). JSON LSP will not work.")))

(when (and (modulep! :tools docker) (modulep! :tools lsp +eglot))
  (unless (executable-find "docker-langserver")
    (warn! "Couldn't find `docker-langserver' (dockerfile-language-server). Dockerfile LSP will not work.")))
