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
  (setq! aidermacs-program "aider")
  (map! :desc "Aidermacs menu" "C-c a" #'aidermacs-transient-menu))

;; gptel
;; (use-package! gptel
;;   :commands (gptel-send
;;              gptel
;;              gptel-menu
;;              gptel-add
;;              gptel-add-file
;;              gptel-rewrite)
;;   :init
;;   (map! :prefix ("C-c a g" . "gptel")
;;         :desc "gptel menu" "g" #'gptel-menu
;;         :desc "Open chat" "c" #'gptel
;;         :desc "Add region/buffer" "a" #'gptel-add
;;         :desc "Add file" "f" #'gptel-add-file
;;         :desc "Rewrite region" "r" #'gptel-rewrite
;;         ;; :desc "Tools enable" "t" #'cc/gptel-enable-all-mcp-tools
;;         ;; :desc "Tools disable" "T" #'cc/gptel-disable-all-mcp-tools
;;         )
;;   :config
;;   (setq! gptel-default-mode 'org-mode
;;          gptel-log-level 'info
;;          gptel-use-tools t
;;          gptel-include-reasoning t
;;          gptel-rewrite-default-action 'ediff)
;;   (setq! gptel-api-key cc/openai-key)
;;   (gptel-make-anthropic "Claude" :stream t :key cc/anthropic-key)
;;   (gptel-make-gemini "Gemini" :stream t :key cc/gemini-key)
;;   (gptel-make-deepseek "DeepSeek" :stream t :key cc/deepseek-key)
;;   (gptel-make-ollama "Ollama"
;;     :host "localhost:11434"
;;     :stream t
;;     :models '(qwen2.5-coder:latest
;;               gemma3:12b))
;;   )

;; mcp servers
;; use `mcp-make-text-tool` to create a gptel tool
;; (use-package! mcp-hub
;;   :commands (mcp-hub
;;              mcp-hub-start-all-server
;;              mcp-hub-close-all-server)
;;   :init
;;   (setq mcp-hub-servers
;;         ;; support multiple directories
;;         `(("filesystem" .
;;            (:command "npx" :args ("-y" "@modelcontextprotocol/server-filesystem" ,cc/mcp-fs-directory)))
;;           ("fetch" . (:command "uvx" :args ("mcp-server-fetch")))
;;           ;; ("git" . (:command "uvx" :args ("mcp-server-git" "--git-dir" ,cc/mcp-git-directory)))
;;           ))
;;   (map! :desc "mcp hub" "C-c a m" #'mcp-hub)
;;   (when cc/use-mcp-p
;;     (after! gptel
;;       (cc/gptel-mcp-register-tools))
;;     (add-hook 'after-init-hook #'mcp-hub-start-all-server)
;;     (add-hook 'gptel-mode-hook #'cc/gptel-enable-all-mcp-tools)))
