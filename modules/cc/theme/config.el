;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/theme/config.el

(setopt doom-font (font-spec :family cc/mono-font :size cc/font-size)
        doom-symbol-font (font-spec :family cc/unicode-font :size cc/font-size :weight 'medium)
        doom-big-font-increment (+ cc/font-size (/ cc/font-size 3))
        doom-theme cc/light-theme)

(add-hook! 'doom-load-theme-hook
  (set-fontset-font t 'emoji (font-spec :family cc/emoji-font) nil 'prepend))


(if (string-equal (getenv "XDG_SESSION_DESKTOP") "gnome")
    (set-theme-based-on-sys-style)
  (set-theme-based-on-time))

(map! "<f12>" #'cc/switch-light-dark-theme)
