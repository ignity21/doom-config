;;; -*- lexical-binding: t; no-byte-compile: t; -*-;;;
;;; config.d/completion.el

;; (when (modulep! :completion vertico)
;;   (map! :map vertico-map
;;         "C-l" #'vertico-directory-delete-word
;;         "C-M-p" #'vertico-previous-group
;;         "C-M-n" #'vertico-next-group
;;         "C-SPC" #'+vertico/embark-preview
;;         :desc "Export to buffer" "C-c C-p" #'embark-export))

(when (modulep! :completion corfu)
  (map! :map corfu-map
        "C-c C-p" #'+corfu/move-to-minibuffer
        "C-SPC" #'corfu-insert-separator
        "<tab>" #'corfu-quick-complete
        :map corfu-popupinfo-map
        "C-M-p" #'corfu-popupinfo-scroll-down
        "C-<up>" #'corfu-popupinfo-scroll-down
        "C-M-n" #'corfu-popupinfo-scroll-up
        "C-<down>" #'corfu-popupinfo-scroll-up
        "C-M-a" #'corfu-popupinfo-beginning
        "C-M-e" #'corfu-popupinfo-end)

  (after! cape
    (map! :mode (text-mode yaml-mode)
          "M-/" #'cape-dabbrev))
  (custom-set-faces!
    '(corfu-current :background "moccasin"))
  )
