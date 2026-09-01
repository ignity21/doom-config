;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/notes/packages.el

(package! anki-editor)

(package! toc-org)

(package! org-download
  :recipe (:host github
            :repo "abo-abo/org-download"
            :files ("*.el" "Makeifle")))

(when (modulep! :lang org +roam)
  (package! org-roam-ui))

;; `org-noter' itself is provided by Doom's :lang org +noter flag.  These are
;; its optional document-reader integrations and should not be installed when
;; that workflow is disabled.
(when (modulep! :lang org +noter)
  (package! nov)
  (package! djvu))
