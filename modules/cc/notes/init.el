;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/notes/init.el

;;; Core note-library paths

;; Derived from `cc/notes-root-dir'; ordinary state, not user options.  They
;; are populated by `cc/notes--set-root' (the `:set' function below), which
;; runs at definition time and again when custom-vars.el `setopt's the root.
(defvar cc/roam-notes-dir nil
  "Absolute path of the org-roam library root.")

(defun cc/notes--set-root (symbol value)
  "Setter for `cc/notes-root-dir': refresh the derived library directory."
  (set-default-toplevel-value symbol value)
  (setq cc/roam-notes-dir
    (file-name-as-directory (expand-file-name value))))

(defcustom cc/notes-root-dir "~/notes/"
  "Root directory of the org-roam library."
  :group 'cc-note
  :type 'directory
  :set #'cc/notes--set-root)

;;; Org-roam organization

;; These variables are consumed while org-roam is initialized.  They must live
;; in init.el: a module's autoload.el provides function autoloads, but is not
;; guaranteed to have been evaluated when `after! org-roam' runs.
(defcustom cc/org-roam-non-category-directories
  '(".cache" "assets")
  "Directories under `cc/roam-notes-dir' that are not note categories."
  :group 'cc-note
  :type '(repeat string))

(defcustom cc/org-roam-default-category "Unsorted"
  "Category used when a node is created from `cc/org-roam-node-find'."
  :group 'cc-note
  :type 'string)
