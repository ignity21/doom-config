;;; test/test-notes.el --- tests for cc/notes pure helpers -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(load (expand-file-name "test-helper" (file-name-directory (or load-file-name buffer-file-name))))

(cc/test-load "modules/cc/notes/init.el")
(cc/test-load "modules/cc/notes/autoload.el")

;;; cc/notes--derive-directories

(ert-deftest cc/notes-derive-adds-trailing-slash ()
  (pcase-let ((`(,roam ,_pdf ,_dailies)
               (cc/notes--derive-directories "/home/x/notes")))
    (should (equal roam "/home/x/notes/"))))

(ert-deftest cc/notes-derive-pdf-is-sibling ()
  (pcase-let ((`(,_roam ,pdf ,_dailies)
               (cc/notes--derive-directories "/home/x/notes/")))
    (should (equal pdf "/home/x/pdfnotes/"))))

(ert-deftest cc/notes-derive-dailies-inside-root ()
  (pcase-let ((`(,roam ,_pdf ,dailies)
               (cc/notes--derive-directories "/home/x/notes/")))
    (should (string-prefix-p roam dailies))
    (should (equal dailies "/home/x/notes/dailies/"))))

(ert-deftest cc/notes-derive-expands-tilde ()
  (pcase-let ((`(,roam ,_pdf ,_dailies)
               (cc/notes--derive-directories "~/notes/")))
    (should (equal roam (file-name-as-directory (expand-file-name "~/notes/"))))))

(ert-deftest cc/notes--set-root-refreshes-derived ()
  (cc/notes--set-root 'cc/notes-root-dir "/tmp/n/")
  (should (equal cc/roam-notes-dir "/tmp/n/"))
  (should (equal cc/org-pdf-notes-dir "/tmp/pdfnotes/"))
  (should (equal cc/roam-dailies-dir "/tmp/n/dailies/")))

;;; org-roam category directory logic

(defun cc/test--make-roam-tree ()
  "Create a temp roam root with a few category and non-category dirs."
  (let ((root (file-name-as-directory (make-temp-file "cc-roam" t))))
    (dolist (d '("Inbox" "Projects" ".cache" "dailies" "assets"))
      (make-directory (expand-file-name d root)))
    (with-temp-file (expand-file-name "Inbox/note.org" root) (insert "x"))
    root))

(ert-deftest cc/org-roam-category-directories-filters-non-categories ()
  (let* ((cc/roam-notes-dir (cc/test--make-roam-tree))
         (cc/org-roam-non-category-directories
          '(".cache" "assets" "dailies" "logseq" "pages"))
         (got (sort (cc/org-roam-category-directories) #'string<)))
    (unwind-protect
        (should (equal got '("Inbox" "Projects")))
      (delete-directory cc/roam-notes-dir t))))

(ert-deftest cc/org-roam-category-directories-nil-when-root-absent ()
  (let ((cc/roam-notes-dir "/no/such/roam/root/"))
    (should (null (cc/org-roam-category-directories)))))

(ert-deftest cc/org-roam-category-directory-rejects-bad-names ()
  (let ((cc/roam-notes-dir (cc/test--make-roam-tree))
        (cc/org-roam-non-category-directories '(".cache")))
    (unwind-protect
        (progn
          (should-error (cc/org-roam-category-directory ""))
          (should-error (cc/org-roam-category-directory ".cache"))
          (should-error (cc/org-roam-category-directory "a/b")))
      (delete-directory cc/roam-notes-dir t))))

(ert-deftest cc/org-roam-category-directory-creates-new ()
  (let ((cc/roam-notes-dir (cc/test--make-roam-tree))
        (cc/org-roam-non-category-directories '(".cache")))
    (unwind-protect
        (let ((dir (cc/org-roam-category-directory "Fresh")))
          (should (file-directory-p dir))
          (should (equal dir (expand-file-name "Fresh" cc/roam-notes-dir))))
      (delete-directory cc/roam-notes-dir t))))

;;; test-notes.el ends here
