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
  cc/light-ef-theme 'ef-cyprus
  cc/dark-ef-theme 'ef-dream)

;; Defaults
(setopt
  cc/tramp-user-bin-directory "~/.local/bin")

;; Org agenda
(setopt
  cc/default-org-dir "~/org/"
  cc/org-agenda-dir "~/org/todos/")

;; Notes / org-roam
(setopt
  cc/notes-root-dir "~/notes/"
  cc/org-roam-default-category "Inbox"
  cc/org-roam-non-category-directories '(".cache" "assets" "dailies" "logseq" "pages"))

;; llm
(setopt
  cc/openai-api-key ""
  cc/anthropic-api-key ""
  cc/deepseek-api-key ""
  cc/gemini-api-key ""

  ;; 自定义 OpenAI 兼容 vendor（纯数据，可加任意多个；构造推迟到 :cc ai 模块内）
  ;; cc/gptel-openai-compatible-vendors
  ;; '((:id openwebui
  ;;    :name "OpenWebUI"
  ;;    :host "localhost:3000"
  ;;    :protocol "http"
  ;;    :endpoint "/api/chat/completions"
  ;;    :key "KEY_FOR_ACCESSING_OPENWEBUI"
  ;;    :models ("gemma3n:latest"))
  ;;   (:id groq
  ;;    :name "Groq"
  ;;    :host "api.groq.com"
  ;;    :endpoint "/openai/v1/chat/completions"
  ;;    :key "gsk_..."
  ;;    :models (llama-3.3-70b-versatile
  ;;             (moonshotai/kimi-k2-instruct :capabilities (tool)))))
  ;; 选其一作默认：cc/gptel-default-backend 'openwebui

  ;; gptel
  gptel-default-mode 'org-mode
  gptel-include-reasoning t
  cc/gptel-enable-copilot t
  ;; ChatGPT 订阅（OAuth），启用后运行一次 M-x gptel-openai-oauth-login
  cc/gptel-enable-openai-sub t
  cc/gptel-default-backend 'openai-sub
  gptel-model 'gpt-5.6-terra
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

;; C/C++
(setopt
  cc/cpp-default-tab-width 4)

;; yaml
(setopt
  cc/yaml-indent-offset 2)
