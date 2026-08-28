;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/checkers.el
(defcustom cc/personal-aspell-en-dict "~/spell-fu/en.pws"
  "Path to the personal aspell dictionary for English."
  :type 'file
  :group 'cc
  :safe #'stringp)

(setopt
  spell-fu-global-mode nil
  spell-fu-idle-delay 0.5
  spell-fu-word-delimit-camel-case t
  ispell-dictionary "en_US")

(after! spell-fu
  (if (file-exists-p cc/personal-aspell-en-dict)
    (setopt ispell-personal-dictionary cc/personal-aspell-en-dict)
    ;; (spell-fu-dictionary-add
    ;;   (spell-fu-get-personal-dictionary "en" cc/personal-aspell-en-dict))
    (warn "Personal aspell dictionary not found: %s" cc/personal-aspell-en-dict))

  ;; exclude what faces to preform spellchecking on in a specific mode
  (setf
    (alist-get 'prog-mode +spell-excluded-faces-alist)
    '(font-lock-constant-face
       font-lock-string-face))

  (setf (alist-get 'markdown-mode +spell-excluded-faces-alist)
    '(markdown-code-face
       markdown-reference-face
       markdown-link-face
       markdown-url-face
       markdown-markup-face
       markdown-html-attr-value-face
       markdown-html-attr-name-face
       markdown-html-tag-name-face))
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
