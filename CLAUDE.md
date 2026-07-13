# CLAUDE.md

Personal Doom Emacs configuration. On branch `refactor` — the old flat
`config.d/` files are being migrated to the themed `config.d.new/` layout.

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

## Conventions

These hold across `config.d.new/`, `modules/cc/`, and `modules/cc-langs/`:

- **Custom variables**: `cc/` prefix with slash — `cc/gptel-default-backend`,
  `cc/font-size`, `cc/code-completion-backend`.
- **Customize groups**: `cc-<area>` with hyphen — `cc-ai`, `cc-ui`,
  `cc-completion`, `cc-langs`. (`langs/yaml.el` uses bare `cc`; exception.)
- **Backend / option choices**: declare with
  `(defcustom ... :type '(choice (const :tag "Label" val) ...))`.
- **Mutually exclusive packages**: pick one at install time in `packages.el`
  with a `defvar` flag + `disable-packages!` (see `use-minuet-p` for the
  minuet/copilot switch). A `:disable`d package's `use-package!` and `after!`
  blocks become no-ops automatically, so both packages' configs can stay in
  place without `:if` guards.
- **Lexical binding**: every `.el` starts with
  `;;; -*- lexical-binding: t; no-byte-compile: t; -*-`.
- **Doom idioms**: wrap package config in `(after! PACKAGE ...)`; use `map!`,
  `use-package!`, `add-hook!`, `setopt` (not bare `setq` for defcustoms).

## When you add a defcustom

1. Define it in the relevant `config.d.new/*.el` (or module `config.el`) with
   the `cc/` prefix and a `cc-<area>` group.
2. **Add an example value to `custom-vars.example.el`** under the matching
   section (`;; llm`, `;; code completion`, ...). This template must list every
   customizable option; a new defcustom with no example entry is incomplete.

## Secrets and personal data

API keys, `user-full-name`, `user-mail-address` live in `custom-vars.el`, which
is a symlink to a Dropbox-synced file and is **never** committed. The
`custom-vars.example.el` template carries placeholder values only. Do not
hard-code keys or personal info into committed files — always route through a
`cc/`-prefixed defcustom defined in `config.d.new/` and consumed from
`custom-vars.el`.

## Verifying changes

- After editing `init.el` or `packages.el`: run `doom sync` (or `M-x doom/reload`).
- `config.el` and `config.d.new/*` are loaded on startup — restart Emacs, or
  re-evaluate the specific form. There is no test suite; verify by starting
  Emacs and exercising the feature.
- Byte-compilation is disabled project-wide (`no-byte-compile: t`), so don't
  rely on compile-time errors to catch mistakes.
