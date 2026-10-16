;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/defaults/init.el

;; Font options must exist before config.el loads the personal variable files.

(defcustom cc/font-size 16
  "The default font size in pixels.
Set this integer in `ui-vars.el' before constructing font specs.
Font specs are rebuilt when that file is loaded; restart Emacs after editing."
  :type 'integer
  :group 'cc-ui)

(defcustom cc/emoji-font
  (font-spec :family "Noto Color Emoji" :size cc/font-size)
  "Emoji font, Must be a `font-spec'"
  :type 'sexp
  :group 'cc-ui)
