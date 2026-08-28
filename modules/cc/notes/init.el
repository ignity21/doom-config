;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/notes/init.el

;; Derived from `cc/notes-root-dir'; ordinary state, not user options.  They
;; are populated by `cc/notes--set-root' (the `:set' function below), which
;; runs at definition time and again when custom-vars.el `setopt's the root.
(defvar cc/roam-notes-dir nil
  "Absolute path of the org-roam library root.")
(defvar cc/org-pdf-notes-dir nil
  "Directory holding PDF note files (sibling of the roam root).")
(defvar cc/roam-dailies-dir nil
  "Directory holding org-roam dailies, kept inside the roam root.")

(defun cc/notes--derive-directories (root)
  "Return (ROAM PDF DAILIES) directories derived from notes ROOT."
  (let* ((roam (file-name-as-directory (expand-file-name root)))
         (parent (file-name-directory (directory-file-name roam))))
    (list roam
          (expand-file-name "pdfnotes/" parent)
          (expand-file-name "dailies/" roam))))

(defun cc/notes--set-root (symbol value)
  "Setter for `cc/notes-root-dir': refresh the derived note directories."
  (set-default-toplevel-value symbol value)
  (pcase-let ((`(,roam ,pdf ,dailies) (cc/notes--derive-directories value)))
    (setq cc/roam-notes-dir roam
          cc/org-pdf-notes-dir pdf
          cc/roam-dailies-dir dailies)))

(defcustom cc/notes-root-dir "~/notes/"
  "Root directory of the org-roam library."
  :group 'cc-note
  :type 'directory
  :set #'cc/notes--set-root)

;; These variables are consumed while org-roam is initialized.  They must live
;; in init.el: a module's autoload.el provides function autoloads, but is not
;; guaranteed to have been evaluated when `after! org-roam' runs.
(defcustom cc/org-roam-non-category-directories
  '(".cache" "assets" "dailies" "logseq" "pages")
  "Directories under `cc/roam-notes-dir' that are not note categories."
  :group 'cc-note
  :type '(repeat string))

(defcustom cc/org-roam-default-category "Inbox"
  "Category used when a node is created from `cc/org-roam-node-find'."
  :group 'cc-note
  :type 'string)
