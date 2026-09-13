;; -*- no-byte-compile: t; -*-
;;; cc/ai/packages.el

;; (package! aider
;;   :recipe (:host github :repo "tninja/aider.el" ))

;; `:build (:not autoloads)': the package's own generated autoloads file
;; embeds bare `transient-define-prefix' forms (`ai-code-insert-menu',
;; `ai-code-eca-menu') under a plain `;;;###autoload' cookie instead of the
;; `;;;###autoload (autoload ...)' stub pattern transient-based commands
;; need.  Emacs's autoload generator doesn't recognize the macro, so it
;; copies the form verbatim; loading that file (as `doom sync' does for
;; every package) then calls `transient-define-prefix' before `transient'
;; is loaded, erroring with "Symbol's function definition is void".  Our
;; own `use-package!' already declares `ai-code-menu' via `:commands',
;; which is enough to lazy-load the package, so skip the broken file.
(package! ai-code
  :recipe (:host github
            :repo "tninja/ai-code-interface.el"
            :files ("*.el")
            :build (:not autoloads)))

;; Fetch backend model lists from providers' /v1/models endpoints.
(package! gptel-model-updater
  :recipe (:host github
            :repo "cat-emacs/gptel-model-updater"
            :files ("*.el" (:exclude "*-tests.el"))))

;; Track upstream gptel instead of Doom's `:tools llm' pin: built-in model
;; lists for OpenAI / Anthropic / openai-sub only move on gptel releases,
;; and the OAuth backend has no models endpoint to fetch from.  Accepts
;; the upstream-API-churn risk against this module's heavy gptel config.
(unpin! gptel)

;; (package! mcp
;;   :recipe (:host github
;;             :repo "lizqwerscott/mcp.el"
;;             :files ("*.el")))
