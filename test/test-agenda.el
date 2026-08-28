;;; test/test-agenda.el --- tests for cc/agenda pure helpers -*- lexical-binding: t; -*-

(require 'ert)
(load (expand-file-name "test-helper" (file-name-directory (or load-file-name buffer-file-name))))

(defvar org-directory)

(cc/test-load "modules/cc/agenda/autoload.el")
(cc/test-load "modules/cc/agenda/init.el")

(ert-deftest cc/org-clock-in-switch-todo->strt ()
  (should (equal (cc/org-clock-in-switch-state "TODO") "STRT")))

(ert-deftest cc/org-clock-in-switch-checkbox ()
  (should (equal (cc/org-clock-in-switch-state "[ ]") "[-]")))

(ert-deftest cc/org-clock-in-switch-other-unchanged ()
  (should (equal (cc/org-clock-in-switch-state "WAIT") "WAIT"))
  (should (equal (cc/org-clock-in-switch-state nil) nil)))

;;; cc/default-org-dir setter

(ert-deftest cc/default-org-dir-setter-updates-org-directory ()
  (let ((org-directory nil))
    (cc/agenda--set-org-dir 'cc/default-org-dir "/tmp/orgtest/")
    (should (equal cc/default-org-dir "/tmp/orgtest/"))
    (should (equal org-directory (expand-file-name "/tmp/orgtest/")))))

;;; test-agenda.el ends here
