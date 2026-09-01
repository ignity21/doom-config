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
(defun cc/org-roam-capture-in-default-category ()
  "Capture an org-roam node, creating the default category if needed."
  (interactive)
  (cc/org-roam-default-category-directory)
  (org-roam-capture))

;; A downloaded image is normally linked relative to its note, for example
;; `images/screenshots/Heading/20260101-image.png'.  Keep that relative layout
;; when a note changes category so its links need no rewriting.
(defun cc/org-roam--file-link-targets (file)
  "Return absolute local targets of all `file:' links in FILE."
  (require 'org-element)
  (with-temp-buffer
    (insert-file-contents file)
    (delay-mode-hooks (org-mode))
    (let ((default-directory (file-name-directory file)))
      (delete-dups
       (org-element-map (org-element-parse-buffer) 'link
         (lambda (link)
           (when (string-equal (org-element-property :type link) "file")
             (when-let* ((path (org-element-property :path link)))
               (expand-file-name (org-link-unescape path))))))))))

(defun cc/org-roam--linked-resource-files (file)
  "Return local non-Org files linked relative to FILE's directory."
  (let ((directory (file-name-directory file)))
    (seq-filter
     (lambda (target)
       (and (file-regular-p target)
            (not (file-symlink-p target))
            (file-in-directory-p target directory)
            (not (string-equal (downcase (or (file-name-extension target) ""))
                               "org"))))
     (cc/org-roam--file-link-targets file))))

(defun cc/org-roam--resource-shared-p (resource source source-directory)
  "Return non-nil when RESOURCE is linked by another Org file in SOURCE-DIRECTORY."
  (seq-some
   (lambda (other-file)
     (and (not (equal other-file source))
          (member resource (cc/org-roam--file-link-targets other-file))))
   (directory-files-recursively source-directory "\\.org\\'")))

(defun cc/org-roam--same-file-contents-p (first second)
  "Return non-nil when regular files FIRST and SECOND have identical contents."
  (and (= (file-attribute-size (file-attributes first))
          (file-attribute-size (file-attributes second)))
       (string-equal (secure-hash 'sha256 first)
                     (secure-hash 'sha256 second))))

(defun cc/org-roam--delete-empty-resource-directories (resources stop-directory)
  "Delete empty parents of RESOURCES without deleting STOP-DIRECTORY itself."
  (dolist (resource resources)
    (let ((directory (file-name-directory resource)))
      (while (and (file-in-directory-p directory stop-directory)
                  (not (equal (directory-file-name directory)
                              (directory-file-name stop-directory)))
                  (null (directory-files directory nil
                                         directory-files-no-dot-files-regexp)))
        (delete-directory directory)
        (setq directory (file-name-directory (directory-file-name directory)))))))

;;;###autoload
(defun cc/org-roam-move-current-node ()
  "Move the current org-roam file and its linked resources to a category.

Relative non-Org `file:' links below the note's directory keep their paths.
Resources linked by another note in that directory are copied instead of moved.
Org attachments use stable IDs and are deliberately left in place."
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
                                     target-directory))
           (source-directory (file-name-directory source))
           (resources (cc/org-roam--linked-resource-files source))
           (resource-plan
            (mapcar
             (lambda (resource)
               (let ((destination
                      (expand-file-name (file-relative-name resource source-directory)
                                        target-directory)))
                 (list resource destination
                       (if (cc/org-roam--resource-shared-p
                            resource source source-directory)
                           'copy
                         'move))))
             resources)))
      (when (equal source target)
        (user-error "Node is already in %s" category))
      (when (file-exists-p target)
        (user-error "A note named %s already exists in %s"
                    (file-name-nondirectory source) category))
      (dolist (entry resource-plan)
        (pcase-let ((`(,resource ,destination ,_) entry))
          (when (file-exists-p destination)
            (unless (cc/org-roam--same-file-contents-p resource destination)
              (user-error "Resource collision at %s" destination))
            (setcar (cddr entry) 'reuse))))
      (save-buffer)
      (let (moved-resources copied-resources note-moved)
        (condition-case err
            (progn
              (dolist (entry resource-plan)
                (pcase-let ((`(,resource ,destination ,action) entry))
                  (unless (eq action 'reuse)
                    (make-directory (file-name-directory destination) t)
                    (pcase action
                      ('copy
                       (copy-file resource destination)
                       (push entry copied-resources))
                      ('move
                       (rename-file resource destination)
                       (push entry moved-resources))))))
              (rename-file source target)
              (setq note-moved t)
              (set-visited-file-name target t)
              (set-buffer-modified-p nil)
              (cc/org-roam--delete-empty-resource-directories
               (mapcar #'car moved-resources) source-directory)
              (org-roam-db-sync)
              (message "Moved %s to %s%s"
                       (file-name-nondirectory source) category
                       (if resources
                           (format "; transferred %d linked resource%s"
                                   (length resources)
                                   (if (= (length resources) 1) "" "s"))
                         "")))
          (error
           (when note-moved
             (rename-file target source t)
             (set-visited-file-name source t)
             (set-buffer-modified-p nil))
           (dolist (entry moved-resources)
             (pcase-let ((`(,resource ,destination ,_) entry))
               (when (file-exists-p destination)
                 (rename-file destination resource t))))
           (dolist (entry copied-resources)
             (pcase-let ((`(,_ ,destination ,_) entry))
               (when (file-exists-p destination)
                 (delete-file destination))))
           (signal (car err) (cdr err))))))))

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
