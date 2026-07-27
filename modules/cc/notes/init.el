;;; -*- lexical-binding: t; no-byte-compile: t; ---
;;; cc/notes/init.el

(defcustom cc/notes-root-dir "~/notes/"
  "Root directory of the org-roam library."
  :group 'cc-note
  :type 'directory)

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
