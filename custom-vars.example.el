;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; custom-vars.el

(setopt
  user-full-name "Name"
  user-mail-address "name@example.com")

;; Fonts
(setopt
  cc/font-size 17
  cc/han-font (font-spec :family "LXGW WenKai" :weight 'medium :size cc/font-size)
  cc/emoji-font (font-spec :family "Noto Color Emoji" :size cc/font-size)
  doom-font (font-spec :family "Hack Nerd Font Mono" :size cc/font-size)
  doom-symbol-font (font-spec :family "Sarasa Mono SC" :size cc/font-size)
  doom-big-font-increment (+ cc/font-size (/ cc/font-size 4)) ; increase by 25%
  )

;; Themes
(setopt
  cc/light-ef-theme 'ef-cyprus)

;; checkers
(setopt
  ispell-dictionary "en_US"
  cc/personal-aspell-en-dict "~/dicts/spell-fu/en.pws")
