;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/lsp.el

(after! lsp-mode
  (setopt
    lsp-inlay-hint-enable t
    lsp-log-io nil
    lsp-keymap-prefix "C-c ;"
    lsp-format-buffer-on-save t
    lsp-auto-guess-root t
    lsp-keep-workspace-alive nil

    ;; UI settings
    lsp-lens-enable t
    lsp-headerline-breadcrumb-enable nil
    lsp-ui-doc-enable nil
    lsp-ui-sideline-enable t
    lsp-ui-sideline-delay 1.5
    lsp-ui-sideline-show-code-actions nil
    lsp-modeline-diagnostics-enable t
    lsp-enable-on-type-formatting nil
    lsp-ui-doc-show-with-mouse t
    lsp-signature-render-documentation t
    )
  )

(after! eglot
  (setopt eglot-send-changes-idle-time 0.5
    eglot-autoshutdown t))

(when (modulep! :tools lsp +lsp +booster)
  ;; emacs-lsp-booster configuration for lsp-mode
  (defun lsp-booster--advice-json-parse (old-fn &rest args)
    "Try to parse bytecode instead of json."
    (or
      (when (equal (following-char) ?#)
        (let ((bytecode (read (current-buffer))))
          (when (byte-code-function-p bytecode)
            (funcall bytecode))))
      (apply old-fn args)))
  (advice-add (if (progn (require 'json)
                    (fboundp 'json-parse-buffer))
                'json-parse-buffer
                'json-read)
    :around
    #'lsp-booster--advice-json-parse)

  (defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
    "Prepend emacs-lsp-booster command to lsp CMD."
    (let ((orig-result (funcall old-fn cmd test?)))
      (if (and (not test?)                             ;; for check lsp-server-present?
            (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
            lsp-use-plists
            (not (functionp 'json-rpc-connection))  ;; native json-rpc
            (executable-find "emacs-lsp-booster"))
        (progn
          (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $PATH)
            (setcar orig-result command-from-exec-path))
          (message "Using emacs-lsp-booster for %s!" orig-result)
          (cons "emacs-lsp-booster" orig-result))
        orig-result)))
  (advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command))

(when (modulep! :tools lsp +eglot +booster)
  (after! eglot-booster
    (setopt eglot-booster-io-only nil)))
