;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/checkers.el

(when (modulep! :checkers spell)
  (setopt spell-fu-idle-delay 0.5
          spell-fu-word-delimit-camel-case t
          ispell-dictionary "en_US")

  ;; exclude what faces to preform spellchecking on
  (setf
   (alist-get 'prog-mode +spell-excluded-faces-alist)
   '(font-lock-constant-face
     font-lock-string-face))

  (custom-set-faces!
    `(spell-fu-incorrect-face :underline (:style wave :color ,(doom-color 'blue))))


  (add-hook! 'spell-fu-mode-hook
    (defun add-personal-dictionaries ()
      (spell-fu-dictionary-add
       (spell-fu-get-personal-dictionary "en" cc/personal-aspell-en-dict))))
  )

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
