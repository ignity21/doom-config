;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/completion.el

;; vertico
(map!
 (:map cc/ctl-dot-lookup-map
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
  :desc "Search flycheck" "f" #'consult-flycheck
  :desc "Search project" "p" #'+vertico/project-search)
 (:map cc/ctl-c-file-map
  :desc "locate" "l" #'consult-locate
  :desc "Recent files" "r" #'consult-recent-file))

;; corfu cape
(map! :map corfu-map
      "C-c C-l" #'+corfu/move-to-minibuffer
      "C-SPC" #'corfu-insert-separator
      "M-RET" #'corfu-quick-comple
      "C-h" #'corfu-popupinfo-toggle
      :map corfu-popupinfo-map
      "C-M-p" #'corfu-popupinfo-scroll-down
      "C-M-n" #'corfu-popupinfo-scroll-up.)

;; copilot
(use-package! copilot
  :hook ((emacs-lisp-mode) . copilot-mode)
  :init
  (add-hook! (prog-mode yaml-pro-ts-mode conf-mode) #'copilot-mode) ; #'copilot-nes-mode
  :config
  (setopt copilot-indent-offset-warning-disable t)
  (map! :desc "Copilot mode" "C-c t o" #'copilot-mode
        (:map copilot-completion-map
              "<tab>" #'copilot-accept-completion
              "<right>" #'copilot-accept-completion
              "C-<tab>" #'copilot-accept-completion-by-word
              "M-<right>" #'copilot-accept-completion-by-word
              "C-l" #'copilot-accept-completion-by-line
              "<end>" #'copilot-accept-completion-by-line
              "C-c C-e" #'copilot-panel-complete
              "M-n" #'copilot-next-completion
              "M-p" #'copilot-previous-completion)
        (:map copilot-mode-map
         :desc "Copilot Chat" "C-c o o" #'copilot-chat
         (:prefix ("C-c l o" . "<copilot>")
          :desc "Send to copilot" "o" #'copilot-chat-send
          :desc "Send region" "r" #'copilot-chat-send-region
          :desc "Stop" "k" #'copilot-chat-stop
          :desc "Reset" "R" #'copilot-chat-reset))))
