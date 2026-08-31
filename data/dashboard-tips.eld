((:id consult-ripgrep
  :topic "Consult"
  :text "Use C-c s d to search the current project with ripgrep."
  :weight 6)
 (:id consult-buffer-search
  :topic "Consult"
  :text "Use C-s to filter the current buffer without leaving your position."
  :weight 5)
 (:id vertico-embark-preview
  :topic "Vertico"
  :text "While completing, C-o previews the candidate through Embark."
  :weight 4)
 (:id corfu-quick-complete
  :topic "Corfu"
  :text "In the completion popup, press TAB to finish a quick candidate."
  :weight 4)
 (:id minuet-toggle
  :topic "Minuet"
  :text "Toggle automatic suggestions with C-c t c; accept with M-RET."
  :weight 6
  :requires minuet)
 (:id minuet-dismiss
  :topic "Minuet"
  :text "Dismiss an unwanted suggestion with C-g and keep typing."
  :weight 3
  :requires minuet)
 (:id copilot-toggle
  :topic "Copilot"
  :text "When the Copilot backend is enabled, C-c t o toggles Copilot mode."
  :weight 4
  :requires copilot)
 (:id gptel-chat
  :topic "Gptel"
  :text "Open a chat with C-c g c, then use C-c g s to send context."
  :weight 6)
 (:id gptel-context
  :topic "Gptel"
  :text "Add the current region or buffer context with C-c g a before asking."
  :weight 4)
 (:id ai-code-menu
  :topic "AI code"
  :text "C-c a is a prefix; press C-c a a to open the AI code menu."
  :weight 4)
 (:id project-switch
  :topic "Projectile"
  :text "Switch projects with C-c p p, then find a file with C-c p f."
  :weight 6)
 (:id project-search
  :topic "Projectile"
  :text "Use C-c p s for a project search when you already know the project."
  :weight 5)
 (:id eglot-actions
  :topic "Eglot"
  :text "In an Eglot buffer, use C-c c a for code actions and C-c c r r to rename."
  :weight 5)
 (:id eglot-symbols
  :topic "Eglot"
  :text "Use C-c . p to browse project symbols and C-c . c for call hierarchy."
  :weight 4)
 (:id python-backend
  :topic "Python"
  :text "Set cc/python-lsp-backend in .dir-locals.el to choose a per-project LSP backend."
  :weight 3)
 (:id format-buffer
  :topic "Formatting"
  :text "Format the active region or buffer with C-c c f."
  :weight 5)
 (:id flycheck
  :topic "Flycheck"
  :text "Toggle checking with C-c t f and inspect diagnostics from C-c s f."
  :weight 4)
 (:id org-roam-find
  :topic "Org-roam"
  :text "Use C-c n f to find a note or create one in Inbox."
  :weight 6
  :requires org-roam)
 (:id org-roam-daily
  :topic "Org-roam"
  :text "Open today's daily note with C-c n j."
  :weight 4
  :requires org-roam)
 (:id org-agenda
  :topic "Org agenda"
  :text "Open the agenda with C-x a a; capture with C-x a c."
  :weight 5)
 (:id dired-parent
  :topic "Dired"
  :text "In Dired, C-l follows the configured parent-directory action."
  :weight 3)
 (:id wdired
  :topic "Dired"
  :text "In Dired, use C-c m e to edit file names in place with wdired."
  :weight 4)
 (:id remote-files
  :topic "Remote files"
  :text "The C-c f u prefix contains ssh-deploy upload, download, diff, and remote-file commands."
  :weight 3
  :requires tramp)
 (:id workspaces
  :topic "Workspaces"
  :text "Save the current workspace with C-c w s before switching contexts."
  :weight 4)
 (:id window-select
  :topic "Windows"
  :text "Use C-x o to move between ordinary windows and Treemacs."
  :weight 3)
 (:id undo
  :topic "Undo"
  :text "C-z is undo; C-c e u opens the undo-fu commands."
  :weight 4)
 (:id snippets
  :topic "Snippets"
  :text "Insert a Yasnippet with C-c i s when you want a template by name."
  :weight 3)
 (:id multiple-cursors
  :topic "Multiple cursors"
  :text "C-c e m e edits multiple selected lines; use the same prefix for matching text."
  :weight 2)
 (:id ghostel
  :topic "Terminal"
  :text "Open the Ghostel terminal with C-c o t without leaving Emacs."
  :weight 3)
 (:id magit
  :topic "Magit"
  :text "Use the Doom leader Git menu to enter Magit, then stage and commit from its status buffer."
  :weight 5)
 (:id lookup-definition
  :topic "Navigation"
  :text "Jump to a definition with M-. and return with M-, ."
  :weight 5)
 (:id notes-backlinks
  :topic "Org-roam"
  :text "Toggle backlinks with C-c n b to see how the current note connects."
  :weight 3
  :requires org-roam)
 (:id spell
  :topic "Writing"
  :text "Toggle spelling with C-c t s; correct the word at point from C-c e s c."
  :weight 2)
 (:id presentation
  :topic "Org presentation"
  :text "In an Org buffer, C-c t p starts the presentation mode."
  :weight 2)
 (:id profiler
  :topic "Profiling"
  :text "Use C-c o p s and C-c o p r to capture and inspect an Emacs profile."
  :weight 1))
