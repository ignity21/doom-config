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

(defconst cc/gptel-backend-fallback-order
  '(deepseek openai anthropic gemini copilot)
  "Backend preference order when the configured default is unavailable.")

(defun cc/gptel-select-backend ()
  "Return the configured gptel backend or a deterministic available fallback."
  (or (gethash cc/gptel-default-backend cc/gptel-backends)
      (catch 'backend
        (dolist (name cc/gptel-backend-fallback-order)
          (when-let ((backend (gethash name cc/gptel-backends)))
            (throw 'backend backend))))))

(after! gptel
  ;; Rebuilding the registry makes `doom/reload' reflect credential changes.
  (clrhash cc/gptel-backends)

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

  ;; Select the requested backend, or a known available fallback.
  (if-let ((backend (cc/gptel-select-backend)))
      (setq gptel-backend backend)
    (setq gptel-backend nil)
    (display-warning
     'cc-ai
     "No gptel backend is configured; set a provider key or enable GitHub Copilot."
     :warning)))

(after! gptel-magit
  (setopt
    git-commit-summary-max-length 72
    gptel-magit-commit-prompt
    (concat
      "Write a Conventional Commit message for the staged diff.\n\n"
      "Return exactly this plain-text shape:\n\n"
      "<type>(<optional scope>): <imperative subject>\n"
      "\n"
      "<optional body>\n\n"
      "Subject rules:\n"
      "- Choose exactly one type: build, chore, ci, docs, feat, fix, perf, "
      "refactor, style, or test. Use feat only for a user-visible feature and "
      "fix only for a bug fix.\n"
      "- Include a scope only when it makes the subject clearer.\n"
      "- Start the description with an imperative verb; capitalize it; do not "
      "end it with punctuation.\n"
      "- The entire first line, including type and scope, should target 60 "
      "characters and MUST NOT exceed 72 characters.\n"
      "- Before responding, count the first line. If it is too long, rewrite it "
      "shorter; never wrap it or continue it on a second line.\n"
      "- Summarize the primary change only. Move secondary details to the body.\n\n"
      "Body rules:\n"
      "- Omit the body unless it explains a non-obvious why, compatibility "
      "impact, or important secondary change.\n"
      "- When present, begin after exactly one blank line and wrap each body "
      "line at 72 characters or fewer.\n\n"
      (format "The hard subject limit is %d characters; output only the commit message, without Markdown, quotes, explanations, or code fences."
              git-commit-summary-max-length)))

  (defun cc/gptel-magit--truncate-subject (subject)
    "Return SUBJECT within `git-commit-summary-max-length' at a word boundary."
    (if (<= (length subject) git-commit-summary-max-length)
        subject
      (let ((prefix (substring subject 0 git-commit-summary-max-length)))
        (string-trim-right
         (if (string-match "\\`\\(.*\\)[[:space:]]+[^[:space:]]*\\'" prefix)
             (match-string 1 prefix)
           prefix)))))

  (define-advice gptel-magit--format-commit-message
      (:around (original-fn message) cc/prevent-subject-wrap)
    "Keep an overlong generated subject on one line before formatting it."
    (let* ((lines (split-string message "\n" nil))
           (subject (cc/gptel-magit--truncate-subject (or (car lines) "")))
           (normalized-message (string-join (cons subject (cdr lines)) "\n")))
      (funcall original-fn normalized-message))))
