;; -*- no-byte-compile: t; -*-
;;; cc/ai/packages.el

;; (package! aider
;;   :recipe (:host github :repo "tninja/aider.el" ))

(package! ai-code
  :recipe (:host github
            :repo "tninja/ai-code-interface.el"
            :files ("*.el"))
  :pin "589307b8496ac8530d6de06cd7189d827b72e4b0")

;; Fetch backend model lists from providers' /v1/models endpoints.
(package! gptel-model-updater
  :recipe (:host github
            :repo "cat-emacs/gptel-model-updater"
            :files ("*.el" (:exclude "*-tests.el")))
  :pin "ce53fa9667f8c4f83566085c3d0486631f704bc8")

;; Track upstream gptel instead of Doom's `:tools llm' pin: built-in model
;; lists for OpenAI / Anthropic / openai-sub only move on gptel releases,
;; and the OAuth backend has no models endpoint to fetch from.  Accepts
;; the upstream-API-churn risk against this module's heavy gptel config.
(unpin! gptel)

;; (package! mcp
;;   :recipe (:host github
;;             :repo "lizqwerscott/mcp.el"
;;             :files ("*.el")))
