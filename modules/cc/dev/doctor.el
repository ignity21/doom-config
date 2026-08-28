;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/dev/doctor.el

;; copilot dependencies
(unless (modulep! :tools editorconfig)
  (error! "copilot.el requires the :editor editorconfig module"))

(unless (require 'jsonrpc nil t)
  (error! "copilot.el requires the jsonrpc package"))
