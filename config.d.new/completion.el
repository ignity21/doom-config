;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/completion.el

(defun cc/minuet--use-deepseek ()
  (setopt
    minuet-provider 'openai-fim-compatible
    minuet-auto-suggestion-throttle-delay 1.5 ; Increase to reduce costs
    minuet-auto-suggestion-debounce-delay 0.6 ; Increase to reduce costs
    minuet-request-timeout 20)
  (plist-put minuet-openai-fim-compatible-options :end-point "https://api.deepseek.com/beta/completions")
  (plist-put minuet-openai-fim-compatible-options :api-key (lambda () cc/deepseek-api-key))
  (plist-put minuet-openai-fim-compatible-options :model "deepseek-v4-flash")
  (minuet-set-optional-options minuet-openai-fim-compatible-options :max_tokens 150)
  (minuet-set-optional-options minuet-openai-fim-compatible-options :top_p 0.85)
  )

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

;; copilot
(use-package! copilot
  :init
  (add-hook!
    (prog-mode emacs-lisp-mode yaml-ts-mode
      conf-mode)
    #'copilot-mode) ; 'copilot-nes-mode
  :config
  (setopt
    copilot-indent-offset-warning-disable t
    copilot-nes-idle-delay 0.5)
  (map!
    :desc "Copilot mode" "C-c t o" #'copilot-mode
    :desc "Copilot NES mode" "C-c t n" #'copilot-nes-mode
    (:map copilot-completion-map
      "M-RET" #'copilot-accept-completion
      "<right>" #'copilot-accept-completion
      "M-<right>" #'copilot-accept-completion-by-word
      "C-l" #'copilot-accept-completion-by-line
      "<end>" #'copilot-accept-completion-by-line
      "C-c C-e" #'copilot-panel-complete
      "M-n" #'copilot-next-completion
      "M-p" #'copilot-previous-completion)))

(use-package! minuet
  :init
  (add-hook! (prog-mode yaml-mode conf-mode) #'minuet-auto-suggestion-mode)
  :config
  (map! :map minuet-active-mode-map
    "M-RET" #'minuet-accept-suggestion
    "<right>" #'minuet-accept-suggestion
    "M-l" #'minuet-accept-suggestion-line
    "<end>" #'minuet-accept-suggestion-line
    "M-i" #'minuet-show-suggestion
    "M-n" #'minuet-next-suggestion
    "M-p" #'minuet-previous-suggestion
    "C-g" #'minuet-dismiss-suggestion)
  (cc/minuet--use-deepseek)
  )
