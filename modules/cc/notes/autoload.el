;;; -*- lexical-binding: t; no-byte-compile: t; ---
;;; cc/notes/autoload.el

;;;###autoload
(defun cc/open-pdf-note-files ()
  "Open all PDF note files in `cc/org-pdf-notes-dir'."
  (interactive)
  (let ((default-directory cc/org-pdf-notes-dir))
    (call-interactively 'find-file)))

;;;###autoload
(defun cc/org-roam-choose-dir ()
  "Choose a directory to use as the org-roam directory."
  (interactive)
  (let ((chosen-dir
         (completing-read "Choose directory: "
                          (directory-files cc/roam-notes-dir nil "^[A-Z]"))))
    (setopt org-roam-directory
            (expand-file-name chosen-dir cc/roam-notes-dir)
            org-roam-db-location
            (expand-file-name ".cache/org-roam.db" org-roam-directory))
    (unless (file-exists-p org-roam-db-location)
      (org-roam-db-sync)
      )))

;;;###autoload
(defun cc/org-roam-choose-dir-if-not-set ()
  "Choose a directory to use as the org-roam directory if not set."
  (interactive)
  ;; org roam db file exists
  (unless (file-exists-p org-roam-db-location)
    (cc/org-roam-choose-dir)))

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
