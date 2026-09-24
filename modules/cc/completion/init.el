;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/completion/init.el

(defcustom cc/minuet-provider 'codestral
  "Provider for Minuet inline code completion."
  :type '(choice (const :tag "Codestral (Mistral)" codestral)
                 (const :tag "DeepSeek FIM" deepseek))
  :group 'cc-completion)

(defcustom cc/mistral-api-key ""
  "The Mistral API key used by Minuet's Codestral provider."
  :type 'string
  :group 'cc-completion)
