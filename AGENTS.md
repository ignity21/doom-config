# AGENTS.md

Personal Doom Emacs configuration. On branch `refactor` — the old flat
`config.d/` files have been replaced in place by the themed `config.d/`
layout (migration happened in a transitional `config.d.new/` directory that
was renamed back to `config.d/` once the old flat files were gone).

The active migration — themed `config.d/` + `modules/` restructure,
plus confirmed module decisions and LSP invariants — is tracked in
[`.agents/plans/config-d-migration.md`](.agents/plans/config-d-migration.md),
which carries a step-by-step plan and a progress checklist. Resume from the
first unchecked Step.

@.agents/plans/config-d-migration.md

## AI Project Content

This project prefers `AGENTS.md` files and the `.agents/` directory for
managing AI-related instructions, context, workflows, and supporting content.
When adding or updating AI-related project guidance, place it there rather
than introducing a separate convention unless a tool explicitly requires
otherwise.

## Repository layout

```
init.el              Doom module flags (the `doom!` block) — run `doom sync` after edits
packages.el          package declarations — run `doom sync` after edits
config.el            entry point: loads custom-vars + all config.d files in order
config.d/            themed configs (loaded explicitly by config.el, not auto-discovered)
  ├─ defaults.el theme.el keybindings.el ui.el editor.el completion.el
  ├─ checkers.el tools.el patch.el
  └─ langs/<lang>.el     per-language config (loaded via cc/load-lang-config)
modules/cc/          private Doom modules (defaults, lsp, notes, ai, agenda, completion)
modules/cc-langs/    private language modules (cpp, python, web)
custom-vars.el       symlink → real file in Dropbox (API keys, name/email, dirs) — NOT committed
custom-vars.example.el  template users copy to custom-vars.el; lists every defcustom
```

## How config loads

`config.d/` is **not** auto-discovered. Each file is loaded explicitly by
`config.el` via `cc/load-config` / `cc/load-lang-config` (the `t` arg means a
missing file is tolerated, not an error). The load order is hard-coded in
`config.el`:

```
defaults → theme → keybindings → ui → editor → completion → checkers
  → tools → patch
  → langs/elisp → langs/sh → langs/yaml → langs/python → langs/web
```

AI (`gptel`), LSP tuning, org/agenda, notes and the copilot/minuet code
completion backend all live in private `modules/cc/*` modules, not in
`config.d/`. `org-directory` and the notes/pdf/dailies directories are
derived by the `:set` functions of `cc/default-org-dir` (in
`modules/cc/agenda/init.el`) and `cc/notes-root-dir` (in
`modules/cc/notes/init.el`).

**Adding a new `config.d/` file requires registering it in `config.el`.**
Forgetting this is the most common mistake — the file silently never loads.

Private modules under `modules/cc*/` follow Doom's own module lifecycle
(`init.el`/`config.el`/`packages.el`/`autoload.el`), driven by flags in the
top-level `init.el` `doom!` block.

## Development Rules

These rules apply across `config.d/`, `modules/cc/`, and
`modules/cc-langs/`.

### Conventions

- **Custom variables**: use the `cc/` prefix with a slash, for example
  `cc/gptel-default-backend`, `cc/font-size`, and
  `cc/python-lsp-backend`.
- **Customize groups**: use `cc-<area>` with a hyphen, such as `cc-ai`,
  `cc-ui`, `cc-completion`, and `cc-langs`. (`langs/yaml.el` uses bare `cc`
  as an exception.)
- **Backend / option choices**: declare them with
  `(defcustom ... :type '(choice (const :tag "Label" val) ...))`.
- **Mutually exclusive packages**: pick one with a module flag, not a
  `defcustom` (a module's `packages.el` is read before `custom-vars.el`
  loads). The copilot/minuet switch is `(completion +minuet)` in `init.el`;
  `modules/cc/completion/packages.el` calls `disable-packages!` on the
  unpicked one. A `:disable`d package's `use-package!` and `after!` blocks
  become no-ops automatically, so both configurations can remain in place
  without `:if` guards.
