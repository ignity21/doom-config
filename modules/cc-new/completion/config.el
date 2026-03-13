;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/completion/config.el

(when (modulep! :completion vertico)
  ;; vertico
  (map!
   (:prefix "C-."
    :desc "Find symbol" "s" #'+vertico/search-symbol-at-point)
   (:map vertico-map
         "C-M-n" #'vertico-next-group
         "C-M-p" #'vertico-previous-group
         "C-o" #'+vertico/embark-preview
         "C-l" #'vertico-directory-delete-word))

  ;; consult
  (map!
   "C-s" #'consult-line
   (:prefix "C-c s"
    :desc "ripgrep" "g" #'consult-ripgrep
    :desc "imenu" "i" #'consult-imenu
    :desc "imenu-multi" "I" #'consult-imenu-multi)
   (:prefix "C-c f"
    :desc "locate" "l" #'consult-locate
    :desc "Recent files" "r" #'consult-recent-file)))
