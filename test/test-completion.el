;;; test/test-completion.el --- tests for cc/completion pure helpers -*- lexical-binding: t; -*-

(require 'ert)
(load (expand-file-name "test-helper" (file-name-directory (or load-file-name buffer-file-name))))

(cc/test-load "modules/cc/completion/config.el")

(ert-deftest cc/minuet-only-on-change-blocks-when-unchanged ()
  (with-temp-buffer
    (insert "hello")
    ;; First call records the current tick and allows.
    (should (null (cc/minuet-only-on-change-p)))
    ;; No edit since -> blocked.
    (should (eq t (cc/minuet-only-on-change-p)))))

(ert-deftest cc/minuet-only-on-change-allows-after-edit ()
  (with-temp-buffer
    (insert "hello")
    (should (null (cc/minuet-only-on-change-p)))
    (insert " world")
    (should (null (cc/minuet-only-on-change-p)))))

;;; test-completion.el ends here
