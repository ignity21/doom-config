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
  (setopt
    git-commit-summary-max-length 72
    gptel-magit-commit-prompt
    (concat
      "You are an expert at writing Git commits. Your job is to write a "
      "short, clear commit message that summarizes the changes.\n\n"

      "The commit message should be structured as follows:\n\n"
      "    <type>(<optional scope>): <description>\n\n"
      "    [optional body]\n\n"

      "- Each commit MUST begin with one of the following types: "
      "build, chore, ci, docs, feat, fix, perf, refactor, style, test\n"
      "- The type feat MUST be used when a commit adds a new feature\n"
      "- The type fix MUST be used when a commit represents a bug fix\n"
      "- An optional scope MAY follow the type, e.g., fix(parser):\n"
      "- A description MUST immediately follow the type or type/scope prefix\n"
      (format
        "- Keep the subject on a single line and within %d characters\n"
        git-commit-summary-max-length)
      "- If necessary, shorten or rephrase the subject instead of wrapping it\n"
      "- Focus the subject on the primary change. Put secondary changes in the body\n"
      "- Capitalize the subject line\n"
      "- Do not end the subject line with any punctuation\n"
      "- A commit body MAY be provided after the short description. "
      "The body MUST begin after exactly one blank line\n"
      "- Use the imperative mood in the subject line\n"
      "- Keep the body short and concise (omit it entirely if not useful)\n\n"

      "Output only the commit message. Do not include explanations, "
      "Markdown formatting, or code fences.")))
