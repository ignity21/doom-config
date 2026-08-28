;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/agenda/init.el

;; User options for the :cc agenda module.  `modules/README.org' requires a
;; module's user options to be defined in its init.el.  `org-directory' must
;; be set before Org loads, so `cc/default-org-dir' drives it from a `:set'
;; function -- this runs both at definition time (default value) and when
;; custom-vars.el later `setopt's it, always before Org is actually used.

(defun cc/agenda--set-org-dir (symbol value)
  "Setter for `cc/default-org-dir': also point `org-directory' at VALUE."
  (set-default-toplevel-value symbol value)
  (setq org-directory (expand-file-name value)))

(defcustom cc/default-org-dir "~/org/"
  "Base directory for Org files.  Sets `org-directory'."
  :group 'cc-agenda
  :type 'directory
  :set #'cc/agenda--set-org-dir)

(defcustom cc/org-agenda-dir "~/org/todos/"
  "Directory holding the agenda / todo Org files.
The per-purpose files below are derived from this in `after! org'."
  :group 'cc-agenda
  :type 'directory)

;; Derived from `cc/org-agenda-dir' in `after! org' (see config.el); plain
;; state, not user options.
(defvar cc/agenda-habits-file nil
  "File path for habit entries.")
(defvar cc/agenda-projects-file nil
  "File path for personal project entries.")
(defvar cc/agenda-work-file nil
  "File path for work project entries.")
(defvar cc/agenda-study-file nil
  "File path for study task entries.")
