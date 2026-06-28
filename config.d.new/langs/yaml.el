;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/langs/yaml.el

(defcustom cc/yaml-indent-offset 2
  "Number of spaces to use for indentation in YAML files."
  :type 'integer
  :group 'cc)

(setq-hook! 'yaml-ts-mode-hook
  standard-indent cc/yaml-indent-offset)
(add-hook! 'yaml-ts-mode-hook
  (spell-fu-mode -1))
