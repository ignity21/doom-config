;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/langs.el
;; sh
(add-hook! 'sh-mode-hook
  (defun cc/set-default-shell ()
    (sh-set-shell "bash")))
