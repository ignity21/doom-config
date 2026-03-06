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

;; Github Copilot
(use-package! copilot
  :hook ((emacs-lisp-mode) . copilot-mode)
  :init
  (add-hook! (prog-mode yaml-mode conf-mode) #'copilot-mode)
  ;; (when (modulep! :tools lsp)
  ;;   (unless lsp-copilot-enabled
  ;;     (add-hook! (prog-mode yaml-mode conf-mode) #'copilot-mode)))
  :config
  (setopt copilot-indent-offset-warning-disable t)
  ;; For Github Copilot compatibility
  ;; Cursor Jump to End of Line When Typing
  ;; If you are using whitespace-mode, make sure to remove newline-mark from whitespace-style.
  ;; TODO may not be needed anymore
  ;; (setopt whitespace-style (delq 'newline-mark whitespace-style))
  (map! :desc "Copilot mode" "C-c t a" #'copilot-mode
        :map copilot-completion-map
        "M-<return>" #'copilot-accept-completion
        "M-w" #'copilot-accept-completion-by-word
        "M-l" #'copilot-accept-completion-by-line
        "M-n" #'copilot-next-completion
        "M-p" #'copilot-previous-completion))

;; minuet configuration
(use-package! minuet
  :init
  (add-hook! (prog-mode yaml-mode conf-mode) #'minuet-auto-suggestion-mode)
  :config
  (map! :map minuet-active-mode-map
        "M-p" #'minuet-previous-suggestion
        "M-n" #'minuet-next-suggestion
        "M-<return>" #'minuet-accept-suggestion
        "M-l" #'minuet-accept-suggestion-line
        "C-g" #'minuet-dismiss-suggestion)
  (setopt minuet-auto-suggestion-debounce-delay 0.8
          minuet-auto-suggestion-throttle-delay 3.0
          minuet-request-timeout 10)
  (cc/minuet--use-claude)
  ;; (cc/minuet--use-ollama)
  )

;; codeium
;; (use-package! codeium
;;   :init
;;   TODO: (cape-capf-super #'lsp-completion-at-point #'codeium-completion-at-point)
;;   (add-to-list 'completion-at-point-functions #'codeium-completion-at-point)
;;   :config
;;   (setq use-dialog-box nil))
