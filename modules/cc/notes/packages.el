;;; -*- lexical-binding: t; no-byte-compile: t; ---
;;; cc/notes/packages.el

(package! anki-editor)

;; FIXME Wait for PR merge https://github.com/abo-abo/org-download/pull/220
(package! org-download
  :recipe (:host github
            :repo "abo-abo/org-download"
            :files ("*.el" "Makeifle"))
  :pin "900b7b6984d8fcfebbd3620152730228ce6468aa")

(when (modulep! :lang org +roam)
  (package! org-roam-ui))
