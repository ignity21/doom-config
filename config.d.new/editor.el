;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/editor.el

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
  (map! :map yas-minor-mode-map
    "C-c &" nil
    "M-/" #'yas-insert-snippet))

(when (modulep! :editor word-wrap)
  (+global-word-wrap-mode +1)
  (dolist (mode '(prog-mode yaml-mode emacs-lisp-mode python-mode c++-mode))
    (add-to-list '+word-wrap-disabled-modes mode))
  (when (modulep! :term vterm)
    (add-to-list '+word-wrap-disabled-modes 'vterm-mode)))

;; Rainbow mode: highlight color strings (moved from the retired cc/dev module).
(defun cc/rainbow-mode-toggle-hl-line ()
  "Disable `hl-line-mode' while `rainbow-mode' is on so colors stay readable."
  (hl-line-mode (if rainbow-mode -1 +1)))

(use-package! rainbow-mode
  :hook ((emacs-lisp-mode html-mode css-mode scss-mode) . rainbow-mode)
  :config
  (add-hook 'rainbow-mode-hook #'cc/rainbow-mode-toggle-hl-line))
