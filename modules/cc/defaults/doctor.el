;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/defaults/doctor.el

;; The `:checkers grammar' module drives LanguageTool through `langtool'.
;; LanguageTool is an external dependency that is not bundled, so make sure
;; it is reachable either as a command or as a configured jar.
(when (modulep! :checkers grammar)
  (unless (executable-find "languagetool")
    (warn! "Couldn't find LanguageTool for `:checkers grammar'. Install the `languagetool' command.")))
