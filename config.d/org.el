;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/org.el

;; org-directory must be set before doom-package:org has loaded
;; set if cc/org-home-dir is bound
(when (boundp 'cc/default-org-dir)
  (setq org-directory cc/default-org-dir))

(when (boundp 'cc/notes-root-dir)
  ;; `cc/notes-root-dir' is the org-roam library root, not a parent directory.
  (let ((notes-parent (file-name-directory
                       (directory-file-name cc/notes-root-dir))))
    (setopt cc/roam-notes-dir cc/notes-root-dir
      cc/org-pdf-notes-dir (expand-file-name "pdfnotes/" notes-parent)
      ;; Keep dailies under the roam root so one database indexes the whole graph.
      cc/roam-dailies-dir (expand-file-name "dailies/" cc/notes-root-dir))))
