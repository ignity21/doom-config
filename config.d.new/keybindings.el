;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/keybindings.el

(defvar-keymap cc/file-keymap
  :doc "Prefix keymap for file commands.")
(defvar-keymap cc/search-keymap
  :doc "Prefix keymap for search commands.")
(defvar-keymap cc/lookup-keymap
  :doc "Prefix keymap for lookup commands.")
(defvar-keymap cc/code-lookup-keymap
  :doc "Prefix keymap for code lookup commands.")
(defvar-keymap cc/code-keymap
  :doc "Prefix keymap for code commands.")
(defvar-keymap cc/run-eval-keymap
  :doc "Prefix keymap for run and evaluation commands.")
(defvar-keymap cc/local-mode-keymap
  :doc "Prefix keymap for major-mode-local commands.")
(defvar-keymap cc/open-keymap
  :doc "Prefix keymap for opening tools and resources.")

(defconst cc/file-map-prefix "C-c f")
(defconst cc/search-map-prefix "C-c s")
(defconst cc/lookup-map-prefix "C-c l")
(defconst cc/code-lookup-map-prefix "C-c .")
(defconst cc/code-map-prefix "C-c c")
(defconst cc/run-map-prefix "<f5>")
(defconst cc/local-mode-map-prefix "C-c m")
(defconst cc/open-map-prefix "C-c o")

(keymap-global-set cc/file-map-prefix cc/file-keymap)
(keymap-global-set cc/search-map-prefix cc/search-keymap)
(keymap-global-set cc/lookup-map-prefix cc/lookup-keymap)
(keymap-global-set cc/code-lookup-map-prefix cc/code-lookup-keymap)
(keymap-global-set cc/code-map-prefix cc/code-keymap)
(keymap-global-set cc/run-map-prefix cc/run-eval-keymap)
(keymap-global-set cc/local-mode-map-prefix cc/local-mode-keymap)
(keymap-global-set cc/open-map-prefix cc/open-keymap)

(after! which-key
  (which-key-add-key-based-replacements
    cc/file-map-prefix "file"
    cc/search-map-prefix "search"
    cc/lookup-map-prefix "lookup"
    cc/code-lookup-map-prefix "lookup(code)"
    cc/code-map-prefix "code"
    cc/run-map-prefix "run"
    cc/local-mode-map-prefix "local-mode"
    cc/open-map-prefix "open"))

;; Global keybindings
(map! "M-." #'+lookup/definition
  "M-," #'better-jumper-jump-backward
  "C-s" #'consult-line
  ;; "C-x C-e" #'+eval/buffer-or-region
  )

