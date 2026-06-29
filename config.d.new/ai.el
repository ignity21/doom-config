;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/ai.el
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
  "Whether to enable GitHub Copilot."
  :type 'boolean
  :group 'cc-ai)

;; provider selection
(defcustom cc/gptel-default-backend 'deepseek
  "The default backend for gptel."
  :type '(choice
           (const :tag "DeepSeek" deepseek)
           (const :tag "OpenAI" openai)
           (const :tag "Anthropic" anthropic)
           (const :tag "Gemini" gemini)
           (const :tag "GitHub Copilot" copilot))
  :group 'cc-ai)

;; backend registry
(defvar cc/gptel-backends
  (make-hash-table :test #'eq)
  "Registry of gptel backends.")

(after! gptel
  ;; Copilot
  (when cc/gptel-enable-copilot
    (puthash 'copilot
      (gptel-make-gh-copilot "Copilot")
      cc/gptel-backends))

  ;; OpenAI
  (when (not (string-empty-p (or cc/openai-api-key "")))
    (puthash 'openai
      (gptel-make-openai "OpenAI"
        :stream t
        :key cc/openai-api-key)
      cc/gptel-backends))

  ;; DeepSeek
  (when (not (string-empty-p (or cc/deepseek-api-key "")))
    (puthash 'deepseek
      (gptel-make-deepseek "DeepSeek"
        :stream t
        :key cc/deepseek-api-key
        :models '((deepseek-v4-flash
                    :capabilities (tool reasoning)
                    :context-window 1000
                    :input-cost 0.14
                    :output-cost 0.28)
                   (deepseek-v4-pro
                     :capabilities (tool reasoning)
                     :context-window 1000
                     :input-cost 0.435
                     :output-cost 0.87)))
      cc/gptel-backends))

  ;; Anthropic
  (when (not (string-empty-p (or cc/anthropic-api-key "")))
    (puthash 'anthropic
      (gptel-make-anthropic "Anthropic"
        :stream t
        :key cc/anthropic-api-key)
      cc/gptel-backends))

  ;; Gemini
  (when (not (string-empty-p (or cc/gemini-api-key "")))
    (puthash 'gemini
      (gptel-make-gemini "Gemini"
        :stream t
        :key cc/gemini-api-key)
      cc/gptel-backends))

  ;; select default backend
  (setq gptel-backend
    (gethash cc/gptel-default-backend cc/gptel-backends)))


(after! gptel-magit
  (setopt gptel-magit-commit-prompt
    (concat
      "You are an expert at writing Git commits. Your job is to write a "
      "short clear commit message that summarizes the changes.\n\n"

      "The commit message should be structured as follows:\n\n"
      "    <type>(<optional scope>): <description>\n\n"
      "    [optional body]\n\n"

      "- Commits MUST be prefixed with a type, which consists of one of "
      "the following words: build, chore, ci, docs, feat, fix, perf, "
      "refactor, style, test\n"
      "- The type feat MUST be used when a commit adds a new feature\n"
      "- The type fix MUST be used when a commit represents a bug fix\n"
      "- An optional scope MAY be provided after a type. A scope is a "
      "phrase describing a section of the codebase enclosed in "
      "parentheses, e.g., fix(parser):\n"
      "- A description MUST immediately follow the type/scope prefix. "
      "The description is a short description of the code changes.\n"
      "- Try to limit the whole subject line to 72 characters\n"
      "- The subject MUST consist of exactly one line. Never wrap the "
      "subject line.\n"
      "- Capitalize the subject line\n"
      "- Do not end the subject line with any punctuation\n"
      "- A longer commit body MAY be provided after the short "
      "description. The body MUST begin after exactly one blank line.\n"
      "- If the subject is too long, shorten or rephrase it instead of "
      "wrapping it.\n"
      "- Use the imperative mood in the subject line\n"
      "- Keep the body short and concise (omit it entirely if not "
      "useful)")))

(after! git-commit
  (setopt git-commit-summary-max-length 72))
