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

;; Ignore "Package cl is deprecated" warning
(setq byte-compile-warnings '(cl-functions))
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

(doom! :completion
       (vertico +icons)    ; the search engine of the future
       (corfu +orderless +icons) ; the ultimate code completion backend

       :ui
       doom              ; what makes DOOM look the way it does 😖😕
       doom-dashboard    ; a nifty splash screen for Emacs
       doom-quit         ; DOOM quit-message prompts when you quit Emacs ;
       hl-todo           ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW/BUG/XXX
       indent-guides     ; highlighted indent columns
       minimap           ; show a map of the code on the side
       modeline          ; snazzy, Atom-inspired modeline, plus API
       nav-flash         ; blink cursor line after big motions
       ophints           ; highlight the region an operation acts on
       (popup +defaults)   ; Not all windows are created equally.
       (treemacs +lsp)   ; a project drawer, like neotree but cooler
       unicode           ; extended unicode support for various languages
       vc-gutter         ; vcs diff in the fringe
       (window-select +numbers)     ; visually switch windows
       workspaces        ; tab emulation, persistence & separate workspaces
       zen               ; distraction-free coding or writing:

       :editor
       file-templates    ; auto-snippets for empty files
       fold              ; (nigh) universal code folding
       (format +lsp)       ; automated prettiness +format/buffer will use lsp if available
       multiple-cursors ; editing in many places at once, demo: https://emacsrocks.com/e13.html
       snippets             ; my elves. They type so I don't have to
       word-wrap            ; soft wrapping with language-aware indent
       
       :emacs
       (dired +icons)    ; making dired pretty [functional]
       (ibuffer +icons)  ; interactive buffer management
       undo              ; persistent, smarter undo for your inevitable mistakes (undo-fu)
       vc                ; version-control and Emacs, sitting in a tree (gitignore, gitconfig)

       :email
       ;; (mu4e +gmail +org) ; TODO Should give it a try

       :term
       vterm             ; the best terminal emulation in Emacs

       :checkers
       grammar           ; aid your writing by combining lang-tool and writegood-mode
       (spell +aspell)   ; tasing you for misspelling mispelling (+everywhere disabled)
       syntax   ; tasing you for every semicolon you forget

       :tools
       ansible
       direnv
       (debugger +lsp)
       (docker +lsp)
       editorconfig        ; let someone else argue about tabs vs spaces
       ;; ein                 ; TODO try Jupyter notebooks with emacs
       (eval +overlay)     ; run code, run (also, repls)
       (lookup +dictionary)    ; navigate your code and its documentation
       lsp
       magit               ; a git porcelain for Emacs
       make                ; run make tasks from Emacs
       ;; pass             ; password manager for nerds
       pdf                 ; pdf enhancements
       ;; tmux
       ;;terraform         ; May try it: infrastructure as code, try it when using multiple cloud services
       tree-sitter       ; TODO may use the built-in in Emacs29+ instead later on, if highlight is supported
       upload            ; map local to remote projects via ssh/ftp

       :lang
       emacs-lisp          ; drown in parentheses
       (cc +lsp +tree-sitter) ; C > C++ == 1
       ;;common-lisp       ; if you've seen one lisp, you've seen them all
       ;;data              ; config/data formats
       ;;ess               ; emacs speaks statistics
       graphviz            ; language for visualizing graphs
       ;;(graphql +lsp)    ; Give queries a REST
       (json +lsp +tree-sitter)       ; At least it ain't XML
       ;;(java +lsp)       ; the poster child for carpal tunnel syndrome
       ;;(javascript +lsp +tree-sitter) ; all(hope(abandon(ye(who(enter(here))))))
       (latex +cdlatex)      ; NOTE may try +lsp
       ;;lua               ; one-based indices? one-based indices
       markdown            ; writing docs for people to ignore
       (org +roam2 +present) ; TODO +noter
       plantuml            ; diagrams for confusing people more
       (python +lsp +pyright +tree-sitter)
       ;; (python +lsp +pyenv +poetry +pyright +tree-sitter) ; basedpyright lsp server with poetry, pyenv
       ;; qt                  ; the 'cutest' gui framework ever
       rst                 ; ReST in peace
       ;; (rest + jq)      ; TODO Emacs as a REST client +jq Enable support for reading and processing REST responses with jq
       (sh +lsp +tree-sitter)
       (web +lsp +tree-sitter)   ; support for various web languages, including HTML5, CSS, SASS/SCSS, as well as Django
       (yaml +lsp +tree-sitter)        ; JSON, but readable

       :app
       calendar
       ;;everywhere        ; *leave* Emacs!? You must be joking
       ;;(rss +org)          ; emacs as an RSS reader

       :config
       (default +smartparens) ;; +bindings

       :cc
       theme
       defaults
       bindings
       dev
       notes
       agenda
       ai

       :cc-langs
       cpp
       python
       web
       )

;; Using "mycustom" instead of "custom" to keep the custom file clean
;; TODO should move to at the end of config.el
(load! "mycustom")
