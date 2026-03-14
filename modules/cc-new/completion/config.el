;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/completion/config.el

(when (modulep! :completion vertico)
  ;; vertico
  (map!
   (:map cc/ctl-c-lookup-map
    :desc "Find symbol" "s" #'+vertico/search-symbol-at-point)
   (:map vertico-map
         "C-M-n" #'vertico-next-group
         "C-M-p" #'vertico-previous-group
         "C-o" #'+vertico/embark-preview
         "C-l" #'vertico-directory-delete-word))

  ;; consult
  (map!
   "C-s" #'consult-line
   (:map cc/ctl-c-search-map
    :desc "imenu" "i" #'consult-imenu
    :desc "imenu-multi" "I" #'consult-imenu-multi
    :desc "Search directory" "d" #'consult-ripgrep
    :desc "Search project" "p" #'+vertico/project-search)
   (:map cc/ctl-c-file-map
    :desc "locate" "l" #'consult-locate
    :desc "Recent files" "r" #'consult-recent-file)))
