;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/checkers.el

(when (and (modulep! :checkers syntax)
           (not (modulep! :checkers syntax +flymake)))
  (map! :map flycheck-mode-map
        "C-c !" nil
        :prefix "C-c"
        "C-p" #'flycheck-previous-error
        "C-n" #'flycheck-next-error
        "M-w" #'flycheck-copy-errors-as-kill
        (:prefix ("1" . "<checker>")
         :desc "First error" "a" #'flycheck-first-error
         :desc "Next error" "n" #'flycheck-next-error
         :desc "Previous error" "p" #'flycheck-previous-error
         :desc "Copy errors" "w" #'flycheck-copy-errors-as-kill
         :desc "Describe checker" "d" #'flycheck-describe-checker
         :desc "List errors" "l" #'flycheck-list-errors
         :desc "Setup checkers" "s" #'flycheck-verify-setup
         )))
