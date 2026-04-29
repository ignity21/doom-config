;;; -*- lexical-binding: t; no-byte-compile: t; -*-

;;; cc/theme/init.el
(defcustom cc/mono-font
  (string-trim-right
    (font-get-system-font) " [0-9]+$")
  "The default monospace font for the system."
  :type 'string
  :group 'cc-ui)

(defcustom cc/unicode-font
  (string-trim-right
    (font-get-system-normal-font) " [0-9]+$")
  "The default unicode font for the system."
  :type 'string
  :group 'cc-ui)

(defcustom cc/emoji-font
  "Noto Color Emoji"
  "The default emoji font for the system."
  :type 'string
  :group 'cc-ui)

(defcustom cc/font-size 16
  "The default monospace font size."
  :type 'integer
  :group 'cc-ui)

(defcustom cc/light-theme 'modus-operandi-tinted
  "The default light theme."
  :type 'symbol
  :group 'cc-ui)

(defcustom cc/dark-theme 'modus-vivendi-tinted
  "The default dark theme."
  :type 'symbol
  :group 'cc-ui)
