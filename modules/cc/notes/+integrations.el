;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/notes/+integrations.el
;;;
;;; Optional packages that extend Org-mode: Anki, downloads, diagrams, and
;;; PDF annotation.

(when (modulep! :lang plantuml)
  (setopt plantuml-default-exec-mode 'executable
          plantuml-indent-level 4))

(use-package! anki-editor
  :commands (anki-editor-push-notes
              anki-editor-insert-note)
  :config
  (setopt anki-editor-create-decks t
          anki-editor-org-tags-as-anki-tags t
          anki-editor-use-math-jax t)
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

;; Keep the PDF workflow available without loading any of it unless the Doom
;; Org module explicitly enables +noter.
(when (modulep! :lang org +noter)
  (map! :prefix ("C-c n P" . "<pdfnotes>")
    :desc "Find note files" "f" #'cc/open-pdf-note-files
    :desc "Org noter" "o" #'org-noter)
  (after! org-noter
    (setopt org-noter-notes-search-path `(,cc/org-pdf-notes-dir)
            org-noter-highlight-selected-text t
            org-noter-auto-save-last-location t
            org-noter-max-short-selected-text-length 40)
    (add-hook! 'org-noter-doc-mode-hook
      (setq-local pdf-view-display-size 'fit-width))
    (map! (:map (org-noter-notes-mode-map org-noter-doc-mode-map)
            :prefix "C-c n p"
            :desc "Generate TOC" "t" #'org-noter-create-skeleton
            :desc "Sync next note" "n" #'org-noter-sync-next-note
            :desc "Sync previous note" "p" #'org-noter-sync-prev-note
            :desc "Sync page or chapter" "S"
            #'org-noter-sync-current-page-or-chapter
            :desc "Sync current note" "s" #'org-noter-sync-current-note
            :desc "Exit org noter" "q" #'org-noter-kill-session
            :desc "Set start location" "l" #'org-noter-set-start-location)
      (:map org-noter-doc-mode-map
        :desc "Insert note" "e" #'org-noter-insert-note
        :desc "Insert precise note" "M-e" #'org-noter-insert-precise-note))))
