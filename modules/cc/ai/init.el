;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/ai/init.el

;; (defcustom cc/openai-key "<openai-key>"
;;   "OpenAI API key."
;;   :group 'cc-ai
;;   :type 'string)

;; (defcustom cc/anthropic-key "<anthropic-key>"
;;   "Anthropic API key."
;;   :group 'cc-ai
;;   :type 'string)

;; (defcustom cc/gemini-key "<gemini-key>"
;;   "Gemini API key."
;;   :group 'cc-ai
;;   :type 'string)

;; (defcustom cc/deepseek-key "<deepseek-key>"
;;   "DeepSeek API key."
;;   :group 'cc-ai
;;   :type 'string)

(defcustom cc/use-mcp-p t
  "Use mcp-hub."
  :group 'cc-mcp
  :type 'boolean)

(defcustom cc/mcp-fs-directory "~/repos/"
  "Directory for mcp-hub filesystem server."
  :group 'cc-mcp
  :type 'string)
