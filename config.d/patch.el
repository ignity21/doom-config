;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/patch.el

(defadvice! cc/guard-kill-buffer-and-windows (buf)
  :before-while #'doom-kill-buffer-and-windows
  (buffer-live-p buf))
