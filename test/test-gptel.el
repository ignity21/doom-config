;;; test/test-gptel.el --- tests for cc/ai pure helpers -*- lexical-binding: t; -*-

(require 'ert)
(load (expand-file-name "test-helper" (file-name-directory (or load-file-name buffer-file-name))))

(defvar git-commit-summary-max-length)

(cc/test-load "modules/cc/ai/init.el")
(cc/test-load "modules/cc/ai/+magit.el")
(cc/test-load "modules/cc/ai/config.el")

;;; cc/gptel-magit--truncate-subject

(defmacro cc/test--with-max (n &rest body)
  (declare (indent 1))
  `(let ((git-commit-summary-max-length ,n)) ,@body))

(ert-deftest cc/gptel-truncate-under-limit-untouched ()
  (cc/test--with-max 72
    (should (equal (cc/gptel-magit--truncate-subject "feat: short subject")
                   "feat: short subject"))))

(ert-deftest cc/gptel-truncate-exactly-at-limit-untouched ()
  (let ((s (make-string 72 ?a)))
    (cc/test--with-max 72
      (should (equal (cc/gptel-magit--truncate-subject s) s)))))

(ert-deftest cc/gptel-truncate-one-over-limit-trims-to-word-boundary ()
  ;; 73 chars, last word starts at 68 -> trimmed at the preceding boundary.
  (cc/test--with-max 72
    (let ((s (concat (make-string 67 ?a) " bbbbb")))
      (should (equal (cc/gptel-magit--truncate-subject s)
                     (make-string 67 ?a))))))

(ert-deftest cc/gptel-truncate-no-space-hard-cuts ()
  (cc/test--with-max 10
    (should (equal (cc/gptel-magit--truncate-subject (make-string 40 ?x))
                   (make-string 10 ?x)))))

(ert-deftest cc/gptel-truncate-trailing-space-trimmed ()
  (cc/test--with-max 10
    (should (equal (cc/gptel-magit--truncate-subject "abcde     fghij more")
                   "abcde"))))

(ert-deftest cc/gptel-truncate-empty-string ()
  (cc/test--with-max 72
    (should (equal (cc/gptel-magit--truncate-subject "") ""))))

;;; cc/gptel-select-backend

(defmacro cc/test--with-backends (alist default &rest body)
  (declare (indent 2))
  `(let ((cc/gptel-backends (make-hash-table :test #'eq))
         (cc/gptel-default-backend ,default))
     (pcase-dolist (`(,k . ,v) ,alist) (puthash k v cc/gptel-backends))
     ,@body))

(ert-deftest cc/gptel-select-returns-configured-default ()
  (cc/test--with-backends '((openai . :o) (deepseek . :d)) 'openai
    (should (eq (cc/gptel-select-backend) :o))))

(ert-deftest cc/gptel-select-falls-back-in-order ()
  ;; default 'gemini absent; fallback order is deepseek openai anthropic ...
  (cc/test--with-backends '((anthropic . :a) (openai . :o)) 'gemini
    (should (eq (cc/gptel-select-backend) :o))))

(ert-deftest cc/gptel-select-nil-when-registry-empty ()
  (cc/test--with-backends '() 'openai
    (should (null (cc/gptel-select-backend)))))

;;; test-gptel.el ends here
