# Module Migration

## Migration memory

- The startup currently loads the legacy `config.d/` first and then
  `config.d.new/`. A migrated behavior must have one source only; remove its
  old implementation when its replacement is verified.
- `config.d.new/ai.el` owns gptel provider and credential configuration.
  `modules/cc/ai` owns the separate `ai-code` package and its direct
  `C-c a` entry point. Aidermacs is retired and no longer declared.
- LSP configuration now has one source: `config.d.new/lsp.el`. Doom's
  `:editor format +onsave` owns format-on-save; lsp-mode's own save formatter
  is intentionally disabled.
- `:tools lsp +eglot` means Eglot, not lsp-mode. The two clients have
  mutually exclusive configuration and mode-local keybindings.

## Doom module migration rules

These rules apply to every Doom module migration, regardless of category.

1. Treat the current upstream `doomemacs/modules` module directory and its
   README as authoritative for module names, flags, packages, and supported
   configuration. Use GitHub (`gh` when available) to inspect it.
2. Before changing anything, trace the module through all legacy configuration
   (`config.d/`) and private modules (`modules/`), including package
   declarations and load entry points.
3. Put replacement configuration in `config.d.new/` by default. When the
   feature has a coherent reusable boundary, organize it as an appropriate
   private module under `modules/` instead.
4. Define the configuration and its intended workflow together. Document that
   workflow in the relevant private module's `README.org`; if no private module
   is created, agree where its user-facing workflow belongs before writing it.
   Discuss choices with the user as they arise; do not enable or configure a
   module until the user confirms its intended use.
5. Keep legacy configuration intact while the replacement is being implemented
   and verified. Only after the new configuration works, remove the matching
   old implementation so one behavior has one owner.

## Module migration protocol

The modules after `;; TODO: following not confirmed` in `init.el` are reviewed
one at a time. The authoritative inventory, module documentation, and flags
are the current `doomemacs/modules` repository (not the legacy configuration
or stale Doom documentation).

For each module, follow this sequence:

1. Trace all legacy configuration through its load entry points (including
   hidden `config.d/` and `config.d.new/` directories), then search its package
   declarations and source for module-specific settings.
2. Inspect the upstream module directory and its README, supported flags, and
   package/configuration implications.
3. Give a short explanation of what it provides, its dependencies or likely
   workflow, and any relevant alternative.
4. Ask whether to keep it. Do not enable or add configuration until confirmed.
5. If kept, add or migrate only the necessary configuration, then remove the
   corresponding legacy implementation so there is one owner.
6. If declined, comment/remove the module from `init.el` and delete only its
   corresponding obsolete legacy configuration. Update this table.

## Active :tools migration scope

The user has selected these modules for review and possible migration, in this
order unless changed during discussion:

1. `ansible`
2. `direnv`
3. `docker`
4. `editorconfig`
5. `lookup`
6. `magit`
7. `make`
8. `tree-sitter`
9. `debugger`

`lsp`, `llm`, and `eval` are already handled and are outside this review.

## Session handoff

This session completed the selected `:tools` reviews for `ansible`, `direnv`,
`docker +lsp +tree-sitter`, `editorconfig`, `lookup +dictionary`, and `make`.
`magit` has its workflow documented; its user-pinned `magit` and `transient`
package versions remain intentionally untouched and can be reviewed later.

Resume the migration with `tree-sitter`, then `debugger`.

| Module | Upstream location | Decision | Migration state |
|---|---|---|---|
| `ansible` | `:tools/ansible` | keep | complete |
| `direnv` | `:tools/direnv` | keep | complete |
| `docker +lsp +tree-sitter` | `:tools/docker` | keep | complete |
| `editorconfig` | `:tools/editorconfig` | keep | complete |
| `lookup +dictionary` | `:tools/lookup` | keep | complete |
| `magit` | `:tools/magit` | keep | workflow documented; pin review pending |
| `make` | `:tools/make` | keep | complete |
| `pdf` | `:tools/pdf` | pending | queued |
| `tree-sitter` | `:tools/tree-sitter` | pending | queued |
| `debugger` | `:tools/debugger` | selected | queued |
| `upload` | `:tools/upload` | pending | queued |
| `emacs-lisp` | `:lang/emacs-lisp` | pending | queued |
| `python` | `:lang/python` | pending | queued |
| `cc` | `:lang/cc` | pending | queued |
| `graphviz` | `:lang/graphviz` | pending | queued |
| `json` | `:lang/json` | pending | queued |
| `latex +cdlatex` | `:lang/latex` | pending | queued |
| `markdown` | `:lang/markdown` | pending | queued |
| `org +roam +present` | `:lang/org` | pending | queued |
| `plantuml` | `:lang/plantuml` | pending | queued |
| `rst` | `:lang/rst` | pending | queued |
| `sh +lsp` | `:lang/sh` | pending | queued |
| `web +lsp` | `:lang/web` | pending | queued |
| `yaml +lsp +tree-sitter` | `:lang/yaml` | pending | queued |
| `calendar` | `:app/calendar` | pending | queued |

## Modules completed before this review

The modules before `;; TODO: following not confirmed` in `init.el` were
migrated in the earlier configuration pass. They remain enabled and are not
re-reviewed unless their configuration needs changing.

| Category | Completed module selectors |
|---|---|
| `:completion` | `vertico +icons`, `corfu +orderless +icons +dabbrev` |
| `:ui` | `doom`, `dashboard`, `hl-todo`, `indent-guides`, `modeline`, `nav-flash`, `ophints`, `popup +defaults`, `unicode`, `vc-gutter`, `window-select +numbers`, `workspaces` |
| `:editor` | `file-templates`, `fold`, `format +lsp +onsave`, `snippets`, `word-wrap` |
| `:emacs` | `dired +icons`, `ibuffer +icons`, `undo +tree`, `vc` |
| `:checkers` | `grammar`, `spell +aspell`, `syntax` |
| `:tools` | `lsp`, `llm`, `eval +overlay` |
| `:config` | `default +smartparens` |
| personal | `:cc/theme`, `:cc/defaults`, `:cc/bindings`, `:cc/dev`, `:cc/notes`, `:cc/agenda`, `:cc/ai`, `:cc-langs/cpp`, `:cc-langs/python`, `:cc-langs/web` |
