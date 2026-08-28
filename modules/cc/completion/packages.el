;; -*- no-byte-compile: t; -*-
;;; cc/completion/packages.el

;; Code-completion backend: pick one at install time via the module flag
;; (+minuet or +copilot).  This runs in an isolated environment where
;; custom-vars.el is not loaded, so a defcustom cannot be read here -- the
;; choice must be a module flag.

(package! minuet :recipe
  (:host github :repo "milanglacier/minuet-ai.el" :files ("*.el")))

(package! copilot
  :recipe (:host github
            :repo "copilot-emacs/copilot.el"
            :files ("*.el")))

(if (modulep! +minuet)
    (disable-packages! copilot)
  (disable-packages! minuet))
