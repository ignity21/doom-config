;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d/keybindings.el
;;
;; The single source of truth for keybindings: global prefix keymaps, global
;; unbinds/rebinds, which-key descriptions, and every entry that hangs off a
;; global prefix (even mode-local ones, guarded with `:map' / `:when').
;; Package-internal keymaps (vertico-map, corfu-map, treemacs-mode-map, ...)
;; stay in their theme/module files.

;; Autoloads for commands bound below whose packages do not autoload them
;; themselves (previously in the never-executed modules/cc/bindings/autoload.el).
(autoload 'org-capture-goto-target "org-capture" nil t)
(autoload 'recentf-open-files "recentf" nil t)
(autoload 'projectile-recentf "projectile" nil t)
(when (modulep! :tools upload)
  (dolist (handler '(ssh-deploy-upload-handler
                      ssh-deploy-download-handler
                      ssh-deploy-delete-handler
                      ssh-deploy-browse-remote-handler
                      ssh-deploy-remote-changes-handler
                      ssh-deploy-upload-handler-forced
                      ssh-deploy-open-remote-file-handler
                      ssh-deploy-diff-handler))
    (autoload handler "ssh-deploy" nil t)))

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
(defvar-keymap cc/gptel-keymap
  :doc "Prefix keymap for gptel commands.")
(defvar-keymap cc/toggle-keymap
  :doc "Prefix keymap for toggle commands.")

(defconst cc/file-map-prefix "C-c f")
(defconst cc/search-map-prefix "C-c s")
(defconst cc/lookup-map-prefix "C-c l")
(defconst cc/code-lookup-map-prefix "C-c .")
(defconst cc/code-map-prefix "C-c c")
(defconst cc/run-map-prefix "<f5>")
(defconst cc/local-mode-map-prefix "C-c m")
(defconst cc/open-map-prefix "C-c o")
(defconst cc/gptel-map-prefix "C-c g")
(defconst cc/toggle-map-prefix "C-c t")

(keymap-global-set cc/file-map-prefix cc/file-keymap)
(keymap-global-set cc/search-map-prefix cc/search-keymap)
(keymap-global-set cc/lookup-map-prefix cc/lookup-keymap)
(keymap-global-set cc/code-lookup-map-prefix cc/code-lookup-keymap)
(keymap-global-set cc/code-map-prefix cc/code-keymap)
(keymap-global-set cc/run-map-prefix cc/run-eval-keymap)
(keymap-global-set cc/local-mode-map-prefix cc/local-mode-keymap)
(keymap-global-set cc/open-map-prefix cc/open-keymap)
(keymap-global-set cc/gptel-map-prefix cc/gptel-keymap)
(keymap-global-set cc/toggle-map-prefix cc/toggle-keymap)

(which-key-mode +1)
(setopt doom-leader-key "C-c M-;"
  doom-localleader-key "C-c M-l"
  doom-leader-alt-key "C-c M-;"
  doom-localleader-alt-key "C-c M-l")

(after! which-key
  (setopt which-key-sort-order 'which-key-description-order
    which-key-use-C-h-commands t)
  (which-key-add-key-based-replacements
    cc/file-map-prefix "<file>"
    cc/search-map-prefix "<search>"
    cc/lookup-map-prefix "<lookup>"
    cc/code-lookup-map-prefix "<lookup(code)>"
    cc/code-map-prefix "<code>"
    cc/run-map-prefix "<run>"
    cc/local-mode-map-prefix "<local-mode>"
    cc/open-map-prefix "<open>"
    cc/gptel-map-prefix "<gptel>"
    cc/toggle-map-prefix "<toggle>"
    "C-c 1" "<checker>"
    "C-x <RET>" "coding-system"
    "M-s h" "highlight"
    "C-x n" "<narrow>"
    "C-x r" "register"
    "C-x t" "tab"
    "C-x w" "win-select"
    "C-x x" "buffer-ops"
    "C-x 4" "other-window"
    "C-x 5" "other-frame"
    "C-x p" "project"
    "C-h d p" "doom/help-packages"
    "C-c M-d" "doom/leader"
    "C-c M-d l" "doom/localleader"
    "C-." "<lookup>"))

;; Global keybindings
(map! "M-." #'+lookup/definition
  "M-," #'better-jumper-jump-backward
  "C-s" #'consult-line
  ;; "C-x C-e" #'+eval/buffer-or-region
  )

;; Global unbinds and rebinds
(map! "C-z" nil
  "C-x C-z" nil
  "C-x 8" nil                            ; emoji
  "C-h 4" nil                            ; info other window
  "C-<wheel-up>" nil                     ; text scale up
  "C-<wheel-down>" nil                   ; text scale down
  "M-<wheel-up>" #'mouse-wheel-text-scale
  "M-<wheel-down>" #'mouse-wheel-text-scale)
(when (modulep! :emacs undo)
  (map! "C-z" #'undo))

(after! projectile
  (keymap-set projectile-mode-map "C-c p c" 'projectile-command-map)
  (which-key-add-keymap-based-replacements projectile-mode-map
    "C-c p c" "<projectile-command>"
    "C-c p c 4" "other-window"
    "C-c p c 5" "other-frame"
    "C-c p c x" "execute"
    "C-c p c s" "search"))

;; C-x prefix supplements
(map! :prefix "C-x"
  :desc "ibuffer" "C-b" #'ibuffer
  (:prefix ("n" . "<narrow>")
    "g" nil)
  (:prefix-map ("a" . "<agenda>")
    :desc "Find agenda file" "f" #'+default/find-in-notes
    :desc "Agenda view" "a" #'org-agenda
    :desc "Agenda capture" "c" #'org-capture
    :desc "Agenda archive" "A" #'org-agenda-archive))

;; C-h prefix supplements
(map! :prefix "C-h"
  :desc "Woman" "w" #'woman)

;; C-c t prefix -- toggles: minor modes and buffer/UI state (the single home
;; for minor-mode toggles; code-specific ones used to live under `C-c c m').
(map! :map cc/toggle-keymap
  :desc "Flycheck" "f" #'flycheck-mode
  :desc "Line numbers" "l" #'doom/toggle-line-numbers
  (:when (modulep! :ui indent-guides)
    :desc "Indent guides" "i" #'indent-bars-mode)
  (:when (modulep! :editor word-wrap)
    :desc "Visual line mode" "v" #'+word-wrap-mode)
  (:when (modulep! :checkers spell)
    :desc "Spelling check" "s" #'spell-fu-mode)
  (:when (modulep! :cc completion +minuet)
    :desc "Minuet automatic suggestions" "c" #'cc/minuet-toggle-auto-suggestion)
  (:when (modulep! :cc completion +copilot)
    :desc "Copilot mode" "o" #'copilot-mode
    :desc "Copilot NES mode" "n" #'copilot-nes-mode))
(when (modulep! :tools lsp -eglot)
  (map! :map lsp-mode-map
    :desc "Inlay hints" "C-c t h" #'lsp-inlay-hints-mode))
(when (modulep! :tools lsp +eglot)
  (map! :map eglot-mode-map
    :desc "Inlay hints" "C-c t h" #'eglot-inlay-hints-mode))
(when (modulep! :lang org +present)
  (map! :map org-mode-map
    :desc "Org presentation" "C-c t p" #'org-tree-slide-mode))

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
  :desc "Find file (fd)" "f" #'+lookup/file
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
  (:when (modulep! :tools lsp -eglot)
    :map lsp-mode-map
    :desc "Code actions" "a" #'lsp-execute-code-action
    :desc "Rename symbol" "r" #'lsp-rename
    :desc "imenu" "i" #'lsp-ui-imenu
    :desc "Flycheck" "e" #'lsp-ui-flycheck-list
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
    :map eglot-mode-map
    (:prefix ("r" . "<refactor>")
      :desc "Rename symbol" "r" #'eglot-rename
      :desc "Refactor inline" "i" #'eglot-code-action-inline
      :desc "Refactor extract" "e" #'eglot-code-action-extract
      :desc "Refactor rewrite" "w" #'eglot-code-action-rewrite
      )
    (:prefix ("s" . "<eglot-session>")
      :desc "Shutdown" "d" #'eglot-shutdown
      :desc "Reconnect" "r" #'eglot-reconnect)
    :desc "Code actions" "a" #'eglot-code-actions)
  )

(map! :prefix cc/open-map-prefix
  :desc "New frame" "f" #'make-frame
  :desc "Terminal" "t" #'ghostel
  (:when (modulep! :tools docker)
    :desc "Docker" "d" #'docker)
  (:when (modulep! :app calendar)
    :desc "Calendar" "c" #'+calendar/open-calendar)
  (:prefix ("p" . "<profiling>")
    :desc "Start profiling" "s" #'profiler-start
    :desc "Stop profiling" "t" #'profiler-stop
    :desc "Report" "r" #'profiler-report))

(map! :prefix cc/gptel-map-prefix
  (:when (modulep! :tools llm)
    :desc "Open chat" "c" #'gptel
    :desc "Menu" "m" #'gptel-menu
    :desc "Send region(or before)" "s" #'gptel-send
    :desc "Rewrite" "r" #'gptel-rewrite
    :desc "Add text to ctx" "a" #'gptel-add
    :desc "Add file to ctx" "f" #'gptel-add-file
    :desc "Quick explain" "e" #'gptel-quick
    ;; org-mode
    :desc "Limit ctx to Heading" "o" #'gptel-org-set-topic
    :desc "Set org property" "O" #'gptel-org-set-properties))

;; C-c prefixes migrated from modules/cc/bindings
(map! :prefix "C-c"
  ;; C-c a -- ai
  (:prefix-map ("a" . "<ai>")
    (:when (modulep! :cc ai)
      :desc "AI code menu" "a" #'ai-code-menu))

  ;; C-c d -- debug
  (:prefix-map ("d" . "<debug>")
    (:when (modulep! :tools debugger)
      :map prog-mode-map
      :desc "Start" "d" #'+debugger/start
      :desc "Stop" "s" #'+debugger/quit)
    (:when (modulep! :tools lsp)
      :desc "dap-debug" "g" #'dap-debug
      :desc "dap-hydra" "h" #'dap-hydra
      :map lsp-mode-map
      :desc "Edit dap template" "t" #'dap-debug-edit-template
      (:prefix ("b" . "<breakpoint>")
        :desc "Toggle" "b" #'dap-breakpoint-toggle
        :desc "Delete all" "d" #'dap-breakpoint-delete-all)))

  ;; C-c e -- edit/writing
  (:prefix-map ("e" . "<edit>")
    (:when (modulep! :editor multiple-cursors)
      (:prefix ("m" . "<multicursors>")
        :desc "Edit lines" "e" #'mc/edit-lines
        :desc "Mark next like this" "n" #'mc/mark-next-like-this
        :desc "Mark previous like this" "p" #'mc/mark-previous-like-this
        :desc "Mark all like this" "a" #'mc/mark-all-like-this))
    (:when (modulep! :emacs undo)
      (:prefix ("u" . "<undo>")
        :desc "Undo" "u" #'undo-fu-only-undo
        :desc "Undo tree redo" "r" #'undo-fu-only-redo
        :desc "Undo tree redo all" "R" #'undo-fu-redo-all))
    (:when (modulep! :checkers spell)
      (:prefix ("s" . "<spell>")
        :desc "Correct this word" "c" #'+spell/correct
        :desc "Add word to dict" "a" #'+spell/add-word
        :desc "Remove word" "r" #'+spell/remove-word
        (:unless (modulep! :checkers spell +flyspell)
          :desc "Toggle spell-fu" "t" #'spell-fu-mode
          :desc "Reset word cache" "k" #'spell-fu-reset
          :desc "Next error" "n" #'spell-fu-goto-next-error
          :desc "Previous error" "p" #'spell-fu-goto-previous-error)))
    (:prefix ("w" . "<writing>")
      (:when (modulep! :checkers grammar)
        :desc "Grammar check" "c" #'langtool-check
        :desc "Grammar correct" "e" #'langtool-correct-buffer
        :desc "Grade level" "l" #'writegood-grade-level
        :desc "Reading ease" "r" #'writegood-reading-ease)))

  ;; C-c i -- insert
  (:prefix-map ("i" . "<insert>")
    :desc "From clipboard" "c" #'+default/yank-pop
    (:when (modulep! :completion corfu)
      :desc "From dict" "d" #'cape-dict
      :desc "Emoji" "e" #'cape-emoji
      :desc "Nerd font" "n" #'nerd-icons-insert
      :desc "dabbrev" "a" #'cape-dabbrev)
    (:when (modulep! :editor snippets)
      :desc "Insert snippet" "s" #'yas-insert-snippet))

  ;; C-c n -- notes
  (:prefix-map ("n" . "<note>")
    (:when (modulep! :lang org +roam)
      :desc "Fleet note" "j" #'org-roam-dailies-find-today
      :desc "Capture note by category" "n" #'cc/org-roam-capture-in-category
      :desc "Find note (create in Inbox)" "f" #'cc/org-roam-node-find
      :desc "Find ref" "r" #'org-roam-ref-find
      :desc "Insert node" "i" #'org-roam-node-insert
      :desc "Capture" "c" #'org-roam-capture
      :desc "Show backlinks" "b" #'org-roam-buffer-toggle
      :desc "Show backlinks(dedicated)" "B" #'org-roam-buffer-display-dedicated
      :desc "Sync db" "s" #'org-roam-db-sync
      :desc "Refile node" "w" #'org-roam-refile
      :desc "Move current node to category" "m" #'cc/org-roam-move-current-node
      (:prefix ("a" . "<alias>")
        :desc "Add alias" "a" #'org-roam-alias-add
        :desc "Remove alias" "r" #'org-roam-alias-remove)
      (:prefix ("r" . "<ref>")
        :desc "Add ref" "a" #'org-roam-ref-add
        :desc "Remove ref" "r" #'org-roam-ref-remove
        :desc "Find ref" "f" #'org-roam-ref-find)
      (:prefix ("t" . "<tag>")
        :desc "Add tag" "a" #'org-roam-tag-add
        :desc "Remove tag" "r" #'org-roam-tag-remove)
      (:prefix ("d" . "<by date>")
        :desc "Goto date" "d" #'org-roam-dailies-goto-date
        :desc "Capture date" "c" #'org-roam-dailies-capture-date
        :desc "Goto tomorrow" "m" #'org-roam-dailies-goto-tomorrow
        :desc "Goto today" "t" #'org-roam-dailies-goto-today
        :desc "Goto yesterday" "y" #'org-roam-dailies-goto-yesterday
        :desc "Find dir" "f" #'org-roam-dailies-find-directory)
      (:map org-roam-mode-map
        :desc "Visit node" "v" #'org-roam-node-visit)))

  ;; C-c p -- project
  (:prefix-map ("p" . "<project>")
    :desc "Open current editorconfig" "e" #'editorconfig-find-current-editorconfig
    :desc "Search project" "s" #'+default/search-project
    :desc "Switch project" "p" #'projectile-switch-project
    :desc "Recent files" "R" #'projectile-recentf
    :desc "Replace in project" "r" #'projectile-replace
    :desc "Find file" "f" #'projectile-find-file
    :desc "Project dired" "d" #'+default/browse-project
    :desc "Search symbol" "." #'+default/search-project-for-symbol-at-point
    :desc "Add dir local variable" "v" #'add-dir-local-variable
    :desc "Add file local variable" "V" #'add-file-local-variable)

  ;; C-c w -- workspace
  (:prefix-map ("w" . "<workspace>")
    (:when (modulep! :ui workspaces)
      :desc "Make workspace" "m" #'+workspace/new-named
      :desc "Load workspace" "l" #'+workspace/load
      :desc "Remove workspace" "r" #'+workspace/delete
      :desc "Switch workspace" "o" #'+workspace/switch-to
      :desc "Display workspaces" "d" #'+workspace/display
      :desc "Save current workspace" "s" #'cc/workspace-save-current)
    :desc "Kill other buffers" "k" #'doom/kill-other-buffers
    :desc "Kill all buffers" "K" #'doom/kill-all-buffers
    :desc "Load last session" "w" #'doom/quickload-session)

  ;; C-c y -- yasnippets
  (:when (modulep! :editor snippets)
    (:prefix-map ("y" . "<snippets>")
      :desc "New snippet" "n" #'+snippets/new
      :desc "Edit snippet" "e" #'+snippets/edit
      :desc "Find snippet" "f" #'+snippets/find
      :desc "Browse snippets" "b" #'+default/browse-templates
      :desc "aya create" "m" #'aya-create
      :desc "aya expand" "a" #'aya-expand
      :desc "Describe snippets" "d" #'yas-describe-tables)))
