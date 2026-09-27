;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/notes/packages.el

(package! anki-editor)

(package! toc-org)

(package! org-download
  :recipe (:host github
            :repo "abo-abo/org-download"
            :files ("*.el" "Makeifle")))

;; Personal fork with a search button over the node data org-roam-ui already
;; gets over the websocket (so it stays in sync with no separate index step),
;; plus note-view enhancements: syntax-highlighted src blocks, ruled tables,
;; theme fixes and a full-window note view.  The `enhanced' branch ships the
;; built UI in out/.
(when (modulep! :lang org +roam)
  (package! org-roam-ui
    :recipe (:host github
              :repo "ignity21/org-roam-ui"
              :branch "enhanced"
              :files ("*.el" "out"))
    :pin "78b928e321dc7c310cf7b20083d22bca7b5dcdf6"))

;; `org-noter' itself is provided by Doom's :lang org +noter flag.  These are
;; its optional document-reader integrations and should not be installed when
;; that workflow is disabled.
(when (modulep! :lang org +noter)
  (package! nov)
  (package! djvu))
