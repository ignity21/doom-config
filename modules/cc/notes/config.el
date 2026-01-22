;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; cc/notes/config.el
;; TODO: org-format-latex-options
;; TODO: may try +jupyter +pandoc +pretty(latex highlighting)
;;
;;; Hints:
;;
;; C-c o l -- Open link at point
;; C-c i l -- Insert a link
;; C-x n s, C-x n w -- Narrow/Unnarrow buffer
;; C-c s o -- Search in an outline tree as much as possible
;; C-c - -- Cycle bullets (-, +, *, ...)
;; C-c ; -- Toggle the "COMMENT" keyword
;; ====== Tags ==========
;; C-c C-c -- Set a tag
;; M-x org-agenda m/M -- Match tags (only TODO)
;; ====== Properties ========
;; C-c C-x p -- Set a property
;; ====== Timestamps ========
;; C-c . -- Set a timestamp
;; S-LEFT/S-Right -- Change by one day
;; ====== Footnotes =========
;; C-c l f footnote prefix
;; C-c C-c -- jump between definition and reference
;; +strike-through+

(after! org (require 'org-indent))

(map! :after org
      :map org-mode-map
      ;; non prefix
      "M-S-<return>" #'org-table-copy-down
      "S-<return>" #'org-insert-todo-heading
      :desc "Open link" "C-c o l" #'org-open-at-point
      :desc "Search in outline tree" "C-c s o" #'org-sparse-tree
      ;; C-x n --- narrow
      (:prefix "C-x n"
       :desc "Org narrow to subtree" "n" #'org-narrow-to-subtree
       :desc "Widen" "w" #'widen
       )
      ;; C-c i --- insert
      (:prefix "C-c i"
       :desc "Org insert date" "t" #'org-timestamp-inactive
       :desc "Org insert time" "T" #'org-timestamp
       :desc "Set a tag" "T" #'org-set-tags-command
       :desc "Set property" "p" #'org-set-property
       :desc "Create org-id" "i" #'org-id-get-create
       :desc "Insert link" "l" #'org-insert-link
       :desc "Insert footnote" "f" #'org-footnote-new)

      ;; local prefix l
      (:prefix
       "C-c l"
       (:prefix ("r" . "<roam>")
        :desc "Update org-id-locations" "u" #'org-roam-update-org-id-locations)

       ;; p -- preview/plot
       (:prefix ("p" . "<preview/plot>")
        :desc "Preview latex fragment" "l" #'org-latex-preview
        :desc "Preview image" "i" #'org-display-inline-images
        :desc "Plot table" "" #'org-plot/gnuplot))
      )

(after! org
  (remove-hook 'org-mode-hook #'org-indent-mode)
  (setq! org-startup-indented nil
         ;; TODO org-id-locations cc/org-id-locations
         org-ellipsis " ▼"
         org-appear-autoemphasis nil
         ;; pretty latex preview
         org-pretty-entities t
         org-pretty-entities-include-sub-superscripts nil
         org-highlight-latex-and-related '(native latex entities)

         ;; inline image
         org-startup-with-inline-images t)
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)))
    (set-face-attribute (car face) nil :weight 'bold :height (cdr face))))

;; TODO org-noter
(when (modulep! :lang org +noter)
  (map! :prefix ("C-c n p" . "<pdfnotes>")
        :desc "Find note files" "f" #'cc/open-pdf-note-files
        :desc "Org noter" "o" #'org-noter)
  (after! org-noter
    (setq! org-noter-notes-search-path `(,cc/org-pdf-notes-dir)
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

(when (modulep! :lang plantuml)
  (setq! plantuml-default-exec-mode 'executable
         plantuml-indent-level 4))

(use-package! anki-editor
  ;;:after-call (org-mode-hook)
  :commands (anki-editor-push-notes
             anki-editor-insert-note)
  :config
  (setq! anki-editor-create-decks t
         anki-editor-org-tags-as-anki-tags t
         anki-editor-use-math-jax t)
  :init
  (map! :map org-mode-map
        :prefix ("C-c l a" . "<anki>")
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
  :init
  (map! :map org-mode-map
        :prefix ("C-c l d" . "<org-download>")
        :desc "Insert screenshot" "i" #'org-download-screenshot
        :desc "Insert from clipboard" "y" #'org-download-clipboard
        :desc "Rename at point" "r" #'org-download-rename-at-point
        :desc "Delete at point" "d" #'org-download-delete)
  :config
  (setq! org-download-image-dir "images/screenshots/"
         org-download-heading-lvl 1
         org-download-annotate-function (lambda (_link) "")))

(load! "roam")
