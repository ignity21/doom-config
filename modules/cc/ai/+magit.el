;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/ai/+magit.el

(defun cc/gptel-magit--truncate-subject (subject)
  "Return SUBJECT within `git-commit-summary-max-length' at a word boundary."
  (if (<= (length subject) git-commit-summary-max-length)
      subject
    (let ((prefix (substring subject 0 git-commit-summary-max-length)))
      (string-trim-right
       (if (string-match "\\`\\(.*\\)[[:space:]]+[^[:space:]]*\\'" prefix)
           (match-string 1 prefix)
         prefix)))))

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

  (define-advice gptel-magit--format-commit-message
      (:around (original-fn message) cc/prevent-subject-wrap)
    "Keep an overlong generated subject on one line before formatting it."
    (let* ((lines (split-string message "\n" nil))
           (subject (cc/gptel-magit--truncate-subject (or (car lines) "")))
           (normalized-message (string-join (cons subject (cdr lines)) "\n")))
      (funcall original-fn normalized-message))))
