;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/editor.el

(when (modulep! :editor fold)
  (map! :map (prog-mode-map
               python-mode-map
               yaml-mode-map
               org-mode-map)
    :prefix ("C-c <TAB>" . "<fold>")
    :desc "Fold/Unfold" "<TAB>" #'+fold/toggle
    :desc "Fold all" "f" #'hs-hide-all
    :desc "Fold level" "l" #'hs-hide-level
    :desc "Unfold all" "u" #'hs-show-all))

(when (modulep! :editor multiple-cursors)
  (map! :map prog-mode-map
    :desc "Mark previous line like this" "C-<left>"
    #'mc/mark-previous-like-this
    :desc "Mark next line like this" "C-<right>"
    #'mc/mark-next-like-this
    :map multiple-cursors-mode-map
    "<return>" nil))

(when (modulep! :editor snippets)
  (remove-hook! 'yas-minor-mode-hook #'+corfu-add-yasnippet-capf-h)
  ;; (when (modulep! :tools lsp)
  ;;   (after! lsp-mode
  ;;     (remove-hook! 'completion-at-point-functions #'lsp-completion-at-point)
  ;;     (add-hook! 'completion-at-point-functions (cape-capf-super
  ;;                                                #'lsp-completion-at-point
  ;;                                                #'yasnippet-capf)))
  ;;   )
  (map! :map yas-minor-mode-map
    "C-c &" nil
    "M-/" #'yas-insert-snippet))

(when (modulep! :editor word-wrap)
  (+global-word-wrap-mode +1)
  (dolist (mode '(prog-mode yaml-mode emacs-lisp-mode python-mode c++-mode))
    (add-to-list '+word-wrap-disabled-modes mode))
  (when (modulep! :term vterm)
    (add-to-list '+word-wrap-disabled-modes 'vterm-mode)))
