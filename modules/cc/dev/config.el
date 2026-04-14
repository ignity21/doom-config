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

;; minuet configuration
;; (use-package! minuet
;;   :init
;;   (add-hook! (prog-mode yaml-mode conf-mode) #'minuet-auto-suggestion-mode)
;;   :config
;;   (map! :map minuet-active-mode-map
;;         "M-i" #'minuet-show-suggestion
;;         "M-p" #'minuet-previous-suggestion
;;         "M-n" #'minuet-next-suggestion
;;         "M-<return>" #'minuet-accept-suggestion
;;         "M-l" #'minuet-accept-suggestion-line
;;         "C-g" #'minuet-dismiss-suggestion)
;;   (setopt minuet-auto-suggestion-debounce-delay 0.8
;;           minuet-auto-suggestion-throttle-delay 3.0
;;           minuet-request-timeout 10)
;;   (cc/minuet--use-gemini)
;;   ;; (cc/minuet--use-ollama)
;;   )

;; codeium
;; (use-package! codeium
;;   :init
;;   TODO: (cape-capf-super #'lsp-completion-at-point #'codeium-completion-at-point)
;;   (add-to-list 'completion-at-point-functions #'codeium-completion-at-point)
;;   :config
;;   (setq use-dialog-box nil))
