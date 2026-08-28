;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc-langs/cpp/doctor.el

(unless (executable-find "insights")
    (warn! "Couldn't find cppinsights."))
