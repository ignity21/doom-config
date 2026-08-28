;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/defaults.el

;; For relative line numbers, set this to `relative'.
(setopt display-line-numbers-type t) ; absolute line numbers

(defcustom cc/tramp-user-bin-directory "~/.local/bin"
  "Directory on remote hosts that TRAMP adds to its executable search path."
  :type 'directory
  :group 'cc-defaults)

(after! tramp
  (add-to-list 'tramp-remote-path cc/tramp-user-bin-directory))
