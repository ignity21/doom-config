;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/ai/config.el

;; ai-code-interface
(use-package! ai-code
  :init
  ;; `C-c c a' is bound in config.d/keybindings.el.
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
  '(deepseek openai anthropic gemini copilot openai-sub)
  "Backend preference order when the configured default is unavailable.")

(defun cc/gptel--vendor-id (vendor)
  "Return the registry key for VENDOR plist (its :id, or a slug of :name)."
  (or (plist-get vendor :id)
    (intern (downcase (replace-regexp-in-string
                        "[^[:alnum:]]+" "-"
                        (string-trim (or (plist-get vendor :name) "")))))))

(defun cc/gptel--register-vendor (vendor)
  "Register VENDOR plist as an OpenAI-compatible gptel backend.
Skip it with a warning when a required key is missing."
  (let ((name   (plist-get vendor :name))
         (host   (plist-get vendor :host))
         (key    (plist-get vendor :key))
         (models (plist-get vendor :models)))
    (cond
      ((or (not (stringp name)) (string-empty-p (string-trim (or name ""))))
        (display-warning 'cc-ai "gptel vendor missing :name, skipped" :warning))
      ((or (not (stringp host)) (string-empty-p (or host "")))
        (display-warning 'cc-ai (format "gptel vendor %s missing :host, skipped" name) :warning))
      ((or (not (stringp key)) (string-empty-p (or key "")))
        (display-warning 'cc-ai (format "gptel vendor %s missing :key, skipped" name) :warning))
      ((null models)
        (display-warning 'cc-ai (format "gptel vendor %s missing :models, skipped" name) :warning))
      (t
        (puthash (cc/gptel--vendor-id vendor)
          (apply #'gptel-make-openai name
            :stream (if (plist-member vendor :stream) (plist-get vendor :stream) t)
            :key key
            :host host
            :models models
            (append
              (when-let ((v (plist-get vendor :endpoint)))       (list :endpoint v))
              (when-let ((v (plist-get vendor :protocol)))       (list :protocol v))
              (when-let ((v (plist-get vendor :header)))         (list :header v))
              (when-let ((v (plist-get vendor :request-params))) (list :request-params v))
              (when-let ((v (plist-get vendor :curl-args)))      (list :curl-args v))))
          cc/gptel-backends)))))

(defun cc/gptel-select-backend ()
  "Return the configured gptel backend or a deterministic available fallback."
  (or (gethash cc/gptel-default-backend cc/gptel-backends)
    (catch 'backend
      (dolist (name cc/gptel-backend-fallback-order)
        (when-let ((backend (gethash name cc/gptel-backends)))
          (throw 'backend backend))))))

(defun cc/gptel--model-updater-can-fetch-p (backend)
  "Non-nil when `gptel-model-updater' can build a models URL for BACKEND.

The updater derives the URL by trimming `chat/completions' off the
endpoint, so OpenAI backends on the Responses API (plain \"OpenAI\" and
\"openai-sub\") and non-OpenAI-compatible ones (Anthropic) cannot work --
gptel ships good static lists for those anyway.  Gemini and Ollama are
handled natively (Gemini still needs direct network access)."
  (or (and (fboundp 'gptel-gemini-p) (gptel-gemini-p backend))
    (and (fboundp 'gptel-ollama-p) (gptel-ollama-p backend))
    (and (gptel-openai-p backend)
      (not (and (fboundp 'gptel-openai-responses-p)
             (gptel-openai-responses-p backend)))
      (when-let ((ep (gptel-backend-endpoint backend)))
        (string-search "chat/completions" ep)))))

(defun cc/gptel--sync-model-updater-backends ()
  "Expose fetchable `cc/gptel-backends' entries to `gptel-model-updater'.
It targets backends held in variables, so bind one per eligible registry
entry (see `cc/gptel--model-updater-can-fetch-p') and point
`gptel-model-updater-backends' at them.  Safe to re-run after
`doom/reload' rebuilds the registry with fresh structs."
  (when (boundp 'gptel-model-updater-backends)
    (let (syms)
      (maphash (lambda (id backend)
                 (when (cc/gptel--model-updater-can-fetch-p backend)
                   (let ((sym (intern (format "cc/gptel-backend--%s" id))))
                     (set sym backend)
                     (push sym syms))))
        cc/gptel-backends)
      (setq gptel-model-updater-backends (nreverse syms)))))

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

  ;; ChatGPT subscription (OAuth); run `gptel-openai-oauth-login' once.
  (when cc/gptel-enable-openai-sub
    (puthash 'openai-sub
      (gptel-make-openai-oauth "openai-sub")
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

  ;; Custom OpenAI-compatible vendors
  (dolist (vendor cc/gptel-openai-compatible-vendors)
    (cc/gptel--register-vendor vendor))

  ;; Select the requested backend, or a known available fallback.
  (if-let ((backend (cc/gptel-select-backend)))
    (setq gptel-backend backend)
    (setq gptel-backend nil)
    (display-warning
      'cc-ai
      "No gptel backend is configured; set a provider key or enable GitHub Copilot."
      :warning)))

;; gptel-model-updater: `M-x gptel-model-updater-update-all' (or the
;; transient) fetches model ids from each backend's models endpoint.
;; Fetched lists are in-memory only; re-run after each restart.
(use-package! gptel-model-updater
  :after gptel
  :commands (gptel-model-updater-update-all
              gptel-model-updater-update-backend
              gptel-model-updater-transient))

;; Expose the registry to the updater once both are loaded; re-runs on
;; `doom/reload' since the registry is rebuilt with fresh structs.
(after! (gptel gptel-model-updater)
  (cc/gptel--sync-model-updater-backends))

;; Reach the updater from `gptel-menu', right after the "-m" model infix.
;; Best-effort: gptel is unpinned, so tolerate upstream menu changes.
(after! gptel-transient
  (unless (ignore-errors (transient-get-suffix 'gptel-menu "-u"))
    (condition-case err
      (transient-append-suffix 'gptel-menu "-m"
        '("-u" "Update model lists" gptel-model-updater-transient))
      (error (display-warning 'cc-ai
               (format "Couldn't add model-updater to gptel-menu: %s"
                 (error-message-string err))
               :warning)))))

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
