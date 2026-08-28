;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/notes/autoload.el

;; Declared by org-roam.  Declare it here too because this autoload file is
;; loaded before org-roam, while `cc/org-roam-capture-in-category' dynamically
;; binds it for one capture.
(defvar org-roam-capture-templates)

;;;###autoload
(defun cc/open-pdf-note-files ()
  "Open all PDF note files in `cc/org-pdf-notes-dir'."
  (interactive)
  (let ((default-directory cc/org-pdf-notes-dir))
    (call-interactively 'find-file)))

;;;###autoload
(defun cc/org-roam-default-category-directory ()
  "Create and return the default category directory."
  (let ((directory (expand-file-name cc/org-roam-default-category
                                     cc/roam-notes-dir)))
    (make-directory directory t)
    directory))

;;;###autoload
(defun cc/org-roam-category-directories ()
  "Return immediate note-category directories in the roam root."
  (when (file-directory-p cc/roam-notes-dir)
    (seq-filter
     (lambda (directory)
       (and (file-directory-p (expand-file-name directory cc/roam-notes-dir))
            (not (member directory cc/org-roam-non-category-directories))))
     (directory-files cc/roam-notes-dir nil directory-files-no-dot-files-regexp))))

;;;###autoload
(defun cc/org-roam-read-category ()
  "Prompt for a category directory below `cc/roam-notes-dir'.

An input that does not yet exist creates a new immediate category directory."
  (let ((categories (cc/org-roam-category-directories)))
    (completing-read "Note category (new allowed): " categories nil nil)))

;;;###autoload
(defun cc/org-roam-category-directory (category)
  "Create and return CATEGORY's immediate directory in the roam root."
  (when (or (string-empty-p category)
            (member category cc/org-roam-non-category-directories)
            (string-match-p "[/\\\\]" category))
    (user-error "Category must be a new immediate directory name"))
  (let ((directory (expand-file-name category cc/roam-notes-dir)))
    (make-directory directory t)
    directory))

;;;###autoload
(defun cc/org-roam-capture-in-category ()
  "Create an org-roam node in a selected category.

The node remains in the single database rooted at `cc/roam-notes-dir', so it
can link to and be linked from every other category."
  (interactive)
  (let* ((category (cc/org-roam-read-category))
         (_category-directory (cc/org-roam-category-directory category))
         (org-roam-capture-templates
          `(("c" "category" plain "%?"
             :if-new (file+head
                      ,(concat category "/${slug}-%<%Y%m%d>.org")
                      "#+title: ${title}\n")
             :unnarrowed t))))
    (org-roam-capture)))

;;;###autoload
(defun cc/org-roam-node-find (&optional other-window initial-input filter-fn predicate)
  "Find a node globally; create unmatched nodes in the Inbox category."
  (interactive "P")
  (cc/org-roam-default-category-directory)
  (org-roam-node-find other-window initial-input filter-fn predicate))

;;;###autoload
(defun cc/org-roam-move-current-node ()
  "Move the current org-roam file to a category without changing its ID."
  (interactive)
  (unless buffer-file-name
    (user-error "Current buffer is not visiting a file"))
  (let* ((source (expand-file-name buffer-file-name))
         (root (file-name-as-directory (expand-file-name cc/roam-notes-dir))))
    (unless (string-equal (file-name-extension source) "org")
      (user-error "Current file is not an Org note"))
    (unless (file-in-directory-p source root)
      (user-error "Current file is not in the org-roam library"))
    (let* ((category (cc/org-roam-read-category))
           (target-directory (cc/org-roam-category-directory category))
           (target (expand-file-name (file-name-nondirectory source)
                                     target-directory)))
      (when (equal source target)
        (user-error "Node is already in %s" category))
      (when (file-exists-p target)
        (user-error "A note named %s already exists in %s"
                    (file-name-nondirectory source) category))
      (save-buffer)
      (rename-file source target)
      (set-visited-file-name target t)
      (set-buffer-modified-p nil)
      (org-roam-db-sync)
      (message "Moved %s to %s" (file-name-nondirectory source) category))))

;; ;;;###autoload
;; (defun cc/org-roam-find-by-dir (&rest args)
;;   "Wrapped `org-roam-node-find' that prompts for a directory first."
;;   (interactive)
;;   (cc/org-roam-choose-directory)
;;   (apply #'org-roam-node-find args))


;; ;;;###autoload
;; (defun cc/org-roam-capture-by-dir (&rest args)
;;   "Wrapped `org-roam-capture' that prompts for a directory first."
;;   (interactive)
;;   (cc/org-roam-choose-directory)
;;   (apply #'org-roam-capture args))
