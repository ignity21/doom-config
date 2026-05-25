;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/org.el

;; org-directory must be set before doom-package:org has loaded
;; set if cc/org-home-dir is bound
(when (boundp 'cc/default-org-dir)
  (setq org-directory cc/default-org-dir))

(when (boundp 'cc/notes-root-dir)
  (setopt cc/roam-notes-dir (concat cc/notes-root-dir "roamnotes/")
    cc/org-pdf-notes-dir (concat cc/notes-root-dir "pdfnotes/")
    cc/roam-dailies-dir (concat cc/notes-root-dir "dailies/")))
