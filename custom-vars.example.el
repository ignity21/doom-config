;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; custom-vars.el

(setopt
  user-full-name "Name"
  user-mail-address "name@example.com")

;; Fonts
(setopt
  cc/font-size 17
  cc/emoji-font (font-spec :family "Noto Color Emoji" :size cc/font-size)
  doom-font (font-spec :family "Hack Nerd Font Mono" :size cc/font-size)
  doom-symbol-font (font-spec :family "Sarasa Mono SC" :size cc/font-size)
  doom-variable-pitch-font (font-spec :family "LXGW WenKai" :size cc/font-size)
  doom-big-font-increment (+ cc/font-size (/ cc/font-size 4)) ; increase by 25%
  )

;; Themes
(setopt
  cc/light-ef-theme 'ef-cyprus)

;; Defaults
(setopt
  cc/tramp-user-bin-directory "~/.local/bin")

;; llm
(setopt
  cc/openai-api-key ""
  cc/anthropic-api-key ""
  cc/deepseek-api-key ""
  cc/gemini-api-key ""

  ;; gptel
  gptel-default-mode 'org-mode
  gptel-include-reasoning t
  cc/gptel-enable-copilot t
  cc/gptel-default-backend 'copilot
  gptel-model 'claude-sonnet-4.5
  ;; gptel-temperature 0.8
  ;; gptel-max-tokens 4096
  )

;; checkers
(setopt
  ispell-dictionary "en_US"
  cc/personal-aspell-en-dict "~/dicts/spell-fu/en.pws")

;; python
(setopt
  cc/python-lsp-backend 'tyruff)