;; F5 prefix
(map! :prefix cc/run-map-prefix
  :desc "Quick run shell" "<f5>" #'quickrun-shell
  :desc "Quick run" "q" #'quickrun
  :desc "Eval buffer or region" "b" #'+eval/buffer-or-region
  :desc "Eval line" "e" #'+eval/line-or-region
  :desc "Eval print" "p" #'eval-print-last-sexp
  :desc "Send to REPL" "s" #'+eval/send-region-to-repl
  :desc "Open REPL" "r" #'+eval/open-repl-other-window)

;; C-c l prefix
(map! :prefix cc/lookup-map-prefix
  :desc "Find file" "f" #'+lookup/file
  :desc "Search online" "o" #'+lookup/online
  :desc "Find in dictionary" "d" #'+lookup/dictionary-definition
  :desc "Replace with synonyms" "D" #'+lookup/synonyms)

;; C-c . prefix
(map! :prefix cc/code-lookup-map-prefix
  (:when (modulep! :tools lsp -eglot)
    :desc "Consult symbol in project" "p" #'consult-lsp-symbols)
  (:when (modulep! :tools lsp +eglot)
    :desc "Consult symbol in project" "p" #'consult-eglot-symbols
    :desc "Call hierarchy" "c" #'eglot-show-call-hierarchy
    :desc "Type hierarchy" "T" #'eglot-show-type-hierarchy)
  :desc "Consult symbol in File" "f" #'+vertico/search-symbol-at-point
  :desc "Find references" "r" #'+lookup/references
  :desc "Find implementations" "i" #'+lookup/implementations
  :desc "Find type definition" "t" #'+lookup/type-definition
  :desc "Find documentation" "d" #'+lookup/documentation)

;; C-c s prefix
(map! :prefix cc/search-map-prefix
  :desc "Consult imenu" "i" #'consult-imenu
  :desc "Consult imenu-multi" "I" #'consult-imenu-multi
  :desc "Consult ripgrep" "d" #'consult-ripgrep
  :desc "Consult flycheck" "f" #'consult-flycheck
  :desc "Search project" "p" #'+vertico/project-search)

;; C-c f prefix
(map! :prefix cc/file-map-prefix
  :desc "Locate" "l" #'consult-locate
  :desc "Recent files" "r" #'consult-recent-file
  :desc "Copy this file" "c" #'doom/copy-this-file
  :desc "Delete this file" "d" #'doom/delete-this-file
  :desc "Move this file" "m" #'doom/move-this-file
  :desc "Find file under here (-r)" "." #'+default/find-file-under-here
  :desc "Find agenda file" "a" #'+default/find-in-notes
  :desc "Find in doom" "p" #'doom/find-file-in-private-config
  :desc "Browse in doom" "P" #'doom/open-private-config
  :desc "Find in emacsd" "e" #'doom/find-file-in-emacsd
  :desc "Browse in emacsd" "E" #'doom/browse-in-emacsd
  :desc "Sudo this file" "s" #'doom/sudo-this-file
  :desc "Find file" "f" #'find-file
  :desc "Sudo find file" "F" #'doom/sudo-find-file
  :desc "Copy file path" "y" #'+default/yank-buffer-path
  (:when (modulep! :tools upload)
    (:prefix ("u" . "<upload>")
      :desc "Upload" "u" #'ssh-deploy-upload-handler
      :desc "Upload forced" "U" #'ssh-deploy-upload-handler-forced
      :desc "Download" "d" #'ssh-deploy-download-handler
      :desc "Delete" "D" #'ssh-deploy-delete-handler
      :desc "Browse remote" "b" #'ssh-deploy-browse-remote-handler
      :desc "Remote changes" "e" #'ssh-deploy-remote-changes-handler
      :desc "Open remote file" "f" #'ssh-deploy-open-remote-file-handler
      :desc "Diff" "x" #'ssh-deploy-diff-handler))
  )

(map! :prefix cc/code-map-prefix
  :desc "Compile" "c" #'+default/compile
  :desc "Format buffer or region" "f" #'+format/region-or-buffer
  :desc "Treesit install" "t" #'treesit-install-language-grammar
  (:prefix ("m" . "<minor-mode>")
    :desc "Flycheck" "f" #'flycheck-mode
    :desc "Line Numbers" "l" #'doom/toggle-line-numbers
    (:when (modulep! :ui indent-guides)
      :desc "Indent guides" "i" #'indent-bars-mode)
    )
  (:when (modulep! :tools lsp -eglot)
    :map lsp-mode-map
    :desc "Code actions" "a" #'lsp-execute-code-action
    :desc "Rename symbol" "r" #'lsp-rename
    :desc "imenu" "i" #'lsp-ui-imenu
    (:prefix ("m" . "<minor-mode>")
      :desc "Inlay hints" "i" #'lsp-inlay-hints-mode
      )
    (:prefix ("s" . "<lsp-session>")
      :desc "List sessions" "l" #'lsp-describe-session
      :desc "Disconnect" "q" #'lsp-disconnect
      :desc "Restart" "r" #'lsp-workspace-restart
      :desc "Shutdown" "d" #'lsp-workspace-shutdown
      :desc "Add folder" "a" #'lsp-workspace-folders-add
      :desc "Remove folder" "k" #'lsp-workspace-folders-remove
      :desc "Remove all folders" "K" #'lsp-workspace-remove-all-folders
      :desc "Unblock folders" "b" #'lsp-workspace-blocklist-remove
      :desc "Switch client" "s" #'+lsp/switch-client)
    )
  (:when (modulep! :tools lsp +eglot)
    :map eglot-managed-mode-map
    (:prefix ("R" . "<refactor>")
      :desc "Refactor inline" "r" #'eglot-code-action-inline
      :desc "Refactor extract" "e" #'eglot-code-action-extract
      :desc "Refactor rewrite" "w" #'eglot-code-action-rewrite
      )
    (:prefix ("s" . "<eglot-session>")
      :desc "Shutdown" "d" #'eglot-shutdown
      :desc "Reconnect" "r" #'eglot-reconnect)
    :desc "Rename symbol" "r" #'eglot-rename
    :desc "Code actions" "a" #'eglot-code-action-quickfix)
  )

(map! :prefix cc/open-map-prefix
  :desc "New frame" "f" #'make-frame
  :desc "Terminal" "t" #'ghostel
  (:when (modulep! :tools docker)
    :desc "Docker" "d" #'docker)
  (:when (modulep! :app calendar)
    :desc "Calendar" "c" #'+calendar/open-calendar)
  (:when (modulep! :tools llm)
    (:prefix ("l" . "<gptel>")
      :desc "Open chat" "l" #'gptel
      :desc "Menu" "m" #'gptel-menu
      :desc "Send region(or before)" "s" #'gptel-send
      :desc "Rewrite" "r" #'gptel-rewrite
      :desc "Add text to ctx" "a" #'gptel-add
      :desc "Add file to ctx" "f" #'gptel-add-file
      :desc "Quick explain" "e" #'gptel-quick
      ;; org-mode
      :desc "Limit ctx to Heading" "o" #'gptel-org-set-topic
      :desc "Set org property" "O" #'gptel-org-set-properties
      ))
  )
