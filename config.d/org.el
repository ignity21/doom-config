;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/org.el
;;
;; TEMPORARY BRIDGE.  Step 5 of .agents/plans/config-d-migration.md sinks this
;; into modules/cc/agenda/init.el (org-directory + cc/default-org-dir defcustom)
;; and modules/cc/notes/init.el (notes-dir derivation via a :set function).
;; Delete this file and its config.el registration once Step 5 lands.

;; org-directory must be set before org loads; guarded by `boundp' because the
;; value lives in custom-vars.el, which may not define it.
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
