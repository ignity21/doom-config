;;; test/lint-config.el --- config invariant checks -*- lexical-binding: t; no-byte-compile: t; -*-

;; Mechanical checks for the conventions in AGENTS.md that are otherwise only
;; enforced by hand.  Runs under plain `emacs -Q --batch' -- it does NOT load
;; Doom; every check is a text / filesystem inspection.
;;
;;   emacs -Q --batch -l test/lint-config.el -f cc/lint-run
;;
;; Findings are compared against `test/lint-baseline.txt' (one finding id per
;; line, "#" comments allowed).  The run exits non-zero only when a finding
;; appears that is not in the baseline, or when a baseline entry no longer
;; reproduces (so fixes must shrink the baseline).  Regenerate the baseline
;; with LINT_UPDATE_BASELINE=1.

(require 'cl-lib)
(require 'subr-x)

(defvar cc/lint-root
  (file-name-as-directory
   (expand-file-name ".." (file-name-directory (or load-file-name buffer-file-name))))
  "Repository root, derived from this file's location.")

(defvar cc/lint--findings nil)

(defun cc/lint--add (id fmt &rest args)
  "Record finding ID with a human-readable message."
  (push (cons id (apply #'format fmt args)) cc/lint--findings))

(defun cc/lint--files (&rest globs)
  "Return repo-relative paths of tracked files matching GLOBS via git."
  (let ((default-directory cc/lint-root))
    (split-string
     (shell-command-to-string
      (concat "git ls-files -z -- "
              (mapconcat (lambda (g) (shell-quote-argument g)) globs " ")))
     "\0" t)))

(defun cc/lint--slurp (relpath)
  (with-temp-buffer
    (insert-file-contents (expand-file-name relpath cc/lint-root))
    (buffer-string)))

(defun cc/lint--forms (relpath)
  "Read all top-level forms from RELPATH."
  (with-temp-buffer
    (insert-file-contents (expand-file-name relpath cc/lint-root))
    (goto-char (point-min))
    (let (forms)
      (condition-case nil
          (while t (push (read (current-buffer)) forms))
        (end-of-file nil))
      (nreverse forms))))

;;; Check 1 -- balanced parens / quotes

(defun cc/lint-check-parens ()
  (dolist (f (cc/lint--files "*.el"))
    (with-temp-buffer
      (emacs-lisp-mode)
      (insert-file-contents (expand-file-name f cc/lint-root))
      (condition-case err
          (check-parens)
        (error (cc/lint--add (format "parens:%s" f)
                             "%s: %s" f (error-message-string err)))))))

;;; Check 2 -- config.el registration completeness

(defun cc/lint--registered ()
  "Return (TOPLEVEL . LANGS): basenames loaded from config.el."
  (let (top langs)
    (dolist (form (cc/lint--forms "config.el"))
      (pcase form
        (`(cc/load-config ,(and (pred stringp) s))
         (if (string-prefix-p "langs/" s)
             (push (file-name-base s) langs)
           (push s top)))
        (`(cc/load-lang-config ,(and (pred stringp) s))
         (push s langs))))
    (cons top langs)))

(defun cc/lint-check-registration ()
  (pcase-let* ((`(,reg-top . ,reg-langs) (cc/lint--registered))
               (dir (expand-file-name "config.d.new" cc/lint-root))
               (fs-top (and (file-directory-p dir)
                            (directory-files dir nil "\\.el\\'")))
               (langdir (expand-file-name "langs" dir))
               (fs-langs (and (file-directory-p langdir)
                              (mapcar #'file-name-base
                                      (directory-files langdir nil "\\.el\\'")))))
    (dolist (f fs-top)
      (unless (member f reg-top)
        (cc/lint--add (format "unregistered:config.d.new/%s" f)
                      "config.d.new/%s exists but config.el never loads it" f)))
    (dolist (f reg-top)
      (unless (member f fs-top)
        (cc/lint--add (format "dangling-registration:config.d.new/%s" f)
                      "config.el loads config.d.new/%s but the file is missing" f)))
    (dolist (l fs-langs)
      (unless (member l reg-langs)
        (cc/lint--add (format "unregistered:config.d.new/langs/%s.el" l)
                      "config.d.new/langs/%s.el exists but config.el never loads it" l)))
    (dolist (l reg-langs)
      (unless (member l fs-langs)
        (cc/lint--add (format "dangling-registration:config.d.new/langs/%s.el" l)
                      "config.el loads langs/%s but the file is missing" l)))))

;;; Check 3 -- defcustom <-> custom-vars.example.el

(defun cc/lint--defcustom-symbols ()
  (let (syms)
    (dolist (f (cc/lint--files "*.el"))
      (unless (string-suffix-p "custom-vars.example.el" f)
        (with-temp-buffer
          (insert (cc/lint--slurp f))
          (goto-char (point-min))
          (while (re-search-forward "(defcustom[ \t\n]+\\(cc/[^ \t\n()]+\\)" nil t)
            (push (intern (match-string 1)) syms)))))
    (delete-dups syms)))

(defun cc/lint--example-symbols ()
  (let (syms)
    (dolist (form (cc/lint--forms "custom-vars.example.el"))
      (when (eq (car-safe form) 'setopt)
        (cl-loop for (k _v) on (cdr form) by #'cddr
                 when (and (symbolp k)
                           (string-prefix-p "cc/" (symbol-name k)))
                 do (push k syms))))
    (delete-dups syms)))

(defun cc/lint-check-example ()
  (let ((defs (cc/lint--defcustom-symbols))
        (exs (cc/lint--example-symbols)))
    (dolist (s defs)
      (unless (memq s exs)
        (cc/lint--add (format "defcustom-missing-example:%s" s)
                      "%s is a defcustom with no entry in custom-vars.example.el" s)))
    (dolist (s exs)
      (unless (memq s defs)
        (cc/lint--add (format "example-missing-defcustom:%s" s)
                      "custom-vars.example.el sets %s but no defcustom defines it" s)))))

;;; Check 4 -- module file names

(defconst cc/lint--module-file-whitelist
  '("init" "config" "packages" "autoload" "doctor" "cli"))

(defun cc/lint-check-module-filenames ()
  (dolist (f (cc/lint--files "modules/*.el"))
    (let* ((parts (split-string f "/"))
           (base (file-name-base f)))
      ;; modules/<group>/<mod>/<...>.el
      (unless (or (member base cc/lint--module-file-whitelist)
                  (string-prefix-p "+" base)
                  (member "autoload" (butlast parts)))
        (cc/lint--add (format "filename:%s" f)
                      "%s is not an allowed module file name (%s / +*.el / autoload/*.el)"
                      f (string-join cc/lint--module-file-whitelist ", "))))))

;;; Check 5 -- autoload.el cookies

(defun cc/lint-check-autoload-cookies ()
  (dolist (f (cc/lint--files "modules/*.el"))
    (when (equal (file-name-nondirectory f) "autoload.el")
      (with-temp-buffer
        (insert (cc/lint--slurp f))
        (goto-char (point-min))
        (unless (re-search-forward "^;;;###autoload" nil t)
          (cc/lint--add (format "autoload-cookie:%s" f)
                        "%s has no line-start ;;;###autoload cookie -- Doom never loads it" f))))))

;;; Check 6 -- lexical-binding header

(defun cc/lint-check-lexical-binding ()
  (dolist (f (cc/lint--files "*.el"))
    ;; packages.el is read in Doom's sandbox and conventionally carries only
    ;; `no-byte-compile' (matches upstream Doom modules).
    (unless (equal (file-name-nondirectory f) "packages.el")
      (let ((first-line (car (split-string (cc/lint--slurp f) "\n"))))
        (unless (string-match-p "-\\*-.*lexical-binding:[ \t]*t.*-\\*-" first-line)
          (cc/lint--add (format "lexbind:%s" f)
                        "%s: first line lacks a well-formed `-*- ... lexical-binding: t ... -*-'" f))))))

;;; Check 7 -- module names in doom! and modulep! resolve to real directories

(defun cc/lint--doom-modules-dir ()
  (or (getenv "DOOM_MODULES_DIR")
      (cl-find-if
       (lambda (d) (file-directory-p (expand-file-name "lang" d)))
       (list (expand-file-name "~/.config/emacs/sources/doom+/modules")
             (expand-file-name "~/.config/emacs/modules")
             (expand-file-name "~/.emacs.d/modules")))))

(defun cc/lint--module-exists-p (dirs cat mod)
  (cl-some (lambda (d) (file-directory-p (expand-file-name (format "%s/%s" cat mod) d)))
           dirs))

(defun cc/lint--doom!-modules ()
  "Return list of (CAT . MOD) strings from the doom! block in init.el."
  (let ((form (cl-find-if (lambda (f) (eq (car-safe f) 'doom!))
                          (cc/lint--forms "init.el")))
        (cat nil) pairs)
    (dolist (el (cdr form))
      (cond
       ((keywordp el) (setq cat (substring (symbol-name el) 1)))
       ((and cat (symbolp el) (not (string-prefix-p "&" (symbol-name el))))
        (push (cons cat (symbol-name el)) pairs))
       ((and cat (consp el) (symbolp (car el))
             (not (keywordp (car el))))
        (push (cons cat (symbol-name (car el))) pairs))))
    (nreverse pairs)))

(defun cc/lint--modulep!-refs ()
  "Return list of (CAT . MOD) from (modulep! :cat mod ...) across the repo."
  (let (refs)
    (dolist (f (cc/lint--files "*.el"))
      (with-temp-buffer
        (insert (cc/lint--slurp f))
        (goto-char (point-min))
        (while (re-search-forward
                "(\\(?:modulep!\\|featurep!\\)[ \t\n]+:\\([a-z][a-z0-9-]*\\)[ \t\n]+\\([a-z+][a-z0-9+-]*\\)"
                nil t)
          (let ((cat (match-string 1)) (mod (match-string 2)))
            (unless (string-prefix-p "+" mod)
              (push (list (cons cat mod) f) refs))))))
    (nreverse refs)))

(defun cc/lint-check-module-names ()
  (let* ((doom-dir (cc/lint--doom-modules-dir))
         (priv-dir (expand-file-name "modules" cc/lint-root))
         (dirs (delq nil (list doom-dir priv-dir))))
    (unless doom-dir
      (cc/lint--add "setup:doom-modules-dir"
                    "cannot locate the Doom modules directory (set DOOM_MODULES_DIR)"))
    (dolist (pair (cc/lint--doom!-modules))
      (unless (cc/lint--module-exists-p dirs (car pair) (cdr pair))
        (cc/lint--add (format "module-missing:%s/%s" (car pair) (cdr pair))
                      "init.el doom! block declares :%s %s but no such module directory exists"
                      (car pair) (cdr pair))))
    (dolist (ref (cc/lint--modulep!-refs))
      (pcase-let ((`((,cat . ,mod) ,file) ref))
        (unless (cc/lint--module-exists-p dirs cat mod)
          (cc/lint--add (format "module-missing:%s/%s" cat mod)
                        "%s references (modulep! :%s %s) but no such module directory exists"
                        file cat mod))))))

;;; Runner

(defvar cc/lint-checks
  '(cc/lint-check-parens
    cc/lint-check-registration
    cc/lint-check-example
    cc/lint-check-module-filenames
    cc/lint-check-autoload-cookies
    cc/lint-check-lexical-binding
    cc/lint-check-module-names))

(defun cc/lint--baseline ()
  (let ((f (expand-file-name "test/lint-baseline.txt" cc/lint-root)))
    (when (file-exists-p f)
      (with-temp-buffer
        (insert-file-contents f)
        (cl-loop for line in (split-string (buffer-string) "\n" t)
                 for s = (string-trim line)
                 unless (or (string-empty-p s) (string-prefix-p "#" s))
                 collect s)))))

(defun cc/lint-run ()
  (setq cc/lint--findings nil)
  (dolist (check cc/lint-checks)
    (funcall check))
  (let* ((ids (delete-dups (mapcar #'car cc/lint--findings)))
         (msgs (cl-remove-duplicates cc/lint--findings :key #'car :test #'equal :from-end t))
         (baseline (cc/lint--baseline)))
    (when (getenv "LINT_UPDATE_BASELINE")
      (with-temp-file (expand-file-name "test/lint-baseline.txt" cc/lint-root)
        (insert "# Known findings accepted for now; each planned Step should shrink this.\n"
                "# Regenerate with: LINT_UPDATE_BASELINE=1 make lint\n")
        (dolist (id (sort (copy-sequence ids) #'string<)) (insert id "\n")))
      (message "Wrote %d findings to test/lint-baseline.txt" (length ids))
      (kill-emacs 0))
    (let ((new (cl-set-difference ids baseline :test #'equal))
          (stale (cl-set-difference baseline ids :test #'equal)))
      (when msgs
        (message "\nAll findings (%d):" (length msgs))
        (dolist (f (sort (copy-sequence msgs)
                         (lambda (a b) (string< (car a) (car b)))))
          (message "  %s%s  %s"
                   (if (member (car f) baseline) "[baselined] " "")
                   (car f) (cdr f))))
      (when new
        (message "\nNEW findings not in baseline (%d):" (length new))
        (dolist (id (sort new #'string<)) (message "  %s" id)))
      (when stale
        (message "\nSTALE baseline entries that no longer reproduce (%d) -- remove them:"
                 (length stale))
        (dolist (id (sort stale #'string<)) (message "  %s" id)))
      (if (or new stale)
          (kill-emacs 1)
        (message "\nlint: OK (%d findings, all baselined)" (length msgs))
        (kill-emacs 0)))))

(provide 'lint-config)
;;; lint-config.el ends here
