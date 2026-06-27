;;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; cc/dev/config.el

;; :tools
;; ein (jupyter notebook)
(when (modulep! :tools ein)
  (after! ein
    ;; for jupyter-lab, otherwise use "notebook"
    (setopt ein:jupyter-server-use-subcommand "server")))

;; [Packages]
;; Rainbow mode: highlight color string
(use-package! rainbow-mode
  :hook ((emacs-lisp-mode html-mode css-mode scss-mode) . rainbow-mode)
  :config
  (add-hook! 'rainbow-mode-hook
    (hl-line-mode (if rainbow-mode -1 +1))))
