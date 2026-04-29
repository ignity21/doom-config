;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/theme/config.el
(use-package! modus-themes
  :config
  (setopt modus-themes-italic-constructs t
    modus-themes-bold-constructs t
    modus-themes-mixed-fonts t
    modus-themes-to-toggle `(,cc/light-theme ,cc/dark-theme))
  :bind ("<f12>" . modus-themes-toggle))

(add-hook! 'doom-load-theme-hook
  (set-fontset-font t 'emoji (font-spec :family cc/emoji-font) nil 'prepend))

(setopt doom-font (font-spec :family cc/mono-font :size cc/font-size)
  doom-symbol-font (font-spec :family cc/unicode-font :size cc/font-size :weight 'medium)
  doom-big-font-increment (+ cc/font-size (/ cc/font-size 3))
  doom-theme cc/light-theme)
