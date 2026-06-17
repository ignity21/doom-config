;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; custom-vars.el

(setopt
  user-full-name "Name"
  user-mail-address "name@example.com")

;; Fonts
(setopt
  cc/font-size 16
  cc/chinese-font (font-spec :family "LXGW WenKai" :weight 'medium :size cc/font-size)
  cc/japanese-font (font-spec :family "Sarasa Gothic J" :size cc/font-size)
  cc/emoji-font (font-spec :family "Noto Color Emoji" :size cc/font-size)
  doom-font (font-spec :family "Hack Nerd Font Mono" :size cc/font-size)
  doom-symbol-font (font-spec :family "Sarasa Mono SC" :size cc/font-size)
  doom-big-font-increment 2)

;; Themes
(setopt
  cc/light-ef-theme 'ef-cyprus)

;; checkers
(setopt
  ispell-dictionary "en_US"
  cc/personal-aspell-en-dict "~/dicts/spell-fu/en.pws")
