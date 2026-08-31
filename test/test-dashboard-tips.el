;;; test-dashboard-tips.el --- tests for dashboard tips -*- lexical-binding: t; -*-

(require 'ert)
(load (expand-file-name "test-helper" (file-name-directory (or load-file-name buffer-file-name))))

(setq doom-user-dir cc/test-root)
(cc/test-load "config.d/dashboard-tips.el")

(ert-deftest cc/dashboard-tips-load-data-only ()
  (let ((cc/dashboard--tips nil)
        (cc/dashboard-tips-file
         (expand-file-name "data/dashboard-tips.eld" cc/test-root)))
    (should (listp (cc/dashboard--load-tips)))
    (should (plist-get (car cc/dashboard--tips) :text))))

(ert-deftest cc/dashboard-tips-selection-is-stable-for-a-day ()
  (let ((tips '((:id first :weight 1) (:id second :weight 3))))
    (should (equal (cc/dashboard--choose-tip tips "2026-08-31")
                   (cc/dashboard--choose-tip tips "2026-08-31")))))

(ert-deftest cc/dashboard-tips-selection-respects-positive-weight ()
  (should (eq (plist-get (cc/dashboard--choose-tip
                          '((:id ignored :weight 0) (:id kept :weight 1))
                          "2026-08-31")
                         :id)
              'kept)))

;;; test-dashboard-tips.el ends here
