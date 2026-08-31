;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/dashboard-tips.el

;; Tips are deliberately data, not configuration: they are read once, only
;; when Doom renders the dashboard.  See data/dashboard-tips.eld.

(defconst cc/dashboard-tips-file
  (expand-file-name "data/dashboard-tips.eld" doom-user-dir)
  "File containing the dashboard tip data.")

(defvar cc/dashboard--tips nil
  "Cached contents of `cc/dashboard-tips-file'.")

(defface cc-dashboard-tip-heading
  '((t :inherit font-lock-keyword-face :weight bold))
  "Face for a dashboard tip heading."
  :group 'cc-ui)

(defface cc-dashboard-tip-text
  '((t :inherit font-lock-comment-face))
  "Face for dashboard tip text."
  :group 'cc-ui)

(defun cc/dashboard--tip-available-p (tip)
  "Return non-nil when TIP applies to the enabled configuration."
  (pcase (plist-get tip :requires)
    ('minuet (modulep! :cc completion +minuet))
    ('copilot (modulep! :cc completion +copilot))
    ('org-roam (modulep! :lang org +roam))
    ('tramp (modulep! :emacs dired))
    (_ t)))

(defun cc/dashboard--load-tips ()
  "Read and cache the dashboard tip data without evaluating it."
  (or cc/dashboard--tips
      (setq cc/dashboard--tips
            (when (file-readable-p cc/dashboard-tips-file)
              (with-temp-buffer
                (insert-file-contents cc/dashboard-tips-file)
                (read (current-buffer)))))))

(defun cc/dashboard--daily-number (&optional date)
  "Return a stable pseudo-random number for DATE, defaulting to today."
  (string-to-number
   (substring (secure-hash 'sha256 (or date (format-time-string "%F"))) 0 12)
   16))

(defun cc/dashboard--choose-tip (tips &optional date)
  "Select one TIP from TIPS with weighted, day-stable random choice.
DATE is an ISO date string used by tests and defaults to today."
  (let ((eligible nil)
        (total 0))
    (dolist (tip tips)
      (when (cc/dashboard--tip-available-p tip)
        (let ((weight (max 0 (or (plist-get tip :weight) 1))))
          (when (> weight 0)
            (push tip eligible)
            (setq total (+ total weight))))))
    (when (> total 0)
      (let ((target (% (cc/dashboard--daily-number date) total)))
        (catch 'selected
          (dolist (tip (nreverse eligible))
            (setq target (- target (plist-get tip :weight)))
            (when (< target 0)
              (throw 'selected tip))))))))

(defun cc/dashboard-widget-tip ()
  "Insert today's weighted dashboard tip."
  (when-let* ((tip (cc/dashboard--choose-tip (cc/dashboard--load-tips))))
    ;; Start a fresh dashboard paragraph below the banner.  Besides giving the
    ;; banner breathing room, this avoids inheriting its display properties.
    (+dashboard-insert "")
    (+dashboard-insert
     (propertize (format "Tip · %s" (plist-get tip :topic))
                 'face 'cc-dashboard-tip-heading))
    (+dashboard-insert
     (propertize (plist-get tip :text) 'face 'cc-dashboard-tip-text))))

(when (modulep! :ui dashboard)
  ;; Place the tip directly below the banner and before the shortcut menu.
  (setq +dashboard-functions
        (delq #'cc/dashboard-widget-tip +dashboard-functions))
  (if-let* ((tail (memq #'+dashboard-widget-banner +dashboard-functions)))
      (setcdr tail (cons #'cc/dashboard-widget-tip (cdr tail)))
    (setq +dashboard-functions
          (append +dashboard-functions '(cc/dashboard-widget-tip)))))
