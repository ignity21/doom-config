;; -*- no-byte-compile: t; -*-
;;; cc/ai/packages.el

(package! transient
  :pin "1f7039ef8d548d6fe858084fcbeae7588eba4190") ; 0.12.0

(package! magit
  :pin "c800f79c2061621fde847f6a53129eca0e8da728") ; 4.5.0

;; (package! aider
;;   :recipe (:host github :repo "tninja/aider.el" ))

(package! ai-code
  :recipe (:host github
           :repo "tninja/ai-code-interface.el"
           :files ("*.el")))

;; (package! aidermacs
;;   :recipe (:host github
;;            :repo "MatthewZMD/aidermacs"
;;            :files ("*.el")))

(package! gptel :recipe (:nonrecursive t))

(package! mcp
  :recipe (:host github
           :repo "lizqwerscott/mcp.el"
           :files ("*.el")))