- **Lexical binding**: every `.el` starts with
  `;;; -*- lexical-binding: t; no-byte-compile: t; -*-`.
- **Doom idioms**: wrap package configuration in `(after! PACKAGE ...)`; use
  `map!`, `use-package!`, `add-hook!`, and `setopt` (not bare `setq` for
  `defcustom`s).

### When adding a `defcustom`

1. Define it in the relevant `config.d/*.el` (or module `config.el`) with
   the `cc/` prefix and a `cc-<area>` group.
2. Add an example value to `custom-vars.example.el` under the matching section
   (`;; llm`, `;; code completion`, ...). The template must list every
   customizable option; a new `defcustom` without an example entry is
   incomplete.

### Secrets and personal data

API keys, `user-full-name`, and `user-mail-address` live in `custom-vars.el`,
which is a symlink to a Dropbox-synced file and is never committed. The
`custom-vars.example.el` template carries placeholder values only. Do not
hard-code keys or personal information into committed files; always route them
through a `cc/`-prefixed `defcustom` defined in `config.d/` and consumed
from `custom-vars.el`.

### Verifying changes

- After editing `init.el` or `packages.el`, run `doom sync` (or
  `M-x doom/reload`).
- `config.el` and `config.d/*` are loaded on startup; restart Emacs or
  re-evaluate the specific form. There is no test suite, so verify changes by
  starting Emacs and exercising the feature.
- Byte-compilation is disabled project-wide (`no-byte-compile: t`); do not
  rely on compile-time errors to catch mistakes.

## Modern Emacs Lisp

### Variables

- Use `defcustom` for user-facing options. Give it a docstring, `:type`, and
  an appropriate customization group. Define the group before any module or
  configuration declares options in it.
- Set Customize options with `setopt`. It runs the option's setter and checks
  the value. Use `setq` for ordinary state, `setq-local` for buffer-local
  state, and `defvar-local` for buffer-local variables.
- Use `defconst` for configuration constants such as shared key-prefix
  strings.

### Keymaps and bindings

- Create a named keymap with `defvar-keymap` (or `define-keymap` for an
  expression). Do not introduce new uses of `make-sparse-keymap` plus `setq`.
- Bind native global, local, and explicit maps with `keymap-global-set`,
  `keymap-local-set`, and `keymap-set`. Do not introduce new uses of
  `define-key`, `global-set-key`, or `local-set-key`.
- Continue to use Doom's `map!` when its descriptions, conditional bindings,
  mode-map targeting, or prefix DSL make the declaration clearer. Give custom
  prefixes a which-key description.

### Keybinding ownership

- `config.d/keybindings.el` is the single source for **global** bindings: the
  `C-c` / `C-x` / `C-h` prefix keymaps and their contents, global
  unbind/rebind, `doom-leader-key`, and which-key descriptions. Entries that
  hang off a global prefix belong here even when they are mode-local (e.g.
  `C-c m e` wdired, `C-c t c` minuet) — guard them with
  `(:when (modulep! ...))` and `:map`.
- Theme files and `modules/cc/*` keep only bindings **inside a package's own
  keymap** (`vertico-map`, `corfu-map`, `treemacs-mode-map`,
  `minuet-active-mode-map`, `org-agenda-mode-map`, the org-local `C-c n`
  note bindings, …).

### Hooks, advice, and mutable data

- Prefer named functions registered with `add-hook`. Use `add-hook!` only when
  Doom's multi-mode or inline-function syntax is materially clearer; avoid
  anonymous functions in global hooks.
- Prefer hooks, variables, or key remapping over advice. When advice is
  necessary, use named `define-advice` or `advice-add` and document why it is
  needed; do not use obsolete `defadvice`.
- Use `setf` for generalized places such as `alist-get` and `plist-get`. When
  using `plist-put`, always keep its returned plist so a newly added property
  cannot be lost.
