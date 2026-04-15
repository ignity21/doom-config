;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/keybindings.el

(defmacro cc/def-keymap (name key desc)
  "Define a named keymap and bind it to KEY with DESC for which-key.
NAME is the variable name (unquoted), KEY is the key string, DESC is the which-key description."
  (let ((full-desc (concat "<" desc ">")))
    `(progn
       (defvar ,name (make-sparse-keymap) ,full-desc)
       (keymap-set global-map ,key ,name)
       (which-key-add-key-based-replacements ,key ,full-desc))))
(cc/def-keymap cc/ctl-c-file-map "C-c f" "file")
(cc/def-keymap cc/ctl-c-search-map "C-c s" "search")
(cc/def-keymap cc/ctl-dot-lookup-map "C-." "lookup")
(cc/def-keymap cc/f5-run-map "<f5>" "run")

(which-key-add-key-based-replacements "C-c l" "<local>")

;; Global keybindings
(map! "M-." #'+lookup/definition
      "M-," #'better-jumper-jump-backward
      "C-s" #'consult-line
      ;; "C-x C-e" #'+eval/buffer-or-region
      )

;; F5 prefix
(map! :map cc/f5-run-map
      :desc "Eval buffer or region" "e" #'+eval/buffer-or-region
      :desc "Eval line" "l" #'+eval/line-or-region
      :desc "Send to REPL" "s" #'+eval/send-region-to-repl
      :desc "Open REPL" "r" #'+eval/open-repl-other-window)

;; C-. prefix
(map! :map cc/ctl-dot-lookup-map
      :desc "Find symbol" "s" #'+vertico/search-symbol-at-point
      :desc "Find references" "r" #'+lookup/references
      :desc "Find implementations" "i" #'+lookup/implementation
      :desc "Find type definition" "t" #'+lookup/type-definition
      :desc "Find documentation" "RET" #'+lookup/documentation
      :desc "Find file" "f" #'+lookup/file
      :desc "Search online" "o" #'+lookup/online
      :desc "Find in dictionary" "d" #'+lookup/dictionary-definition
      :desc "Replace with synonyms" "D" #'+lookup/synonyms)

;; C-c s prefix
(map! :map cc/ctl-c-search-map
      :desc "Consult imenu" "i" #'consult-imenu
      :desc "Consult imenu-multi" "I" #'consult-imenu-multi
      :desc "Consult ripgrep" "d" #'consult-ripgrep
      :desc "Consult flycheck" "f" #'consult-flycheck
      :desc "Search project" "p" #'+vertico/project-search)

;; C-c f prefix
(map! :map cc/ctl-c-file-map
      :desc "Locate" "l" #'consult-locate
      :desc "Recent files" "r" #'consult-recent-file)
