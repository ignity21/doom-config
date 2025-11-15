;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/ai/config.el

;; aider
;; (use-package! aider
;;   :commands (aider-transient-menu)
;;   :init
;;   (map! :desc "aider.el menu" "C-c a e" #'aider-transient-menu
;;         (:map aider-prompt-mode-map
;;          :desc "Aider send region" "C-c C-e" #'aider-send-line-or-region
;;          :desc "Switch to aider" "C-c C-b" #'aider-switch-to-buffer)))

;; aidermacs
(use-package! aidermacs
  :commands aidermacs-transient-menu
  :init
  (map! :desc "Aidermacs menu" "C-c a" #'aidermacs-transient-menu)
  :config
  (setq! aidermacs-program '("aider-ce" "aider")
         aidermacs-default-model "gemini"
         aidermacs-weak-model "flash"
         aidermacs-auto-commits nil
         ;; May modify aidermacs-common-prompts
         )
  )

;; gptel
(use-package! gptel
  :commands (gptel-send
             gptel
             gptel-menu
             gptel-rewrite
             gptel-tools)
  :init
  (map! (:prefix "C-c m"
         :desc "gptel chat" "c" #'gptel
         :desc "gptel menu" "m" #'gptel-menu
         :desc "gptel send" "s" #'gptel-send
         :desc "gptel rewrite" "r" #'gptel-rewrite
         :desc "gptel mcp add" "+" #'gptel-mcp-connect
         :desc "gptel mcp rm" "-" #'gptel-mcp-disconnect
         ))
  :config
  (setq! gptel-default-mode 'org-mode
         gptel-log-level 'info
         gptel-use-tools t
         gptel-include-reasoning t
         ;; gptel-rewrite-default-action 'ediff
         ;; gptel-temperature 0.8
         ;; gptel-max-tokens 2048
         gptel-model 'claude-sonnet-4.5
         gptel-backend (gptel-make-gh-copilot "Copilot"))
  (gptel-make-anthropic "Claude" :stream t)
  (gptel-make-gemini "Gemini" :stream t)
  (gptel-make-deepseek "DeepSeek" :stream t)
  ;; (setq! gptel-api-key cc/openai-key)
  ;; (gptel-make-ollama "Ollama"
  ;;   :host "localhost:11434"
  ;;   :stream t
  ;;   :models '(qwen2.5-coder:latest
  ;;             gemma3:12b))
  )

;; mcp servers
(use-package! mcp
  :after gptel
  :init
  (setq! mcp-hub-servers
         ;; support multiple directories
         `(
           ;; NOTE filesystem server
           ("filesystem" .
            (:command "npx" :args ("-y" "@modelcontextprotocol/server-filesystem" ,cc/mcp-fs-directory)))

           ;; NOTE mcp-server-fetch server
           ;; ("fetch" . (:command "uvx" :args ("mcp-server-fetch")))

           ;; NOTE git server
           ;; ("git" . (:command "uvx" :args ("mcp-server-git" "--git-dir" ,cc/mcp-git-directory)))
           )
         )
  :config
  (require 'mcp-hub)
  (require 'gptel-integrations)
  ;; :hook (after-init . mcp-hub-start-all-server)
  )

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
;;   (map! :desc "mcp hub" "C-c m h" #'mcp-hub)
;;   (when cc/use-mcp-p
;;     (after! gptel
;;       (cc/gptel-mcp-register-tools))
;;     (add-hook 'after-init-hook #'mcp-hub-start-all-server)
;;     (add-hook 'gptel-mode-hook #'cc/gptel-enable-all-mcp-tools)))
