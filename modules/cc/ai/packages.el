;; -*- no-byte-compile: t; -*-
;;; cc/ai/packages.el

;; (package! aider
;;   :recipe (:host github :repo "tninja/aider.el" ))

(package! ai-code
  :recipe (:host github
            :repo "tninja/ai-code-interface.el"
            :files ("*.el"))
  :pin "589307b8496ac8530d6de06cd7189d827b72e4b0")

;; (package! mcp
;;   :recipe (:host github
;;             :repo "lizqwerscott/mcp.el"
;;             :files ("*.el")))
