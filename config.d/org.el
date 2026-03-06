;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/org.el

;; org-directory must be set before doom-package:org has loaded
;; set if cc/org-home-dir is bound
(when (boundp 'cc/default-org-dir)
  (setq org-directory cc/default-org-dir))

(when (boundp 'cc/notes-base-dir)
  (setopt cc/roam-notes-dir (concat cc/notes-base-dir "roamnotes/")
          cc/org-pdf-notes-dir (concat cc/notes-base-dir "pdfnotes/")
          cc/roam-journals-dir (concat cc/notes-base-dir "journals/")))
