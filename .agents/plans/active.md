# Active configuration work

## 1. Org / notes workflow refinement — in progress

The baseline Org-mode configuration in `modules/cc/notes/+org.el` has been
reviewed and simplified: task-heading creation now belongs to the agenda
module, unused or confusing bindings were removed, and the remaining visual
commands are grouped under `C-c c v`.  `toc-org` is now declared explicitly.

Next: review and refine the org-roam workflow (`+roam.el`, category capture,
dailies, node finding, and its global keybindings) iteratively in GUI Emacs.

## 2. Debugger + LSP — pending decision

`init.el` intentionally leaves `:tools (debugger +lsp)` disabled. The related
configuration and `C-c d` bindings are guarded, so enabling it requires only a
deliberate product decision followed by `doom sync` and a small DAP workflow
verification. Do not enable it incidentally while working on unrelated code.

## 3. TRAMP remote Python LSP — pending diagnosis

Python buffers opened through TRAMP do not yet start their language server
reliably. `cc/tramp-user-bin-directory` currently adds `~/.local/bin` to the
remote executable path; the next investigation should reproduce the failure in
a remote Python project, capture `*EGLOT ... events*` and `*Messages*`, then
distinguish remote PATH/server discovery, the selected Python backend, and
TRAMP process environment before changing configuration.
