;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/completion/doctor.el

;; copilot dependencies (only when copilot is the selected backend)
(unless (modulep! +minuet)
  (unless (modulep! :tools editorconfig)
    (error! "copilot.el requires the :tools editorconfig module"))

  (unless (require 'jsonrpc nil t)
    (error! "copilot.el requires the jsonrpc package")))
