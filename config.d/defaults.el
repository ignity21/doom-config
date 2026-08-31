;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/defaults.el

;; For relative line numbers, set this to `relative'.
(setopt display-line-numbers-type t) ; absolute line numbers

(defcustom cc/tramp-user-bin-directory "~/.local/bin"
  "Directory on remote hosts that TRAMP adds to its executable search path."
  :type 'directory
  :group 'cc-defaults)

(after! tramp
  (add-to-list 'tramp-remote-path cc/tramp-user-bin-directory))

;; Custom widget keybindings
(map!
  (:map widget-keymap
    "C-M-f" #'widget-forward
    "C-M-b" #'widget-backward)
  (:map widget-field-keymap
    "M-/" #'widget-complete
    "TAB" #'widget-complete))

;; TODO: with rsync and ssh
(when (modulep! :emacs dired)
  (map! :after dired
    :map dired-mode-map
    "C-l" #'dired-up-directory
    "C-c C-r" nil
    "C-c C-e" nil
    (:prefix "C-c c"
      ;; :desc "Rsync" "r" #'dired-rsync
      :desc "Edit mode" "e" #'wdired-change-to-wdired-mode)))

(when (modulep! :emacs ibuffer)
  (map! :map ibuffer-mode-map
    "K" #'doom/kill-all-buffers))

;; `C-z' unbind + rebind to `undo-fu-only-undo' lives in keybindings.el.
