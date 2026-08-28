;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/completion.el
(map!
  :map vertico-map
  "C-M-n" #'vertico-next-group
  "C-M-p" #'vertico-previous-group
  "C-o" #'+vertico/embark-preview
  "C-l" #'vertico-directory-delete-char)

(map!
  :map corfu-map
  "C-c C-l" #'+corfu/move-to-minibuffer
  "C-SPC" #'corfu-insert-separator
  "M-SPC" #'corfu-insert-separator
  "<tab>" #'corfu-quick-complete
  "C-h" #'corfu-popupinfo-toggle
  :map corfu-popupinfo-map
  "C-M-p" #'corfu-popupinfo-scroll-down
  "C-M-n" #'corfu-popupinfo-scroll-up)

(after! corfu
  (setopt corfu-preselect 'directory))

(when (modulep! :editor snippets)
  (remove-hook! 'yas-minor-mode-hook #'+corfu-add-yasnippet-capf-h))

;; Inline AI code completion (minuet / copilot) lives in modules/cc/completion.
