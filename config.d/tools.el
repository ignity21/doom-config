;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/tools.el
(when (modulep! :tools debugger)
  (remove-hook! 'dap-ui-mode-hook #'dap-ui-controls-mode)
  (remove-hook! 'dap-mode-hook #'dap-tooltip-mode)
  (setq! dap-auto-configure-features '(locals breakpoints)))

(when (modulep! :tools lsp)
  (add-hook! 'lsp-mode-hook
             #'lsp-enable-which-key-integration
             ;; (defun cc/lsp-ensure-copilot-server ()
             ;;   (lsp-ensure-server 'copilot-ls))
             )
  (when (modulep! :editor snippets)
    (add-hook! 'lsp-mode-hook #'yas-minor-mode-on))

  (setq! lsp-idle-delay 0.8
         lsp-copilot-enabled nil
         lsp-headerline-breadcrumb-enable t
         lsp-signature-render-documentation nil
         lsp-enable-snippet nil

         lsp-ui-sideline-show-diagnostics t
         lsp-ui-sideline-show-code-actions t
         lsp-ui-sideline-show-symbol nil
         lsp-ui-sideline-delay 1

         lsp-ui-imenu-buffer-position 'left
         lsp-ui-imenu-auto-refresh t
         lsp-imenu-detailed-outline nil
         lsp-imenu-index-symbol-kinds '(Namespace Class Constructor Method Property Function)

         lsp-inline-completion-enable nil
         ;; lsp-inline-completion-idle-delay 0.5

         ;; lsp-ui-doc
         lsp-ui-doc-enable nil)
  (map! :map lsp-mode-map
        "s-l" nil
        :desc "Format buffer" "C-c c f" #'lsp-format-buffer

        :map lsp-ui-mode-map
        :desc "Lsp Symbol List" "C-c t i" #'lsp-ui-imenu

        :map lsp-ui-imenu-mode-map
        :desc "Next line" "n" #'next-line
        :desc "Previous line" "p" #'previous-line
        :desc "Next kind" "M-n" #'lsp-ui-imenu--next-kind
        :desc "Previous kind" "M-p" #'lsp-ui-imenu--prev-kind
        :desc "Refresh imenu" "g" #'lsp-ui-imenu--refresh)
  (map! :after lsp-inline-completion
        :map lsp-inline-completion-active-map
        "M-<return>" #'lsp-inline-completion-accept
        "C-n" nil
        "C-p" nil
        "M-n" #'lsp-inline-completion-next
        "M-p" #'lsp-inline-completion-prev)
  )

(when (modulep! :tools pdf)
  (map! (:map pdf-view-mode-map
         :prefix ("C-c t p" . "<pdf-toggles>")
         :desc "Toggle slice mode" "s"
         #'pdf-view-auto-slice-minor-mode
         :desc "Toggle themed mode" "t"
         #'pdf-view-themed-minor-mode))
  (setq-hook! 'pdf-view-mode-hook
    pdf-view-themed-minor-mode 1))
