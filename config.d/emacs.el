;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/emacs.el

;; TODO: with rsync and ssh
(when (modulep! :emacs dired)
  (map! :after dired
    :map dired-mode-map
    "C-l" #'dired-up-directory
    "C-c C-r" nil
    "C-c C-e" nil
    (:prefix "C-c m"
      ;; :desc "Rsync" "r" #'dired-rsync
      :desc "Edit mode" "e" #'wdired-change-to-wdired-mode)))

(when (modulep! :emacs ibuffer)
  (map! :map ibuffer-mode-map
    "K" #'doom/kill-all-buffers))

(when (modulep! :emacs undo)
  (map! "C-z" #'undo-fu-only-undo))
