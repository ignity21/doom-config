;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/langs/sh.el

(defun cc/sh-set-default-shell ()
  "Default new `sh-mode' buffers to bash."
  (sh-set-shell "bash"))

(add-hook 'sh-mode-hook #'cc/sh-set-default-shell)
