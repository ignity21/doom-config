;;; test/test-helper.el --- shared test scaffolding -*- lexical-binding: t; -*-

;; Loaded by the ERT suites.  These run under plain `emacs -Q --batch' with no
;; Doom, so Doom's config macros are stubbed to no-ops; only the top-level
;; `defvar' / `defconst' / `defun' forms of a loaded config file take effect.

(require 'cl-lib)
(require 'subr-x)

(defvar cc/test-root
  (file-name-as-directory
   (expand-file-name ".." (file-name-directory (or load-file-name buffer-file-name))))
  "Repository root, derived from this file's location.")

(defmacro cc/test--noop-macro (&rest _) "Stubbed Doom config macro." nil)

(dolist (name '(use-package! after! map! add-hook! remove-hook! setq-hook!
                add-to-list! load! modulep! featurep!))
  (defalias name 'cc/test--noop-macro))

(defun cc/test-load (relpath)
  "Load config file RELPATH (repo-relative) with Doom macros stubbed."
  (load (expand-file-name relpath cc/test-root) nil t))

(provide 'test-helper)
;;; test-helper.el ends here
