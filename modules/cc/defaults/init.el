;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/defaults/init.el

;; Font options are defined here rather than in config.d/theme.el because
;; custom-vars.el is loaded at the top of config.el and builds font specs from
;; `cc/font-size'.  When custom-vars.el leaves it unset, the default below is
;; derived from the display, which is already connected by the time Doom
;; loads module init files in a graphical session.

(defun cc/auto-font-size ()
  "Return a font pixel size suited to the current monitor.
Use the larger of a resolution-based size (monitor height / 72) and an 11pt
size at the monitor's physical DPI, clamped to 12..48.  Return 16 when no
graphical display is available (batch, terminal, or daemon startup)."
  (if (not (display-graphic-p))
      16
    (let* ((attrs (frame-monitor-attributes))
           (height (nth 3 (alist-get 'geometry attrs)))
           (height-mm (cadr (alist-get 'mm-size attrs)))
           (by-res (/ height 72.0))
           (by-dpi (if (and height-mm (> height-mm 0))
                       (* 11 (/ height (/ height-mm 25.4)) (/ 1.0 72))
                     0)))
      (max 12 (min 48 (round (max by-res by-dpi)))))))

(defcustom cc/font-size (cc/auto-font-size)
  "The default font size in pixels.
Defaults to a size derived from the display; see `cc/auto-font-size'."
  :type 'integer
  :group 'cc-ui)

(defcustom cc/emoji-font
  (font-spec :family "Noto Color Emoji" :size cc/font-size)
  "Emoji font, Must be a `font-spec'"
  :type 'sexp
  :group 'cc-ui)
