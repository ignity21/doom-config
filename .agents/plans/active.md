# Active configuration work

The `config.d/` and private-module migration completed on 2026-08-30. Its
implementation plan and GUI verification material live in `.agents/archive/`.

## 1. Debugger + LSP — pending decision

`init.el` intentionally leaves `:tools (debugger +lsp)` disabled. The related
configuration and `C-c d` bindings are guarded, so enabling it requires only a
deliberate product decision followed by `doom sync` and a small DAP workflow
verification. Do not enable it incidentally while working on unrelated code.

## 2. TRAMP remote Python LSP — pending diagnosis

Python buffers opened through TRAMP do not yet start their language server
reliably. `cc/tramp-user-bin-directory` currently adds `~/.local/bin` to the
remote executable path; the next investigation should reproduce the failure in
a remote Python project, capture `*EGLOT ... events*` and `*Messages*`, then
distinguish remote PATH/server discovery, the selected Python backend, and
TRAMP process environment before changing configuration.

## 3. Dashboard daily tips — implemented

Tips are declarative records in `data/dashboard-tips.eld`, separate from the
small dashboard widget in `config.d/dashboard-tips.el`. The file is read and
cached only when Dashboard is rendered. A SHA-256-derived number chooses one
eligible tip per local calendar day with its configured weight, so reloads do
not churn the message while higher-weight tips occur more often over time.

The starter content prioritizes configured packages and personal keybindings,
then enabled Doom-module features. Add a tip by appending a record with `:id`,
`:topic`, `:text`, and `:weight`; use `:requires minuet`, `copilot`, or
`org-roam` when it only applies with that feature enabled.
