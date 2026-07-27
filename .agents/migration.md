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

| Module | Upstream location | Decision | Migration state |
|---|---|---|---|
| `ansible` | `:tools/ansible` | keep | complete |
| `docker +lsp +tree-sitter` | `:tools/docker` | keep | complete |
| `editorconfig` | `:tools/editorconfig` | pending | queued |
| `lookup +dictionary` | `:tools/lookup` | pending | queued |
| `magit` | `:tools/magit` | pending | queued |
| `make` | `:tools/make` | pending | queued |
| `pdf` | `:tools/pdf` | pending | queued |
| `tree-sitter` | `:tools/tree-sitter` | pending | queued |
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
