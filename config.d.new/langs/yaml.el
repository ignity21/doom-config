;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/langs/yaml.el

(defcustom cc/yaml-indent-offset 2
  "Number of spaces to use for indentation in YAML files."
  :type 'integer
  :group 'cc)

;; Emacs 30's yaml-ts-mode has no indentation engine.  Reuse yaml-mode's
;; mature implementation without changing the active major mode.
(require 'yaml-mode)

(defun cc/yaml-ts-setup ()
  "Configure indentation and spell checking for `yaml-ts-mode'."
  (setq-local yaml-indent-offset cc/yaml-indent-offset
              indent-line-function #'yaml-indent-line)
  (spell-fu-mode -1))

(add-hook 'yaml-ts-mode-hook #'cc/yaml-ts-setup)
