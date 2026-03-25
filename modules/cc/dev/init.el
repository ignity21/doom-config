;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/dev/init.el

(defun cc/minuet--use-claude ()
  (setenv "ANTHROPIC_API_KEY" cc/anthropic-key)
  (setopt minuet-provider 'claude
          minuet-n-completions 2
          minuet-context-window 768))

(defun cc/minuet--use-ollama ()
  (setopt minuet-provider 'openai-fim-compatible
          minuet-n-completions 1
          minuet-context-window 512)
  (minuet-set-optional-options minuet-openai-fim-compatible-options :max_tokens 64)
  (plist-put minuet-openai-fim-compatible-options :end-point "http://localhost:11434/v1/completions")
  (plist-put minuet-openai-fim-compatible-options :name "Ollama")
  (plist-put minuet-openai-fim-compatible-options :api-key "TERM")
  (plist-put minuet-openai-fim-compatible-options :model "qwen2.5-coder:1.5b"))

(defun cc/minuet--use-gemini ()
  (setopt minuet-provider 'gemini
          minuet-n-completions 2
          minuet-context-window 768)
  (plist-put minuet-gemini-options :model "gemini-3.1-flash-lite-preview")
  (minuet-set-optional-options
   minuet-gemini-options :generationConfig
   '(:maxOutputTokens 256
     :topP 0.9
     :thinkingConfig (:thinkingBudget 0)))

  (minuet-set-optional-options
   minuet-gemini-options
   :safetySettings
   [(:category "HARM_CATEGORY_DANGEROUS_CONTENT"
     :threshold "BLOCK_NONE")
    (:category "HARM_CATEGORY_HATE_SPEECH"
     :threshold "BLOCK_NONE")
    (:category "HARM_CATEGORY_HARASSMENT"
     :threshold "BLOCK_NONE")
    (:category "HARM_CATEGORY_SEXUALLY_EXPLICIT"
     :threshold "BLOCK_NONE")])
  )
