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
  ;; Provider, model, and credential setup lives in config.d/ai.el.
  (setopt gptel-log-level 'info
    gptel-use-tools t))

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
;;   (map! :desc "mcp hub" "C-c m h" #'mcp-hub)
;;   (when cc/use-mcp-p
;;     (after! gptel
;;       (cc/gptel-mcp-register-tools))
;;     (add-hook 'after-init-hook #'mcp-hub-start-all-server)
;;     (add-hook 'gptel-mode-hook #'cc/gptel-enable-all-mcp-tools)))
