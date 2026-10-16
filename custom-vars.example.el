;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; custom-vars.el

(setopt
  user-full-name "Name"
  user-mail-address "name@example.com")

;; Fonts and themes: see ui-vars.example.el (machine-local ui-vars.el).

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
  cc/org-roam-default-category "Unsorted"
  cc/org-roam-non-category-directories '(".cache" "assets"))

;; llm
(setopt
  cc/openai-api-key ""
  cc/anthropic-api-key ""
  cc/deepseek-api-key ""
  cc/gemini-api-key ""
  cc/mistral-api-key ""

  ;; 自定义 OpenAI 兼容 vendor（纯数据，可加任意多个；构造推迟到 :cc ai 模块内）
  cc/gptel-openai-compatible-vendors
  '((:id volengine
      :name "VolEngine"
      :host "ark.cn-beijing.volces.com"
      :protocol "https"
      :key "your-api-key"
      :endpoint "/api/coding/v3/chat/completions"
      :stream t
      :models ((deepseek-v4-flash-260425 :capabilities (tool)))))

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

  ;; gptel 文件工具：nil 表示只允许当前项目；也可固定一个或多个目录
  cc/gptel-file-tool-roots nil
  ;; cc/gptel-file-tool-roots '("~/projects/")

  ;; gptel-magit：commit message 用另一套 backend/model（都留 nil 则跟随默认）
  ;; openai-sub（ChatGPT OAuth）是 stream-only，gptel-magit 走非流式会 400，
  ;; 只能挑支持非流式的 backend：deepseek / copilot / anthropic / openai
  cc/gptel-magit-backend 'volengine
  cc/gptel-magit-model 'deepseek-v4-flash-260425

  ;; Minuet: 'codestral or 'deepseek
  cc/minuet-provider 'codestral

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
