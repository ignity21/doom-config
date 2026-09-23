;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/notes/packages.el

(package! anki-editor)

(package! toc-org)

(package! org-download
  :recipe (:host github
            :repo "abo-abo/org-download"
            :files ("*.el" "Makeifle")))

;; Personal fork adding a search button (Fuse.js over the node data
;; org-roam-ui already gets over the websocket, so it stays in sync with no
;; separate index-generation step -- see the `search' branch history for
;; why: upstream has no search feature, and the forks that add one either
;; never open the live websocket or index a static, hand-generated file).
(when (modulep! :lang org +roam)
  (package! org-roam-ui
    :recipe (:host github
              :repo "ignity21/org-roam-ui"
              :branch "search"
              :files ("*.el" "out"))
    :pin "0976ef5f84ade1b9a1fdd526ec18574023506c8e"))

;; `org-noter' itself is provided by Doom's :lang org +noter flag.  These are
;; its optional document-reader integrations and should not be installed when
;; that workflow is disabled.
(when (modulep! :lang org +noter)
  (package! nov)
  (package! djvu))
