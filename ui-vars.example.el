;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; ui-vars.el — machine-local UI preferences

;; Copy ui-vars.example.el to ui-vars.el and adjust for this machine.
;; Usually keep ui-vars.el as a regular local file, not a symlink to a shared
;; copy: monitors, scaling, and installed fonts differ between machines.
;; Loaded after custom-vars.el.  Restart Emacs after changing font settings.

;; Fonts
(setopt
  ;; Integer sizes are pixels; floats mean points in `font-spec'.
  cc/font-size 16
  cc/emoji-font (font-spec :family "Noto Color Emoji" :size cc/font-size)
  doom-font (font-spec :family "Hack Nerd Font Mono" :size cc/font-size)
  doom-symbol-font (font-spec :family "Sarasa Mono SC" :size cc/font-size)
  doom-variable-pitch-font (font-spec :family "LXGW WenKai" :size cc/font-size)
  doom-big-font-increment (/ cc/font-size 4) ; increase by 25%
  )

;; Themes
(setopt
  cc/light-ef-theme 'ef-cyprus
  cc/dark-ef-theme 'ef-dream)
