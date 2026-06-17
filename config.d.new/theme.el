;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/ui.el

(defcustom cc/mono-font
  (string-trim-right
    (font-get-system-font) " [0-9]+$")
  "The default monospace font for the system."
  :type 'string
  :group 'cc-ui)

(defcustom cc/unicode-font
  (string-trim-right
    (font-get-system-normal-font) " [0-9]+$")
  "The default unicode font for the system."
  :type 'string
  :group 'cc-ui)

(defcustom cc/sc-font
  (string-trim-right
    (font-get-system-normal-font) " [0-9]+$")
  "The default monospace font for the system."
  :type 'string
  :group 'cc-ui)

(defcustom cc/emoji-font
  "Noto Color Emoji"
  "The default emoji font for the system."
  :type 'string
  :group 'cc-ui)

(defcustom cc/font-size 16
  "The default monospace font size."
  :type 'integer
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

(if (daemonp)
  (add-hook! 'after-make-frame-functions
    (lambda (frame)
      (with-selected-frame frame
        (set-fontset-font t 'emoji (font-spec :family cc/emoji-font) nil 'prepend)
        (set-fontset-font t 'han (font-spec :family cc/sc-font :weight 'medium) nil 'prepend)
        (set-fontset-font t 'cjk-misc (font-spec :family cc/sc-font:weight 'medium) nil 'prepend))))
  (add-hook! 'after-init-hook
    (set-fontset-font t 'emoji (font-spec :family cc/emoji-font) nil 'prepend)
    (set-fontset-font t 'han (font-spec :family cc/sc-font :weight 'medium) nil 'prepend)
    (set-fontset-font t 'cjk-misc (font-spec :family cc/sc-font :weight 'medium) nil 'prepend)
    ))

(setopt
  doom-font (font-spec :family cc/mono-font :size cc/font-size)
  doom-symbol-font (font-spec :family cc/unicode-font :size cc/font-size :weight 'medium)
  doom-big-font-increment (+ cc/font-size (/ cc/font-size 3)))
