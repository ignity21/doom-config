# config.d/ 迁移 — 实机验证清单

> 代码迁移（Step -1 … 6）已全部落地，`make lint` / `make test` 绿。
> 本文件是**在 GUI Emacs 里**逐项确认没有回归的操作手册。
> 每完成一项在 `[ ]` 里打勾。发现问题记在该项下方 "❌" 行。

分支：`refactor`（领先 `origin/refactor` 14 个 commit，验证通过后再 push）。

---

## 0. 前置：干净启动

```bash
cd ~/.config/doom
~/.config/emacs/bin/doom sync      # 改过 init.el / packages.el，必须先跑
~/.config/emacs/bin/doom doctor    # 只应剩“外部工具缺失”类告警
```

- [ ] **0.1 `doom sync` 无 error**（warning 里不应出现 "Could not find module" / "void"）。
- [ ] **0.2 `doom doctor`** 只剩外部可执行文件缺失告警（basedpyright / ty / vscode-*-language-server / zig-for-ghostel 之类）；**不应**有 `:cc theme`、`:cc bindings`、`:cc dev`、`:ui doom-dashboard` 这类 "module not found"。
- [ ] **0.3 冷启动**：关掉所有 Emacs，`emacs --debug-init`。
  - `*Warnings*` buffer 不存在，或只有无害内容。
  - `M-x view-echo-area-messages`（或 `C-h e`）里 **没有** `void-variable` / `void-function` / `Symbol's function definition is void` / `Cannot open load file`。
  - 特别检查这几个符号没报 void：`cc/set-doom-ui-appearance`（应彻底消失）、`+doom-dashboard-name`、`cc/default-org-dir`、`cc/notes-root-dir`。
- [ ] **0.4 dashboard 渲染**：启动后停在 Doom dashboard，标题/banner 正常（Step 1 把 `+doom-dashboard-name` 改成了 `+dashboard-name`）。

---

## 1. Step 1 — config.d/ 平移

目的：确认 8 个旧文件的内容在新主题化布局里仍然生效。

- [ ] **1.1 目录结构**：`ls config.d/` 只有 `defaults theme keybindings ui editor completion checkers tools patch langs/`，**没有** `org.el` / `ai.el` / `lsp.el` / `term.el` / `emacs.el` / `langs.el`。
- [ ] **1.2 行号**：新 buffer 里 `M-x display-line-numbers-mode` 行为正常（`defaults.el`）。
- [ ] **1.3 word-wrap**：`C-c t v`（`+word-wrap-mode`）能开关（`editor.el`）。
- [ ] **1.4 rainbow-mode**（从 `cc/dev` 搬到 `editor.el`）：打开一个 CSS 或含 `#ff0000` 的文件，`M-x rainbow-mode`，色值应染色；关掉后 `hl-line` 恢复（`cc/rainbow-mode-toggle-hl-line`）。
- [ ] **1.5 sh 默认 shell**：新建 `test.sh`，进入 `sh-mode`，`C-h v sh-shell` 应为 `bash`（`cc/sh-set-default-shell` 顶层函数 + hook）。
- [ ] **1.6 dired `C-l`**：dired buffer 里 `C-l` 走上级目录相关绑定（`defaults.el` 里的 `dired-mode-map`）。
- [ ] **1.7 ibuffer `K`**：`C-x C-b`（ibuffer）里 `K` 绑定存在（`defaults.el`）。
- [ ] **1.8 workspace 保存**：`C-c w s`（`cc/workspace-save-current`，Step 1 提为顶层函数）不报 void-function。
- [ ] **1.9 company-dict 已禁用**：`M-x describe-variable company-backends` 里不含 `company-dict`（`disable-packages!` 挪到顶层 `packages.el`）。

---

## 2. Step 2 — 键位统一（重点，冲突点最多）

`modules/cc/bindings/` 已删。所有全局前缀现在只在 `config.d/keybindings.el`。
逐个按前缀键，看 **which-key 弹窗**：描述正确、且顶层显示为 `<prefix>`（如 `<file>`）而不是被某个命令占据。

### 2.1 前缀完整性

