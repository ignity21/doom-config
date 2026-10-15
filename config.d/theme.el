;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/theme.el


(defcustom cc/light-ef-theme 'ef-cyprus
  "The default light ef theme."
  :type 'symbol
  :group 'cc-ui)

(defcustom cc/dark-ef-theme 'ef-dream
  "The default dark ef theme."
  :type 'symbol
  :group 'cc-ui)

(use-package! ef-themes
  :demand t
  :init
  (setopt
    doom-theme nil
    modus-themes-mixed-fonts t
    modus-themes-italic-constructs t
    modus-themes-bold-constructs t)
  (map!
    "<f12>" #'ef-themes-toggle
    "S-<f12>" #'ef-themes-load-random-light)
  (add-hook! 'after-init-hook
    (ef-themes-load-theme cc/light-ef-theme))
  :config
  (ef-themes-take-over-modus-themes-mode 1)
  (setopt ef-themes-to-toggle `(,cc/light-ef-theme ,cc/dark-ef-theme)))

(add-hook! 'after-setting-font-hook
  (defun cc/set-fontset-font ()
    (set-fontset-font t 'emoji cc/emoji-font)))
