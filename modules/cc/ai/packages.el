;; -*- no-byte-compile: t; -*-
;;; cc/ai/packages.el

;; (package! aider
;;   :recipe (:host github :repo "tninja/aider.el" ))



;; (package! ai-code
;;   :recipe (:host github
;;            :repo "tninja/ai-code-interface.el"
;;            :files ("*.el")))

(package! aidermacs
  :recipe (:host github
           :repo "MatthewZMD/aidermacs"
           :files ("*.el")))

(package! gptel :recipe (:nonrecursive t))

(package! mcp
  :recipe (:host github
           :repo "lizqwerscott/mcp.el"
           :files ("*.el")))
