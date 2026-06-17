;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/ui.el


(defcustom cc/font-size 16
  "The default monospace font size."
  :type 'integer
  :group 'cc-ui)

(defcustom cc/chinese-font
  (font-spec :family "LXGW WenKai" :size cc/font-size)
  "Chinese font, Must be a `font-spec'"
  :type 'sexp
  :group 'cc-ui)

(defcustom cc/japanese-font
  (font-spec :family "Sarasa Gothic J" :size cc/font-size)
  "Japanese font, Must be a `font-spec'"
  :type 'sexp
  :group 'cc-ui)

(defcustom cc/emoji-font
  (font-spec :family "Noto Color Emoji" :size cc/font-size)
  "Emoji font, Must be a `font-spec'"
  :type 'sexp
  :group 'cc-ui)

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
  (ef-themes-take-over-modus-themes-mode 1)
  (map!
    "<f12>" #'ef-themes-toggle
    "S-<f12>" #'ef-themes-load-random-light)
  (add-hook! 'after-init-hook
    (ef-themes-load-theme cc/light-ef-theme))
  :config
  (setopt ef-themes-to-toggle `(,cc/light-ef-theme ,cc/dark-ef-theme)))

(add-hook! 'after-setting-font-hook
  (defun cc/set-fontset-font ()
    (set-fontset-font t 'han cc/chinese-font)
    (set-fontset-font t 'japanese-jisx0208 cc/japanese-font)
    (set-fontset-font t 'emoji cc/emoji-font)))
