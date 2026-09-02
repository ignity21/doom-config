;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/doctor/doctor.el

;; Doom does not support a global doctor.el.  This module exists solely to
;; hold `doom doctor' checks that don't belong to any single cc/ or
;; cc-langs/ module -- e.g. checks for Doom's own modules or for
;; cross-cutting external tools.  A check that clearly belongs to one
;; specific module's feature should live in that module's doctor.el
;; instead, not here.

;; The `:checkers grammar' module drives LanguageTool through `langtool'.
;; LanguageTool is an external dependency that is not bundled, so make sure
;; it is reachable either as a command or as a configured jar.
(when (modulep! :checkers grammar)
  (unless (executable-find "languagetool")
    (warn! "Couldn't find LanguageTool for `:checkers grammar'. Install the `languagetool' command.")))
