;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; mycustom.el

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setopt user-full-name "Name"
  user-mail-address "name@example.com")

;; cc-config
(setopt cc/personal-aspell-en-dict "~/dicts/spell-fu/en.pws")

;; cc-note
(setopt
  org-directory "~/org/"
  cc/org-agenda-dir "~/org/todos/"
  cc/notes-root-dir "~/org/notes/")

;; cc-dev
(setopt cc/cpp-default-tab-width 2)

;; cc-ai
(setopt cc/openai-key ""
  cc/anthropic-key ""
  cc/gemini-key ""
  cc/deepseek-key "")

;; ai-tools
(setopt
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
  )
