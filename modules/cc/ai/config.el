;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/ai/config.el

;; ai-code-interface
(use-package! ai-code
  :init
  ;; `C-c a a' is bound in config.d/keybindings.el.
  (setopt
    ai-code-backends-infra-terminal-backend 'ghostel
    ai-code-auto-test-type 'ask-me)
  :commands (ai-code-menu)
  :config
  (ai-code-set-backend 'codex)
  (with-eval-after-load 'magit
    (ai-code-magit-setup-transients))
  )

;; ;; aider
;; (use-package! aider
;;   :commands (aider-transient-menu)
;;   :init
;;   (map! :desc "aider.el menu" "C-c a" #'aider-transient-menu
;;         (:map aider-prompt-mode-map
;;          :desc "Aider send region" "C-c C-e" #'aider-send-line-or-region
;;          :desc "Switch to aider" "C-c C-b" #'aider-switch-to-buffer)))

;; gptel
(use-package! gptel
  :commands (gptel-send
              gptel
              gptel-menu
              gptel-rewrite
              gptel-tools)
  :config
  (setopt gptel-log-level 'info
    gptel-use-tools t))

;; gptel backend registry
(defvar cc/gptel-backends
  (make-hash-table :test #'eq)
  "Registry of available gptel backends, keyed by provider symbol.")

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

;; NOTE: gptel is lazy-loaded via :commands, so this `after!' body runs on
;; first use -- well after $DOOMDIR/config.el has loaded custom-vars.el.  Do
;; not `require' gptel during startup or the API keys will not be set yet.
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

;; mcp servers
;; (use-package! mcp
;;   :after gptel
;;   :init
;;   (setopt mcp-hub-servers
;;     ;; support multiple directories
;;     `(
;;        ;; NOTE filesystem server
;;        ("filesystem" .
;;          (:command "npx" :args ("-y" "@modelcontextprotocol/server-filesystem" ,cc/mcp-fs-directory)))

;;        ;; NOTE mcp-server-fetch server
;;        ;; ("fetch" . (:command "uvx" :args ("mcp-server-fetch")))

;;        ;; NOTE git server
;;        ;; ("git" . (:command "uvx" :args ("mcp-server-git" "--git-dir" ,cc/mcp-git-directory)))
;;        )
;;     )
;;   :config
;;   (require 'mcp-hub)
;;   (require 'gptel-integrations)
;;   ;; :hook (after-init . mcp-hub-start-all-server)
;;   )

;; use `mcp-make-text-tool` to create a gptel tool
;; (use-package! mcp-hub
;;   :commands (mcp-hub
;;              mcp-hub-start-all-server
;;              mcp-hub-close-all-server)
;;   :init
;;   (setq mcp-hub-servers
;;         ;; support multiple directories
;;         `(
;;           ;; NOTE filesystem server
;;           ;; ("filesystem" .
;;           ;;  (:command "npx" :args ("-y" "@modelcontextprotocol/server-filesystem" ,cc/mcp-fs-directory)))

;;           ;; NOTE fetch web server
;;           ;; ("fetch" . (:command "uvx" :args ("mcp-server-fetch")))

;;           ;; NOTE git server
;;           ;; ("git" . (:command "uvx" :args ("mcp-server-git" "--git-dir" ,cc/mcp-git-directory)))
;;           )
;;         )
;;   ;; check if gptel package is loaded
;;   (when (featurep 'gptel)
;;     (require 'gptel-integrations))
;;   (map! :desc "mcp hub" "C-c a m" #'mcp-hub)
;;   (when cc/use-mcp-p
;;     (after! gptel
;;       (cc/gptel-mcp-register-tools))
;;     (add-hook 'after-init-hook #'mcp-hub-start-all-server)
;;     (add-hook 'gptel-mode-hook #'cc/gptel-enable-all-mcp-tools)))

;; gptel-magit: Conventional Commit message generation.
(load! "+magit")
