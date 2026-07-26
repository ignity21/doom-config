;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/tools.el
(when (modulep! :tools debugger)
  (remove-hook! 'dap-ui-mode-hook #'dap-ui-controls-mode)
  (remove-hook! 'dap-mode-hook #'dap-tooltip-mode)
  (setopt dap-auto-configure-features '(locals breakpoints)))

(when (modulep! :tools pdf)
  (map! (:map pdf-view-mode-map
          :prefix ("C-c t p" . "<pdf-toggles>")
          :desc "Toggle slice mode" "s"
          #'pdf-view-auto-slice-minor-mode
          :desc "Toggle themed mode" "t"
          #'pdf-view-themed-minor-mode))
  (setq-hook! 'pdf-view-mode-hook
    pdf-view-themed-minor-mode 1))
