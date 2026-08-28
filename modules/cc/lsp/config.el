;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/lsp/config.el

(when (modulep! :tools lsp -eglot)
  (after! lsp-mode
    (setopt
      lsp-inlay-hint-enable t
      lsp-log-io nil
      lsp-keymap-prefix "C-c ;"
      ;; Doom's :editor format +onsave owns formatting on save.  Do not invoke a
      ;; second formatter from lsp-mode.
      lsp-format-buffer-on-save nil
      lsp-auto-guess-root t
      lsp-keep-workspace-alive nil
      lsp-idle-delay 0.8
      lsp-copilot-enabled nil
      lsp-enable-snippet nil

      ;; UI settings
      lsp-lens-enable t
      lsp-headerline-breadcrumb-enable nil
      lsp-ui-doc-enable nil
      lsp-ui-sideline-enable t
      lsp-ui-sideline-delay 1.5
      lsp-ui-sideline-show-diagnostics t
      lsp-ui-sideline-show-code-actions nil
      lsp-ui-sideline-show-symbol nil
      lsp-modeline-diagnostics-enable t
      lsp-enable-on-type-formatting nil
      lsp-ui-doc-show-with-mouse t
      lsp-signature-render-documentation t
      lsp-ui-imenu-buffer-position 'left
      lsp-ui-imenu-auto-refresh t
      lsp-imenu-detailed-outline nil
      lsp-imenu-index-symbol-kinds '(Namespace Class Constructor Method Property Function)
      lsp-inline-completion-enable nil)))

(when (modulep! :tools lsp -eglot)
  (add-hook! 'lsp-mode-hook #'lsp-enable-which-key-integration)
  (when (modulep! :editor snippets)
    (add-hook! 'lsp-mode-hook #'yas-minor-mode-on))
  (map! :map lsp-ui-imenu-mode-map
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
    "M-p" #'lsp-inline-completion-prev))

(when (modulep! :tools lsp -eglot +booster)
  ;; emacs-lsp-booster configuration for lsp-mode
  (define-advice json-parse-buffer (:around (original-fn &rest args) cc/lsp-booster)
    "Try to parse emacs-lsp-booster bytecode before JSON."
    (or (when (equal (following-char) ?#)
          (let ((bytecode (read (current-buffer))))
            (when (byte-code-function-p bytecode)
              (funcall bytecode))))
      (apply original-fn args)))

  (define-advice lsp-resolve-final-command
    (:around (original-fn cmd &optional test?) cc/lsp-booster)
    "Prepend emacs-lsp-booster to local LSP commands when supported."
    (let ((result (funcall original-fn cmd test?)))
      (if (and (not test?)
            (not (file-remote-p default-directory))
            lsp-use-plists
            (not (functionp 'json-rpc-connection))
            (executable-find "emacs-lsp-booster"))
        (progn
          (when-let ((command (executable-find (car result))))
            (setcar result command))
          (cons "emacs-lsp-booster" result))
        result))))

(when (modulep! :tools lsp +eglot)
  (defun cc/eglot-events-enable ()
    (interactive)
    (setq eglot-events-buffer-config
      '(:size 2000000 :format full))
    (when-let ((server (eglot-current-server)))
      (eglot-reconnect server t)))

  (defun cc/eglot-events-disable ()
    (interactive)
    (setq eglot-events-buffer-config
      '(:size 0 :format full))
    (when-let ((server (eglot-current-server)))
      (eglot-reconnect server t)))

  (defun cc/eglot-events-toggle ()
    (interactive)
    (if (zerop (plist-get eglot-events-buffer-config :size))
      (cc/eglot-events-enable)
      (cc/eglot-events-disable)))

  (after! eglot
    (setopt eglot-extend-to-xref t)))
