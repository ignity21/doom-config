;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/langs/elisp.el

(setq-hook! 'emacs-lisp-mode-hook
  completion-at-point-functions
  `(cape-file
     ,(cape-capf-super #'elisp-completion-at-point #'yasnippet-capf)
     t
     cape-dabbrev))

(map! :map emacs-lisp-mode-map
  (:prefix "C-c c"
    :desc "Byte compile file" "c" #'byte-compile-file
    :desc "Disassemble" "d" #'disassemble
    :desc "Check parens" "]" #'check-parens))
