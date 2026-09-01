;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/notes/+org.el
;;;
;;; Core Org-mode editing, display, completion, and mode-local bindings.

;; TODO: org-format-latex-options
;; TODO: may try +jupyter +pandoc +pretty(latex highlighting)

(after! org
  (require 'org-indent))

(setq-hook! 'org-mode-hook
  completion-at-point-functions
  `(cape-file
     ,(cape-capf-super #'pcomplete-completions-at-point #'yasnippet-capf)
     cape-dabbrev
     t))

(map! :after org
  :map org-mode-map
  :desc "Open link" "C-c o l" #'org-open-at-point
  (:prefix "C-c c"
    (:prefix ("i" . "<insert>")
      :desc "Org insert date" "t" #'org-timestamp-inactive
      :desc "Org insert time" "T" #'org-timestamp
      :desc "Set a tag" "g" #'org-set-tags-command
      :desc "Set property" "p" #'org-set-property
      :desc "Create org-id" "i" #'org-id-get-create
      :desc "Insert link" "l" #'org-insert-link
      :desc "Insert footnote" "f" #'org-footnote-new)
    (:prefix ("d" . "<org-download>")
      :desc "Insert screenshot" "i" #'org-download-screenshot
      :desc "Insert from clipboard" "y" #'org-download-clipboard
      :desc "Rename at point" "r" #'org-download-rename-at-point
      :desc "Delete at point" "d" #'org-download-delete)
    (:prefix ("v" . "<view>")
      :desc "Preview latex fragment" "l" #'org-latex-preview
      :desc "Preview image" "i" #'org-display-inline-images
      :desc "Plot table" "t" #'org-plot/gnuplot)))

(after! org
  (remove-hook 'org-mode-hook #'org-indent-mode)
  (add-hook 'org-mode-hook #'toc-org-mode)
  (setopt org-startup-indented nil
          org-ellipsis " ▼"
          org-appear-autoemphasis nil
          org-pretty-entities t
          org-pretty-entities-include-sub-superscripts nil
          org-highlight-latex-and-related '(native latex entities)
          org-startup-with-inline-images t)
  (dolist (face '((org-level-1 . 1.2)
                   (org-level-2 . 1.1)
                   (org-level-3 . 1.05)))
    (set-face-attribute (car face) nil :weight 'bold :height (cdr face))))
