;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; custom-vars.el

(setopt
  user-full-name "Name"
  user-mail-address "name@example.com")

;; Fonts
(setopt
  font-size 18
  doom-font (font-spec :family "Hack Nerd Font Mono" :size font-size)
  doom-symbol-font (font-spec :family "LXGW WenKai Mono" :size font-size :weight 'medium)
  doom-emoji-font (font-spec :family "Noto Color Emoji" :size font-size)
  doom-big-font-increment 2)

;; Themes
(setopt
  cc/light-ef-theme 'ef-cyprus)

;; checkers
(setopt
  ispell-dictionary "en_US"
  cc/personal-aspell-en-dict "~/dicts/spell-fu/en.pws")
