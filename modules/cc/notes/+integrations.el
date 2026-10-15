;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/notes/+integrations.el
;;;
;;; Optional packages that extend Org-mode: Anki, downloads, and diagrams.

(when (modulep! :lang plantuml)
  (setopt plantuml-default-exec-mode 'executable
          plantuml-indent-level 4))

(use-package! anki-editor
  :commands (anki-editor-push-notes
              anki-editor-insert-note)
  :config
  (setopt anki-editor-create-decks t
          anki-editor-org-tags-as-anki-tags t
          anki-editor-use-math-jax t
          ;; Avoid [latex] image markup, which needs a separate generator.
          anki-editor-latex-style 'mathjax)
  :init
  (map! :map org-mode-map
    :prefix ("C-c n k" . "<anki>")
    :desc "Push cards" "p" #'anki-editor-push-notes
    :desc "Cloze dwim" "c" #'anki-editor-cloze-dwim
    :desc "Cloze region" "r" #'anki-editor-cloze-region
    :desc "Insert card" "i" #'anki-editor-insert-note
    :desc "Clear cloze" "0" #'anki-editor-clear-cloze))

(use-package! org-download
  :commands (org-download-screenshot
              org-download-clipboard
              org-download-delete
              org-download-rename-at-point)
  :config
  (setopt org-download-image-dir "images/screenshots/"
          org-download-heading-lvl 1
          org-download-annotate-function (lambda (_link) "")))
