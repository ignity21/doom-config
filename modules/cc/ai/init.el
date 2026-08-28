;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/ai/init.el

;; User options for the :cc ai module.  `modules/README.org' requires a
;; module's user options to be defined in its init.el (loaded early, before
;; $DOOMDIR/config.el sets values from custom-vars.el).

(defcustom cc/openai-api-key ""
  "The API key for OpenAI."
  :type 'string
  :group 'cc-ai)

(defcustom cc/anthropic-api-key ""
  "The API key for Anthropic."
  :type 'string
  :group 'cc-ai)

(defcustom cc/deepseek-api-key ""
  "The API key for DeepSeek."
  :type 'string
  :group 'cc-ai)

(defcustom cc/gemini-api-key ""
  "The API key for Gemini."
  :type 'string
  :group 'cc-ai)

(defcustom cc/gptel-enable-copilot nil
  "Whether to enable GitHub Copilot as a gptel backend."
  :type 'boolean
  :group 'cc-ai)

(defcustom cc/gptel-default-backend 'deepseek
  "The default backend for gptel."
  :type '(choice
          (const :tag "DeepSeek" deepseek)
          (const :tag "OpenAI" openai)
          (const :tag "Anthropic" anthropic)
          (const :tag "Gemini" gemini)
          (const :tag "GitHub Copilot" copilot))
  :group 'cc-ai)
