;; -*- no-byte-compile: t; -*-
;;; cc/better-defaults/packages.el

(disable-packages! company-dict
                   eglot)

(package! rainbow-mode)

(package! copilot
  :recipe (:host github
           :repo "copilot-emacs/copilot.el"
           :files ("*.el")))

;; (package! codeium
;;   :recipe (:host github
;;            :repo "Exafunction/codeium.el"
;;            :files ("*.el")))

;; (disable-packages! minuet)
;; (package! minuet
;;   :recipe (:host github
;;            :repo "milanglacier/minuet-ai.el"
;;            :files ("minuet.el")))
