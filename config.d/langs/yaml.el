;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/langs/yaml.el

(defcustom cc/yaml-indent-offset 2
  "Number of spaces to use for indentation in YAML files."
  :type 'integer
  :group 'cc)

;; Emacs 30's yaml-ts-mode has no indentation engine.  Reuse yaml-mode's
;; mature implementation without changing the active major mode.
(require 'yaml-mode)

;; Explicitly indent the new line instead of letting `newline' also
;; reindent the preceding YAML line through electric indentation.
(after! yaml-mode
  (keymap-set yaml-mode-map "RET" #'newline-and-indent))

(after! yaml-ts-mode
  (keymap-set yaml-ts-mode-map "RET" #'newline-and-indent))

(defun cc/yaml-ts-setup ()
  "Configure indentation and spell checking for `yaml-ts-mode'."
  (setq-local yaml-indent-offset cc/yaml-indent-offset
              indent-line-function #'yaml-indent-line)
  (spell-fu-mode -1))

(add-hook 'yaml-ts-mode-hook #'cc/yaml-ts-setup)
