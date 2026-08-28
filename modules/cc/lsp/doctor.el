;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/lsp/doctor.el

(assert! (modulep! :tools lsp)
         "The :cc lsp module requires (:tools lsp)")

;; Eglot does not auto-install language servers.  Check the servers for
;; enabled languages that have no private cc-langs module of their own.
;; (Languages with a private module -- python, web -- check their own
;; servers in modules/cc-langs/<lang>/doctor.el.)
(when (modulep! :tools lsp +eglot)
  (when (modulep! :lang sh)
    (unless (executable-find "bash-language-server")
      (warn! "Couldn't find `bash-language-server'. Shell script LSP will not work.")))

  (when (modulep! :lang markdown)
    (unless (executable-find "marksman")
      (warn! "Couldn't find `marksman'. Markdown LSP will not work.")))

  (when (modulep! :lang json)
    (unless (executable-find "vscode-json-language-server")
      (warn! "Couldn't find `vscode-json-language-server' (vscode-langservers-extracted). JSON LSP will not work.")))

  (when (modulep! :tools docker)
    (unless (executable-find "docker-langserver")
      (warn! "Couldn't find `docker-langserver' (dockerfile-language-server). Dockerfile LSP will not work."))))
