;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/completion.el

(map! :map vertico-map
      "C-M-n" #'vertico-next-group
      "C-M-p" #'vertico-previous-group
      "C-o" #'+vertico/embark-preview
      "C-l" #'vertico-directory-delete-word)

(map! :map corfu-map
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

;; copilot
(use-package! copilot
  :init
  (add-hook!
    (prog-mode emacs-lisp-mode yaml-ts-mode-hook conf-mode)
    #'copilot-mode) ; #'copilot-nes-mode
  :config
  (setopt copilot-indent-offset-warning-disable t)
  (map! :desc "Copilot mode" "C-c t o" #'copilot-mode
        (:map copilot-completion-map
              "M-RET" #'copilot-accept-completion
              "<right>" #'copilot-accept-completion
              "M-<right>" #'copilot-accept-completion-by-word
              "C-l" #'copilot-accept-completion-by-line
              "<end>" #'copilot-accept-completion-by-line
              "C-c C-e" #'copilot-panel-complete
              "M-n" #'copilot-next-completion
              "M-p" #'copilot-previous-completion)
        ;; (:map copilot-mode-map
        ;;  :desc "Copilot Chat" "C-c o o" #'copilot-chat
        ;;  (:prefix ("C-c c o" . "<copilot>")
        ;;   :desc "Send to copilot" "o" #'copilot-chat-send
        ;;   :desc "Send region" "r" #'copilot-chat-send-region
        ;;   :desc "Stop" "k" #'copilot-chat-stop
        ;;   :desc "Reset" "R" #'copilot-chat-reset))
        ;; )
        )
