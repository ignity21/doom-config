;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/checkers.el
(defvar cc/personal-aspell-en-dict "~/spell-fu/en.pws"
  "Path to the personal aspell dictionary for English.")

(when (modulep! :checkers spell)
  (setopt
   spell-fu-global-mode nil
   spell-fu-idle-delay 0.5
   spell-fu-word-delimit-camel-case t
   ispell-dictionary "en_US")

  (after! spell-fu
    (if (file-exists-p cc/personal-aspell-en-dict)
        (spell-fu-dictionary-add
         (spell-fu-get-personal-dictionary "en" cc/personal-aspell-en-dict))
      (warn "Personal aspell dictionary not found: %s" cc/personal-aspell-en-dict))

    ;; exclude what faces to preform spellchecking on
    (setf
     (alist-get 'prog-mode +spell-excluded-faces-alist)
     '(font-lock-constant-face
       font-lock-string-face))

    ;; TODO: may consider theme-specific colors in the future
    (custom-set-faces!
      `(spell-fu-incorrect-face :underline (:style wave :color ,(doom-color 'blue))))
    )
  )
