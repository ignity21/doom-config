;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/bindings/config.el

;; Unset global keybindings
(undefine-key! global-map
  "C-z"
  "C-x C-z"
  "C-x 8" ; emoji
  "C-h 4" ; info other window
  "C-<wheel-up>" ; text scale up
  "C-<wheel-down>" ; text scale down
  )

(define-key! global-map
  "M-<wheel-up>" #'mouse-wheel-text-scale
  "M-<wheel-down>" #'mouse-wheel-text-scale
  )

;; which-key configuration
(which-key-mode +1)
;; (remove-hook! 'doom-first-input-hook #'which-key-mode)
;; (add-hook! 'doom-first-buffer-hook
;;            :append
;;            #'which-key-mode)
(setopt doom-leader-key nil
  doom-localleader-key nil
  doom-leader-alt-key "C-c M-;"
  doom-localleader-alt-key "C-c M-l")

(after! which-key
  (setopt which-key-sort-order 'which-key-description-order
    which-key-use-C-h-commands t))

;; Adding which-key descriptions
(which-key-add-key-based-replacements
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
  "C-." "<lookup>")

(after! projectile
  (keymap-set projectile-mode-map "C-c p c"
    'projectile-command-map)
  (which-key-add-keymap-based-replacements projectile-mode-map
    "C-c p c" "<projectile-command>"
    "C-c p c 4" "other-window"
    "C-c p c 5" "other-frame"
    "C-c p c x" "execute"
    "C-c p c s" "search"))

;; C-x keybindings
(map! :prefix "C-x"
  ;; C-x n -- narrow
  :desc "ibuffer" "C-b" #'ibuffer
  (:prefix ("n" . "<narrow>")
    "g" nil)
  (:prefix-map ("a" . "<agenda>")
    :desc "Find agenda file" "f" #'+default/find-in-notes
    :desc "Agenda view""a" #'org-agenda
    :desc "Agenda capture" "c" #'org-capture
    :desc "Agenda archive" "A" #'org-agenda-archive))

;; C-h keybindings
(map! :prefix "C-h"
  :desc "Woman" "w" #'woman)

;; C-c keybindings
(map! :prefix "C-c"
  ;; C-c a -- ai
  (:prefix
    ("a" . "<ai>"))

  ;; C-c d -- debug
  (:prefix-map
    ("d". "<debug>")
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
  (:prefix-map
    ("e" . "<edit>")
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
        :desc "Add word to dict""a" #'+spell/add-word
        :desc "Remove word" "r" #'+spell/remove-word
        (:unless (modulep! :checkers spell +flyspell)
          :desc "Toggle spell-fu" "t" #'spell-fu-mode
          :desc "Reset word cache" "k" #'spell-fu-reset
          :desc "Next error" "n" #'spell-fu-goto-next-error
          :desc "Previous error" "p" #'spell-fu-goto-previous-error)))
    (:prefix
      ("w" . "<writing>")
      (:when (modulep! :checkers grammar)
        (:desc "Grammar check" "c" #'langtool-check
          :desc "Grammar correct" "e" #'langtool-correct-buffer)))
    )

  ;; C-c i -- insert
  (:prefix-map
    ("i" . "<insert>")
    :desc "From clipboard" "c" #'+default/yank-pop
    (:when (modulep! :completion corfu)
      :desc "From dict" "d" #'cape-dict
      :desc "Emoji" "e" #'cape-emoji
      :desc "Nerd font" "n" #'nerd-icons-insert
      :desc "dabbrev" "a" #'cape-dabbrev)
    (:when (modulep! :editor snippets)
      :desc "Insert snippet" "s" #'yas-insert-snippet)
    )

  ;; C-c n --- notes
  (:prefix-map
    ("n" . "<note>")
    (:when (modulep! :lang org +roam)
      :desc "Fleet note" "j" #'org-roam-dailies-find-today
      :desc "Choose roam dir" "n" #'cc/org-roam-choose-dir
      :desc "Find note" "f" #'org-roam-node-find
      :desc "Find ref" "r" #'org-roam-ref-find
      :desc "Insert node" "i" #'org-roam-node-insert
      :desc "Capture" "c" #'org-roam-capture
      :desc "Show backlinks" "b" #'org-roam-buffer-toggle
      :desc "Show backlinks(dedicated)" "B" #'org-roam-buffer-display-dedicated
      :desc "Sync db" "s" #'org-roam-db-sync
      :desc "Refile node" "w" #'org-roam-refile
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
        :desc "Visit node" "v" #'org-roam-node-visit)
      ))

  ;; C-c o --- open
  ;; (:prefix-map
  ;;   ("o" . "<open>")
  ;;   :desc "Color list" "C" #'list-colors-display
  ;;   (:when (modulep! :term vterm)
  ;;     :desc "vterm" "t" #'+vterm/toggle)
  ;;   (:when (modulep! :tools ein)
  ;;     (:prefix-map ("j" . "<jupyter>")
  ;;       :desc "Jupyter run" "r" #'ein:run
  ;;       :desc "Jupyter login" "l" #'ein:login
  ;;       :desc "Jupyter stop" "s" #'ein:stop))
  ;;   )

  ;; C-c p --- project
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

  ;; C-c P -- profiling
  (:prefix-map
    ("P" . "<profiling>")
    :desc "Start profiling" "s" #'profiler-start
    :desc "Stop profiling" "t" #'profiler-stop
    :desc "Report" "r" #'profiler-report
    )

  ;; C-c t -- toggle
  (:prefix-map
    ("t" . "<toggle>")
    (:when (modulep! :editor word-wrap)
      :desc "Visual line mode" "v" #'+word-wrap-mode)
    (:when (modulep! :checkers spell)
      :desc "Spelling check" "s" #'spell-fu-mode)
    (:when (modulep! :lang org +present)
      :map org-mode-map
      :desc "Org presentation" "p" #'org-tree-slide-mode)
    )

  ;; C-c w --- workspace
  (:prefix-map
    ("w" . "<workspace>")
    (:when (modulep! :ui workspaces)
      :desc "Make workspace" "m" #'+workspace/new-named
      :desc "Save workspace" "s" #'+workspace/save
      :desc "Load workspace" "l" #'+workspace/load
      :desc "Remove workspace" "r" #'+workspace/delete
      :desc "Switch workspace" "o" #'+workspace/switch-to
      :desc "Display workspaces" "d" #'+workspace/display)
    :desc "Kill other buffers" "k" #'doom/kill-other-buffers
    :desc "Kill all buffers" "K" #'doom/kill-all-buffers
    ;; session
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
      :desc "Describe snippets" "d" #'yas-describe-tables))
  )
