;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; mycustom.el

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq! user-full-name "Name"
       user-mail-address "name@example.com"

;; cc-ui
(setq! cc/mono-font "Hack"
       cc/unicode-font "Source Han Sans CN"
       cc/emoji-font "Noto Color Emoji"
       cc/font-size 24
       ;; recommended: doom-one-light, doom-acario-light(cold), doom-oksolar-light(warm)
       cc/light-theme 'doom-one-light
       ;; recommended: doom-one, doom-peacock, doom-tomorrow-night, doom-opera
       cc/dark-theme 'doom-tomorrow-night)

;; cc-config
(setq! cc/personal-aspell-en-dict "~/dicts/spell-fu/en.pws")

;; cc-note
(setq! cc/default-org-dir "~/org/"
       cc/org-id-locations "~/org/.orgids"
       cc/notes-base-dir "~/org/notes/"
       cc/org-agenda-dir "~/org/todos/")

;; cc-dev
(setq! cc/cpp-default-tab-width 2)

;; cc-ai
(setq! cc/openai-key ""
       cc/anthropic-key ""
       cc/gemini-key ""
       cc/deepseek-key "")

;; ai-tools
(setq!
 ;; aidermacs
 ;; models:
 ;; deepseek-reasoner
 ;; deepseek/deepseek-chat
 ;; claude-sonnet-4-20250514
 ;; gemini-2.5-pro-preview-05-06
 aidermacs-default-model "claude-sonnet-4-20250514"
 aidermacs-weak-model "claude-3-5-haiku-latest"
 aidermacs-architect-model "gemini-2.5-pro-preview-05-06"
 ;; for code generation
 aidermacs-editor-model "claude-sonnet-4-20250514"
 aidermacs-auto-commits nil
 ;; aidermacs-config-file "~/.aider.conf.yml"

 ;; gptel
 gptel-model 'claude-3-5-haiku-latest
 gptel-temperature 0.8
 gptel-max-tokens 4096
 )