| 键 | which-key 顶部应显示 | 抽查子键 |
|---|---|---|
| [ ] `C-c f` | `<file>` | `f r` recent、`f u` `<upload>` 子前缀 |
| [ ] `C-c s` | `<search>` | `s d` ripgrep |
| [ ] `C-c l` | `<lookup>` | `l o` search online |
| [ ] `C-c .` | `<lookup(code)>` | `. p` consult-eglot-symbols、`. c` call hierarchy |
| [ ] `C-c c` | `<code>` | `c f` format、`c m` `<minor-mode>` |
| [ ] `C-c o` | `<open>` | `o t` terminal、`o f` new frame |
| [ ] `C-c g` | `<gptel>` | `g c` open chat |
| [ ] `C-c t` | `<toggle>` | `t v` word-wrap、`t c` minuet、`t s` spell |
| [ ] `C-c a` | `<ai>` | `a a` = AI code menu（**关键**：不能整个 `C-c a` 变成命令） |
| [ ] `C-c d` | `<debug>` | 有 `debugger` 才有内容 |
| [ ] `C-c e` | `<edit>` | `e m` multicursors、`e u` undo、`e w` writing |
| [ ] `C-c i` | `<insert>` | `i c` from clipboard、`i e` emoji |
| [ ] `C-c n` | `<note>` | `n f` find note、`n j` fleet note（需 `:lang org +roam`） |
| [ ] `C-c p` | `<project>` | `p p` switch project、`p s` search |
| [ ] `C-c P` | `<profiling>` | `P s` start profiling |
| [ ] `C-c w` | `<workspace>` | `w s` save current、`w m` new named |
| [ ] `C-c y` | `<snippets>` | `y n` new snippet |
| [ ] `C-c 1` | `<checker>` | flycheck buffer 里按，有内容 |
| [ ] `<f5>` | `<run>` | `<f5> <f5>` quickrun-shell、`<f5> b` eval buffer |
| [ ] `C-x a` | `<agenda>` | `a a` org-agenda、`a f` find agenda file |

### 2.2 已知冲突点（务必单测）

- [ ] **`C-z`** = undo（`undo-fu-only-undo`）。之前 bindings 解绑、emacs.el 又绑回，合并后应只有重绑生效，不报错。
- [ ] **`C-x C-z`** 已解绑（不 suspend）。
- [ ] **`C-c m e`**：在 **dired** buffer 里按 → 进 `wdired-mode`（mode-local，需 `:map`）。
- [ ] **`C-c m d`**：在 **org** buffer 里按 → `org-download` 相关（留在 `modules/cc/notes/`，`:map org-mode-map`）。
- [ ] **`C-c p c`**：projectile command map 重映射还在（which-key 显示 `<projectile-command>`）。
- [ ] **`C-c i t/T/p/i/l/f`**：在 **org** buffer 里，这些是 org 版 insert（`modules/cc/notes/`），与全局 `C-c i` 前缀叠加不冲突。
- [ ] **`C-c t p`**：org buffer 里 = `org-tree-slide-mode`；pdf buffer 里 = pdf toggle。两者 mode-local。
- [ ] **`C-c n p`**：org buffer 里 preview/plot；org-noter 场景里 sync。不同 map。
- [ ] **滚轮**：`C-滚轮` 不再缩放（已解绑），`M-滚轮` 缩放文字。
- [ ] **`C-h w`** = woman。
- [ ] **`doom-leader`**：`C-c M-;` 触发 doom leader（`C-c M-; f f` find-file 之类）。

### 2.3 ssh-deploy autoload（Step 2 把 3 个缺失的 handler autoload 搬进 keybindings.el 顶部）

- [ ] `C-c f u d`（download）、`u D`（delete）、`u f`（open remote file）：`describe-key` 能解析到 `ssh-deploy-*-handler`，不是 "not defined"。（需 `:tools upload`；不实际执行也行，看能否 autoload。）

---

## 3. Step 3 — modules/cc/ai（gptel 模块化）

**关键风险**：模块 `config.el` 早于 `custom-vars.el` 加载；靠 gptel 懒加载兜底。

- [ ] **3.1 冷启动后不碰任何东西**，直接 `M-x gptel`。
  - `*Warnings*` **没有** "No gptel backend is configured"。
  - `C-h v gptel-backend` → 值是 `custom-vars.el` 里 `cc/gptel-default-backend` 对应的后端（默认 `deepseek`，你本机可能是别的）。
  - ❌ 若出现该 warning：`after! gptel` 在 custom-vars 之前求值了 → 退路是把注册块挂 `doom-after-init-hook`（改 `modules/cc/ai/config.el`）。
