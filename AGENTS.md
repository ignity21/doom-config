# AGENTS.md

Personal Doom Emacs configuration. On branch `refactor` — the old flat
`config.d/` files are being migrated to the themed `config.d.new/` layout.

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
config.el            entry point: loads custom-vars + all config.d(.new) files in order
config.d/            legacy flat configs (defaults, ui, editor, langs, ...) — still loaded
config.d.new/        new themed configs (the active target of the refactor)
  ├─ defaults.el theme.el keybindings.el completion.el
  ├─ checkers.el lsp.el patch.el ai.el
  └─ langs/<lang>.el     per-language config (loaded via cc/load-lang-config)
modules/cc/          private Doom modules (ui, defaults, dev, notes, ai, agenda, bindings)
modules/cc-langs/    private language modules (cpp, python, web)
custom-vars.el       symlink → real file in Dropbox (API keys, name/email) — NOT committed
custom-vars.example.el  template users copy to custom-vars.el; lists every defcustom
mycustom.el          machine-local setopt overrides (cc-note dirs, tab widths, ...)
```

## How config loads

`config.d.new/` is **not** auto-discovered. Each file is loaded explicitly by
`config.el` via `cc/load-config` / `cc/load-lang-config` (the `t` arg means a
missing file is tolerated, not an error). The load order is hard-coded in
`config.el` (around lines 29–39):

```
defaults → theme → keybindings → completion → checkers → lsp → patch → ai
  → langs/elisp → langs/yaml → langs/python
```

**Adding a new `config.d.new/` file requires registering it in `config.el`.**
Forgetting this is the most common mistake — the file silently never loads.

Private modules under `modules/cc*/` follow Doom's own module lifecycle
(`init.el`/`config.el`/`packages.el`/`autoload.el`), driven by flags in the
top-level `init.el` `doom!` block.

## Development Rules

These rules apply across `config.d.new/`, `modules/cc/`, and
`modules/cc-langs/`.

### Conventions

- **Custom variables**: use the `cc/` prefix with a slash, for example
  `cc/gptel-default-backend`, `cc/font-size`, and
  `cc/code-completion-backend`.
- **Customize groups**: use `cc-<area>` with a hyphen, such as `cc-ai`,
  `cc-ui`, `cc-completion`, and `cc-langs`. (`langs/yaml.el` uses bare `cc`
  as an exception.)
- **Backend / option choices**: declare them with
  `(defcustom ... :type '(choice (const :tag "Label" val) ...))`.
- **Mutually exclusive packages**: pick one at install time in `packages.el`
  with a `defvar` flag and `disable-packages!` (see `use-minuet-p` for the
  minuet/copilot switch). A `:disable`d package's `use-package!` and `after!`
  blocks become no-ops automatically, so both packages' configurations can
  remain in place without `:if` guards.
- **Lexical binding**: every `.el` starts with
  `;;; -*- lexical-binding: t; no-byte-compile: t; -*-`.
- **Doom idioms**: wrap package configuration in `(after! PACKAGE ...)`; use
  `map!`, `use-package!`, `add-hook!`, and `setopt` (not bare `setq` for
  `defcustom`s).

### When adding a `defcustom`

1. Define it in the relevant `config.d.new/*.el` (or module `config.el`) with
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
through a `cc/`-prefixed `defcustom` defined in `config.d.new/` and consumed
from `custom-vars.el`.

### Verifying changes

- After editing `init.el` or `packages.el`, run `doom sync` (or
  `M-x doom/reload`).
- `config.el` and `config.d.new/*` are loaded on startup; restart Emacs or
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
