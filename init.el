;; init.el -*- lexical-binding: t; no-byte-compile: t; -*-

;; This file controls what Doom modules are enabled and what order they load
;; in. Remember to run 'doom sync' after modifying it!

;; NOTE Press 'SPC h d h' (or 'C-h d h' for non-vim users) to access Doom's
;;      documentation. There you'll find a link to Doom's Module Index where all
;;      of our modules are listed, including what flags they support.

;; NOTE Move your cursor over a module's name (or its flags) and press 'K' (or
;;      'C-c c k' for non-vim users) to view its documentation. This works on
;;      flags as well (those symbols that start with a plus).
;;
;;      Alternatively, press 'gd' (or 'C-c c d') on a module to browse its
;;      directory (for easy access to its source code).

(setq initial-frame-alist '((fullscreen . maximized)))

;; Declare groups before Doom loads private module init files.
(defgroup cc nil
  "Personal Doom configuration."
  :group 'applications
  :prefix "cc/")
(defgroup cc-ui nil
  "User interface settings for the personal configuration."
  :group 'cc)
(defgroup cc-defaults nil
  "Default settings for the personal configuration."
  :group 'cc)
(defgroup cc-ai nil
  "AI settings for the personal configuration."
  :group 'cc)
(defgroup cc-completion nil
  "Completion settings for the personal configuration."
  :group 'cc)
(defgroup cc-langs nil
  "Language settings for the personal configuration."
  :group 'cc)
(defgroup cc-python nil
  "Python settings for the personal configuration."
  :group 'cc-langs)
(defgroup cc-note nil
  "Note-taking settings for the personal configuration."
  :group 'cc)

(doom!
  :completion
  (vertico +icons)    ; Vertico, Consult, Embark, Marginalia, Orderless
  (corfu +orderless +icons +dabbrev)

  :ui
  doom              ; what makes DOOM look the way it does 😖😕
  dashboard         ; a nifty splash screen for Emacs
  hl-todo           ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW/BUG/XXX
  indent-guides     ; highlighted indent columns
  modeline         ; snazzy, Atom-inspired modeline, plus API
  nav-flash         ; blink cursor line after big motions

  ophints           ; highlight the region an operation acts on
  (popup +defaults)   ; Not all windows are created equally.
  unicode           ; extended unicode support for various languages
  vc-gutter         ; vcs diff in the fringe
  (window-select +numbers)     ; visually switch windows
  workspaces        ; tab emulation, persistence & separate workspaces

  :editor
  file-templates    ; auto-snippets for empty files
  fold              ; (nigh) universal code folding
  (format +lsp +onsave)       ; automated prettiness +format/buffer will use lsp if available
  snippets             ; my elves. They type so I don't have to
  word-wrap            ; soft wrapping with language-aware indent

  :emacs
  ;; electric
  (dired +icons)    ; making dired pretty [functional]
  (ibuffer +icons)  ; interactive buffer management
  (undo +tree)      ; persistent, smarter undo for your inevitable mistakes (undo-fu)
  vc                ; version-control and Emacs, sitting in a tree (gitignore, gitconfig)

  :checkers
  grammar          ; aid your writing by combining lang-tool and writegood-mode
  (spell +aspell)  ; +everywhere for coding comments
  syntax   ; tasing you for every semicolon you forget

  :tools
  ;; use "lsp with debugger" or "eglot"
  ;; lsp
  ;; (debugger +lsp)
  (lsp +eglot) ; +booster) maybe enable for big projects

  llm
  (eval +overlay)     ; run code, run (also, repls)
  ansible             ; Playbooks, Jinja templates, Vault, and ansible-doc
  ;; direnv              ; project-local environments via .envrc
  (docker +lsp +tree-sitter) ; Docker UI, Dockerfile LSP, and syntax trees
  editorconfig        ; let someone else argue about tabs vs spaces
  ;; ein                 ; TODO try Jupyter notebooks with emacs
  (lookup +dictionary)    ; navigate your code and its documentation

  magit               ; a git porcelain for Emacs
  make                ; run make tasks from Emacs
  ;; pass             ; password manager for nerds
  pdf                 ; pdf enhancements
  ;; tmux
  ;;terraform         ; May try it: infrastructure as code, try it when using multiple cloud services
  tree-sitter
  upload            ; map local to remote projects via ssh/ftp

  :lang
  emacs-lisp          ; drown in parentheses
  (python +lsp +pyright +uv +tree-sitter)
  (cc +lsp) ; C > C++ == 1
  ;;common-lisp       ; if you've seen one lisp, you've seen them all
  ;;data              ; config/data formats
  ;;ess               ; emacs speaks statistics
  graphviz            ; language for visualizing graphs
  ;;(graphql +lsp)    ; Give queries a REST
  (json +lsp)       ; At least it ain't XML
  ;;(java +lsp)       ; the poster child for carpal tunnel syndrome
  (latex +cdlatex)
  ;;lua               ; one-based indices? one-based indices
  (markdown +lsp)           ; writing docs for people to ignore
  (org +roam +present) ; TODO +noter
  plantuml            ; diagrams for confusing people more
  ;; qt                  ; the 'cutest' gui framework ever
  rst                 ; ReST in peace
  ;; (rest + jq)      ; TODO Emacs as a REST client +jq Enable support for reading and processing REST responses with jq
  (sh +lsp)
  (web +lsp +tree-sitter)   ; support for various web languages, including HTML5, CSS, SASS/SCSS, as well as Django
  (yaml +lsp +tree-sitter) ; JSON, but readable

  :app
  calendar
  ;;everywhere        ; *leave* Emacs!? You must be joking
  ;;(rss +org)          ; emacs as an RSS reader

  :config
  (default +smartparens) ;; +bindings

  :cc
  defaults
  lsp
  notes
  agenda
  ai
  (completion +minuet)

  :cc-langs
  cpp
  python
  web
  )

;; Must be set before the :ui dashboard module's config.el runs its early
;; `(switch-to-buffer +dashboard-name)` bootstrap, otherwise the dashboard
;; renders into a differently-named buffer that never gets a window.
(setq +dashboard-name "*Happy Hacking!*")