- [ ] **3.2 `M-x doom/reload`** 后再 `M-x gptel`：注册表重建正常（`clrhash` 路径），backend 仍正确，无重复/报错。
- [ ] **3.3 `C-c g c`** 开 chat、`C-c g m` 菜单、`C-c g s` 发送 region：能正常起对话。
- [ ] **3.4 gptel-magit**：在 magit commit buffer 里触发 AI commit message（`+magit.el`），`cc/gptel-magit--truncate-subject` 截断 subject 行正常（这个函数已有 ERT 覆盖，主要看集成）。
- [ ] **3.5 `C-c a a`** = `ai-code-menu`：菜单能弹（ai-code 包）。

---

## 4. Step 4 — modules/cc/completion（copilot / minuet）

当前 flag：`(completion +minuet)`。

- [ ] **4.1 minuet 自动建议**：打开一个 `.py` 文件，输入几个字符，等一下 → minuet 虚影建议出现。
- [ ] **4.2 `C-c t c`** = `cc/minuet-toggle-auto-suggestion`：能开/关自动建议。
- [ ] **4.3 `M-RET`**（`minuet-active-mode-map`）：接受当前建议。
- [ ] **4.4 `cc/minuet-only-on-change-p`**：光标不动/无改动时不重复触发建议（有 ERT 覆盖，肉眼确认不刷屏即可）。
- [ ] **4.5 doctor**：`doom doctor` 里 copilot 的 editorconfig / jsonrpc 检查只在 `-minuet`（即 `+copilot`）时才跑，当前 `+minuet` 下应被跳过。
- [ ] **4.6 切 copilot（可选）**：`init.el` 改 `(completion +copilot)` → `doom sync` → 重启 → `.py` 里 copilot 建议能起、`C-c t o` = `copilot-mode`、`C-c t n` = `copilot-nes-mode`。测完 **改回 `+minuet`** 再 `doom sync`。

---

## 5. Step 5 — 笔记 / 议程路径 defcustom

`config.d/org.el` 桥接文件已删，派生逻辑进了 `modules/cc/{agenda,notes}/init.el`。

- [ ] **5.1 org-directory**：`C-h v org-directory` = `custom-vars.el` 里 `cc/default-org-dir` 的值（`cc/default-org-dir` 的 `:set` 负责设置）。
- [ ] **5.2 org-agenda-dir**：`C-h v cc/org-agenda-dir` 正确；`C-h v cc/agenda-habits-file` / `-projects-file` / `-work-file` / `-study-file` 是基于它派生的路径（`cc/agenda--set-org-dir`，有 ERT 覆盖）。
- [ ] **5.3 notes 派生**：`C-h v cc/notes-root-dir` = custom-vars 值；`C-h v org-roam-directory` / `cc/roam-notes-dir` / `cc/org-pdf-notes-dir` / `cc/roam-dailies-dir` 都在 root 之内，尾斜杠一致（`cc/notes--derive-directories` + `cc/notes--set-root` 的 `:set`，有 ERT 覆盖）。
- [ ] **5.4 `C-c n f`**（find note）能打开 node 列表。
- [ ] **5.5 `C-x a a`**（org-agenda）能正常出议程视图。
- [ ] **5.6 daily**：`C-c n j`（fleet / today）能创建/打开今天的 daily，文件落在 dailies 目录里。
- [ ] **5.7 org-roam category 逻辑**：`C-c n n`（capture in category）、`C-c n m`（move current node to category）行为正常（这块 118 行逻辑有 ERT，主要看集成不炸）。

---

## 6. Step 5 附带 — `:term ghostel`

手写的 `(package! ghostel)` 换成了 `doom!` 块里的 `:term ghostel`。

- [ ] **6.1 `doom sync`** 里 ghostel 作为模块被处理（可能提示需要 `zig` 编译 —— 若你没装 zig，记下即可，不算回归，但 `C-c o t` 会失败）。
- [ ] **6.2 `C-c o t`** = `#'ghostel`：能打开终端（装了 ghostel 后端的前提下）。
- [ ] **6.3 `doom doctor`** 有 ghostel 自己的检查项出现。

---

## 7. 收尾

- [ ] **7.1** 全部机械检查复跑：`make lint && make test && doom sync && doom doctor`。
- [ ] **7.2** 以上 1–6 全绿后：`git push origin refactor`。
- [ ] **7.3** 在 `.agents/plans/config-d-migration.md` 的 Verification 节标注“已实机验证 / 日期”。
