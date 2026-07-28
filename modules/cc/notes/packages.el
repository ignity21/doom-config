;;; -*- lexical-binding: t; no-byte-compile: t; ---
;;; cc/notes/packages.el

(package! anki-editor)

(package! org-download
  :recipe (:host github
            :repo "abo-abo/org-download"
            :files ("*.el" "Makeifle")))

(when (modulep! :lang org +roam)
  (package! org-roam-ui))
