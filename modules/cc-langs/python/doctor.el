;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc-langs/python/doctor.el

;; Eglot does not auto-install language servers.  Check the binaries the
;; `cc/python-lsp-backend' choices rely on.  (The active backend is a defcustom
;; from $DOOMDIR and is not loaded during `doom doctor', so check all of them.)
(when (and (modulep! :lang python)
           (modulep! :tools lsp +eglot))
  (unless (executable-find "rass")
    (warn! "Couldn't find `rass' (rassumfrassum). The default `tyruff'/`basedruff' Python LSP backends will not work."))
  (unless (or (executable-find "basedpyright-langserver")
              (executable-find "ty"))
    (warn! "Couldn't find `basedpyright-langserver' or `ty'. The `basedpyright'/`ty' Python LSP backends will not work.")))
