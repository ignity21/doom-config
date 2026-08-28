# config.d/ → config.d.new/ + modules/ 迁移计划

## Context

`refactor` 分支上，旧的扁平 `config.d/`（8 文件 / 176 行）正在迁往主题化的
`config.d.new/`（829 行）与私有模块 `modules/`（1527 行）。目前三者并存，边界
模糊，并且阅读中发现若干**从未生效**的配置和悬空引用。

本计划要达成的终点：

1. `config.d/` 目录清空删除，内容按主题落到 `config.d.new/` 或模块。
2. 键位只有一个事实来源（`config.d.new/keybindings.el`），删除 `modules/cc/bindings`。
3. `config.d.new/ai.el` 并入 `modules/cc/ai/`；copilot/minuet 提成 `modules/cc/completion/`。
4. 顺带修掉迁移中暴露的 bug 与不规范写法（详见 Step 0 / Step 5）。

环境：Emacs 31.1 + Doom 2.2.3（`doom+` 源码树）。写代码时用
`setopt` / `defvar-keymap` / `keymap-global-set` / `keymap-set` / `define-advice`
/ 命名函数 + `add-hook`，避免 `setq` 设 defcustom、`define-key`、`defadvice`。

### 迁移中确认的既有缺陷

| 问题 | 位置 | 影响 |
|---|---|---|
| `:cc theme` 模块目录已在 `103838a` 删除，init.el 仍声明 | `init.el:~200` | 悬空模块声明 |
| `cc/set-doom-ui-appearance` 与 `:cc ui` 均不存在 | `config.el:6-7` | 死代码 |
| 本机 Doom 模块名为 `:ui dashboard`、变量为 `+dashboard-name` | `config.d/ui.el:9-10` | **该段从未生效** |
| 括号不闭合，且 `config.el` 未加载它，`:term vterm` 也未启用 | `config.d/term.el` | 孤儿 + 语法错误 |
| ~~`cc/han-font` 在 example 中被 setopt，但无 defcustom~~ | `custom-vars.example.el:11` | 已在 Step 0 移除幽灵 example 行。用户确认当前 `doom-symbol-font`/`doom-variable-pitch-font` 已覆盖 CJK，单独配 `cc/han-font` 有其他坑，不做 |
| `cc/default-org-dir` 从未定义，靠 `boundp` 兜底 | `config.d/org.el:6` | `org-directory` 实际取决于 custom-vars |
| `cc/roam-notes-dir` / `cc/org-pdf-notes-dir` / `cc/roam-dailies-dir` 被 `setopt` 但无 defcustom | `config.d/org.el:13-16` | 无类型、无 Customize 入口 |
| `autoload.el` 无 `;;;###autoload` cookie，Doom 只扫 cookie 不加载文件 | `modules/cc/bindings/autoload.el` | **整个文件从未执行** |
| 文件名拼写为 `docter.el` | `modules/cc-langs/cpp/docter.el` | `doom doctor` 从未跑过这条检查 |
| `(package! ghostel)` 手写，但 Doom 自带 `:term ghostel` 模块 | `packages.el:87` | 绕过模块，少了 doctor/配置 |
| `cc/org-agenda-dir` 及 4 个 `cc/agenda-*-file` 用 `defvar` 定义后 `setopt` | `modules/cc/agenda/config.el:37-48` | 不符合 AGENTS.md 约定 |
| AGENTS.md 举 `cc/code-completion-backend` 为例，但该变量不存在 | `AGENTS.md` | 文档失真 |

---

## 已确认的模块决策与不变量

（并入自原 `.agents/migration.md`，该文件已废弃删除。）

**LSP 不变量**：

- `:tools lsp +eglot` 指 Eglot，**不是** lsp-mode；两套 client 配置与 mode-local
  键位互斥。
- `modules/cc/lsp/` 是 LSP 客户端配置的唯一来源（`config.el` = 调校 / advice /
  `cc/eglot-events-*` 命令；`doctor.el` = 无私有模块的语言的 eglot server 检查）。
  按语言划分的 `eglot-server-programs` 条目仍就近放在语言配置里
  （`langs/<lang>.el` 或 `cc-langs/<lang>/`）。
- Doom 的 `:editor format +onsave` 拥有「保存时格式化」；lsp-mode 自带的保存
  格式化刻意关闭。

**已 review 且保留的 `:tools` 模块**（无需再逐个评估）：`ansible`、`direnv`、
`docker +lsp +tree-sitter`、`editorconfig`、`lookup +dictionary`、`make`、
`tree-sitter`（零迁移工作，已在活跃使用）。`magit` 工作流已文档化，其
用户 pin 的 `magit` / `transient` 版本刻意不动，可日后单独评估。

**`debugger`**：`init.el` 中 `;; (debugger +lsp)` 目前注释停用。Step 1 会把
`config.d/tools.el` 的 debugger 段带 `(when (modulep! ...))` 守卫迁到
`config.d.new/tools.el`；是否正式启用（去掉 `init.el` 注释）待用户决定。

**新增模块的评估流程**：将来往 `doom!` 块加 `:tools` / `:lang` 模块前，先
追踪遗留配置 → 查上游 module README / flags → 说明取舍 → 用户确认后再写配置
→ 配完删除对应旧实现，使一个行为只有一个 owner。

---

## 目标架构（判定规则）

**`modules/cc*/`** — 声明自己的包、有 autoload/doctor、可通过 `init.el` 的
`doom!` flag 开关的**功能领域**。

**`config.d.new/`** — 对 Doom 自带模块的个人调校：设置与键位，不引入新包。

**键位归属规则**（本次统一后必须遵守）：

- `config.d.new/keybindings.el` 独占：全局前缀 keymap 的定义**与内容**（`C-c`
  各前缀、`<f5>`、`C-x` / `C-h` 补充）、全局解绑与重绑、which-key 描述、
  `doom-leader-key` 设置。挂在全局前缀下的条目即使是 mode-local（如
  `C-c m e` wdired、`C-c t o` copilot），也写在这里，用 `(:when (modulep! ...))`
  与 `:map` 守卫。
- 主题文件 / 模块只保留**包自有 keymap 内部**的按键：`vertico-map`、
  `corfu-map`、`dired-mode-map "C-l"`、`minuet-active-mode-map` 等。

### 目标文件布局

```
config.d.new/
  defaults.el      核心 Emacs 内置：line-numbers、tramp、widget、dired、ibuffer、undo
  theme.el         字体 + ef-themes
  keybindings.el   唯一键位来源（吸收 modules/cc/bindings 全部内容）
  ui.el      [新]  popup / dashboard / window-select / workspaces / treemacs / zen
  editor.el  [新]  fold / word-wrap / snippets / multiple-cursors
  completion.el    只剩 vertico / corfu（copilot、minuet 移出）
  checkers.el      不变
  lsp.el     [删]  → modules/cc/lsp/（见下方「修订 A」，已落地）
  tools.el         + debugger / pdf
  patch.el         不变
  ai.el      [删]  并入 modules/cc/ai/
  langs/
    elisp.el yaml.el python.el web.el
    sh.el    [新]
modules/cc/
  ai/         [扩] 吸收 config.d.new/ai.el
  lsp/        [新] 吸收 config.d.new/lsp.el + eglot server doctor（修订 A，已落地）
  completion/ [新] copilot + minuet（+minuet / +copilot flag 二选一）
  defaults/ notes/ agenda/   保留
  dev/        [删] rainbow-mode → editor.el；company-dict disable → 顶层 packages.el
  bindings/   [删]
```

`config.el` 新加载顺序（`ai.el` / `lsp.el` 移除，新增 3 项）：

```
defaults → theme → keybindings → ui → editor → completion → checkers
  → tools → patch
  → langs/elisp → langs/sh → langs/yaml → langs/python → langs/web
```

> ⚠️ 每新增一个 `config.d.new/` 文件都必须在 `config.el` 里显式注册
> （`cc/load-config` / `cc/load-lang-config`），否则静默不加载。

---

## 修订 A — LSP 模块化 + `cc/dev` 待解散（Session A 期间，已部分落地）

**动机**：`+eglot` 不自动装 language server，需要 `doctor.el` 覆盖；而
`doctor.el` 只能挂模块（顶层 `$DOOMDIR/doctor.el` 不存在，`doom doctor` 只遍历
`(doom-module-list)`）。把 eglot server 检查放进 `cc/dev` 与 `lsp.el` 的调校分家。

**已落地**：

- 新建 `modules/cc/lsp/`：`config.el` ← `config.d.new/lsp.el` 整体；
  `doctor.el` = sh / markdown / json / docker 四个 eglot server 检查（这几个语言
  没有私有模块）+ `assert! (:tools lsp)`；`README.org`。无 `packages.el`（不引入包）。
- `init.el` `:cc` 块加 `lsp`（在 `defaults` 之后）；`config.el` 移除 `lsp.el` 注册。
- `modules/cc-langs/python/doctor.el`、`modules/cc-langs/web/doctor.el`（新）：各查
  本语言的 eglot server（`rass` / `basedpyright-langserver` / `ty`；
  `vscode-{html,css}-language-server` / `typescript-language-server`）。
- `modules/cc/dev/doctor.el` 移除 eglot 检查（已挪到 `cc/lsp`）；`config.el` 删掉
  死的 `:tools ein` 段。
- 全部检查只 `warn!` 不 `error!`，守卫 `(and (modulep! :lang X) (modulep! :tools lsp +eglot))`。

**待办（并入后续 Step）**：

- `cc/dev` 解散：`rainbow-mode` use-package! → `config.d.new/editor.el`（Step 1
  新建，`package! rainbow-mode` 移顶层 `packages.el`）；`disable-packages!
  company-dict` → 顶层 `packages.el`；copilot 的 editorconfig/jsonrpc doctor 检查
  → `modules/cc/completion/doctor.el`（Step 4 本来就计划搬）。三者搬完后
  `git rm -r modules/cc/dev` 并从 `init.el` `:cc` 块移除 `dev`。

---

## Step -1 — 让计划可被新 session 找到 ✅ 已完成

本文件已从 `~/.claude/plans/steady-wondering-spark.md` 落地到项目内
`.agents/plans/config-d-migration.md`（`.agents/` 不在 `.gitignore` 内，正常入库），
`AGENTS.md` 已通过 `@.agents/plans/config-d-migration.md` 导入，并写入了 `project`
类型记忆 + `MEMORY.md` 指针。

之后每完成一个 Step，就在下方「进度」表里打勾并 commit，新 session 读该表即可知道
从哪继续。

原 `.agents/migration.md`（Doom 模块逐个 review）已废弃删除，仍有价值的部分
（LSP 不变量、已保留的 `:tools` 模块清单、debugger 决策）已并入上方「已确认的
模块决策与不变量」一节。

## 进度

- [x] Step -1 计划落地到 `.agents/plans/` + AGENTS.md 指针 + memory 指针
- [x] Step 0 修复与清理
- [x] Step 0.5 配置不变量 lint（`test/lint-config.el`）— 7 项检查全部就位；`make lint`
      绿（9 条既有 finding 进 `test/lint-baseline.txt`，后续 Step 逐条清）
- [x] 修订 A（部分）— 新建 `modules/cc/lsp/`（吸收 `config.d.new/lsp.el` + eglot
      server doctor）；`cc-langs/{python,web}/doctor.el` 新增；`cc/dev` 剩余部分待
      Step 1 / Step 4 清
- [x] Step 1 config.d/ 平移，删除 `config.d/` 目录（含把 `cc/dev` 的 rainbow-mode 挪出）
- [ ] Step 2 键位统一，删除 `modules/cc/bindings`
- [ ] Step 3 `config.d.new/ai.el` 并入 `modules/cc/ai/`
- [ ] Step 4 新建 `modules/cc/completion`
- [ ] Step 5 defcustom 规范化 + 文档同步
- [ ] Step 6 纯函数 ERT 测试

## Step 0 — 修复与清理（小 · ~20 行 · 同 session）

1. `init.el`：`:cc` 列表删除 `theme`。
2. `config.el`：删除 `(when (modulep! :cc ui) (cc/set-doom-ui-appearance))` 及
   其上的空 `eval-when-compile` ring require（确认 `ring` 是否仍被使用，未被
   使用则一并删）。
3. 删除 `config.d/term.el`。
4. `modules/cc-langs/cpp/docter.el` → `git mv` 为 `doctor.el`。
5. `custom-vars.example.el`：移除幽灵行 `cc/han-font`（无对应 defcustom）。
   **不新增** `cc/han-font` —— 用户确认当前字体链（`doom-symbol-font` =
   Sarasa Mono SC、`doom-variable-pitch-font` = LXGW WenKai）CJK 显示正常，
   过去单独配 `set-fontset-font 'han` 踩过其他坑。

## Step 0.5 — 配置不变量 lint（小 · ~80 行 · 与 Step 0 同 session）

**必须在 Step 1/2 大改之前建立**，用来接住平移与键位重构的回归。这不是单元测试：
配置主体是声明式的 `setopt` / `map!`，断言它们的结果等于测试 Emacs 本身。真正
反复出问题的是 AGENTS.md 里那些**靠人肉遵守的约定**，把它们变成机械检查即可。

新建 `test/lint-config.el`，纯 `emacs -Q --batch` 运行，**不加载 Doom**（纯文本
与文件系统检查，快且无副作用）。检查项，每条都对应一个本次实际发现的缺陷：

1. **`check-parens`** —— 遍历仓库全部 `.el`（跳过 `custom-vars.el` 符号链接与
   `custom.el`）。→ 抓 `config.d/term.el` 那类括号不闭合。
2. **`config.el` 注册完整性** —— 扫 `config.d.new/*.el` 与 `config.d.new/langs/*.el`
   得到文件集合，扫 `config.el` 中 `cc/load-config` / `cc/load-lang-config` 的
   字面量参数得到注册集合，**双向做差**（漏注册 → 文件静默不加载；注册了但文件
   不存在 → 悬空）。→ AGENTS.md 称之为 "the most common mistake"。
3. **`defcustom` ↔ `custom-vars.example.el` 双向对应** —— 扫全仓
   `(defcustom cc/...)` 收集符号集，扫 `custom-vars.example.el` 中 `setopt` 的
   `cc/` 符号集，两个方向都断言。→ 正向抓「新增 defcustom 忘了补示例」
   （AGENTS.md 硬性要求），反向抓「example 里有、定义处没有」的幽灵变量
   （Step 0 已清掉的 `cc/han-font` 就是这一类）。
4. **模块特殊文件名白名单** —— `modules/*/*/` 下的 `.el` 文件名必须属于
   `{init, config, packages, autoload, doctor, cli}`，或位于 `autoload/` 子目录，
   或以 `+` 开头（Doom 的 `+extra.el` 约定）。→ 抓 `cc-langs/cpp/docter.el` 拼写。
5. **`autoload.el` cookie 检查** —— 每个 `autoload.el` 至少含一条**行首**
   `^;;;###autoload`（行首匹配，`;; ;;;###autoload` 这种注释掉的不算）。
   → 抓 `modules/cc/bindings/autoload.el` 零 cookie 从未执行、以及
   `modules/cc/ai/autoload.el` 整个被注释掉。
6. **`lexical-binding` 头** —— 每个 `.el` 首行含 `lexical-binding: t`
   （AGENTS.md 要求）。
7. **`modulep!` / `doom!` 模块名有效性** —— 扫全仓 `(modulep! :cat mod ...)` 与
   `init.el` 的 `doom!` 块，提取 `:category module`，断言对应目录存在于
   `~/.config/emacs/sources/doom+/modules/<cat>/<mod>/` 或
   `$DOOMDIR/modules/<cat>/<mod>/`。→ 抓 `:cc theme` 悬空、以及
   `(modulep! :ui doom-dashboard)` 这个**本机根本不存在、导致整段配置静默失效**
   的模块名。这条价值最高，因为 `modulep!` 对不存在的模块只会安静返回 nil。

配一个 `test/run.sh`（或 `Makefile` 的 `make lint` 目标）：

```sh
emacs -Q --batch -l test/lint-config.el -f cc/lint-run
```

失败时以非零退出码退出，便于以后接 CI 或 pre-commit hook。

### Step 0.5 落地结果

- `test/lint-config.el`（7 项检查，入口 `cc/lint-run`）+ `Makefile`（`make lint`
  / `make test`）+ `test/run.sh`。
- 检查 6（lexical-binding）**放行 `packages.el`**：Doom 上游模块的 `packages.el`
  惯例只带 `no-byte-compile`，本仓照此。检查 7 的 Doom 模块目录自动在
  `~/.config/emacs/sources/doom+/modules` 与 `~/.config/emacs/modules` 间探测，
  可用 `DOOM_MODULES_DIR` 覆盖。
- **baseline 机制**：`test/lint-baseline.txt` 记录当前已知 finding，`make lint`
  只在出现**新** finding 或 baseline 条目不再复现时才非零退出（即修复必须缩小
  baseline）。`LINT_UPDATE_BASELINE=1 make lint` 重新生成。
- Step 0.5 内顺手修掉的机械缺陷（不进 baseline）：
  - `modules/cc/notes/{autoload,init,packages,+roam}.el`、`modules/cc/dev/doctor.el`
    的文件头 `-*-` 结尾写成 `---` / 缺 `lexical-binding` → 已修正。
  - `modules/cc/notes/roam.el` → `+roam.el`，`config.el` 的 `(load! "roam")`
    同步改为 `(load! "+roam")`。
- **进 baseline、由后续 Step 清除的 9 条**：

  | finding | 清除于 |
  |---|---|
  | `autoload-cookie:modules/cc/bindings/autoload.el` | Step 2 |
  | `autoload-cookie:modules/cc/ai/autoload.el` | Step 3 |
  | `module-missing:ui/doom-dashboard`（在 `config.d/ui.el`） | Step 1（该文件删除 / 改 `:ui dashboard`） |
  | `defcustom-missing-example:cc/dark-ef-theme` `cc/yaml-indent-offset` | Step 5（补 `custom-vars.example.el`） |
  | `defcustom-missing-example:cc/cpp-default-tab-width` `cc/notes-root-dir` `cc/org-roam-default-category` `cc/org-roam-non-category-directories` | Step 5（先与用户确认这些属 `custom-vars.example.el` 还是机器本地 `mycustom.el`；`mycustom.el` 无模板，可能需要放宽检查 3 或补一个 `mycustom.example.el`） |

## Step 1 — config.d/ 平移到 config.d.new/（中 · ~200 行 · 与 Step 0 同 session）

保留未启用模块的配置，一律加 `(when (modulep! ...))` 守卫（用户已确认）。

- **新建 `config.d.new/ui.el`** ← `config.d/ui.el` 全部。
  - `(modulep! :ui doom-dashboard)` → `(modulep! :ui dashboard)`；
    `+doom-dashboard-name` → `+dashboard-name`（本机 Doom 已改名，源码见
    `~/.config/emacs/sources/doom+/modules/ui/dashboard/config.el:7`）。
  - treemacs / zen 段保留守卫（当前未启用）。
  - `cc/workspace-save-current` 提为顶层命名函数（现在嵌在 `after! persp-mode` 里）。
  - treemacs / persp / popup 的**前缀键位**移交 Step 2 的 keybindings.el；此文件
    只留 `:map treemacs-mode-map` 之类的包内 keymap 按键与 `setopt`。
- **新建 `config.d.new/editor.el`** ← `config.d/editor.el` 的 word-wrap 段与
  snippets 的 `remove-hook!`（后者实际是改 corfu capf，放
  `config.d.new/completion.el` 更合适）。fold / multiple-cursors / yas 的前缀
  键位移交 Step 2。**并入 `modules/cc/dev/config.el` 的 `rainbow-mode`
  use-package!**（修订 A），`package! rainbow-mode` 与 `disable-packages!
  company-dict` 挪到顶层 `packages.el`。
- **新建 `config.d.new/langs/sh.el`** ← `config.d/langs.el`；把内联
  `add-hook!` + defun 改成顶层命名函数 `cc/sh-set-default-shell` +
  `(add-hook 'sh-mode-hook #'cc/sh-set-default-shell)`。
- **扩充 `config.d.new/tools.el`** ← `config.d/tools.el` 的 debugger（守卫保留）
  与 pdf 段；pdf 的 `C-c t p` 前缀键位移交 Step 2。
- **扩充 `config.d.new/defaults.el`** ← `config.d/defaults.el`（widget keymap）
  与 `config.d/emacs.el` 中 `dired-mode-map "C-l"`、`ibuffer-mode-map "K"` 等
  包内 keymap 按键。`C-z` 与 `C-c m e` 移交 Step 2。
- **`config.d/org.el` 内容下沉到模块**（见 Step 5），不在 `config.d.new/` 建
  `org.el`。
- 在 `config.el` 注册 `ui` / `editor` / `langs/sh`，删除全部 `config.d/*` 的
  `load!` 调用，**删除 `config.d/` 目录**。

### Step 1 落地结果

- 新建 `config.d.new/{ui,editor}.el`、`config.d.new/langs/sh.el`；`defaults.el` /
  `tools.el` / `completion.el` 扩充；均在 `config.el` 注册，新加载顺序落地
  （`ai.el` 仍在，Step 3 处理）。
- `config.d/ui.el` 的 `:ui doom-dashboard` → `:ui dashboard`，`+doom-dashboard-name`
  → `+dashboard-name`。lint baseline 移除 `module-missing:ui/doom-dashboard`。
- 内联 defun 提为顶层命名函数：`cc/sh-set-default-shell`、`cc/workspace-save-current`、
  `cc/zen-{disable,enable}-line-numbers`、`cc/rainbow-mode-toggle-hl-line`；对应
  `add-hook!` 改 `add-hook`。
- `cc/dev` 部分解散：`rainbow-mode` use-package! → `config.d.new/editor.el`；
  `package! rainbow-mode` + `disable-packages! company-dict` → 顶层 `packages.el`。
  `modules/cc/dev/{config,packages}.el` 清空留占位注释，`init.el` 仍留 `dev`
  （copilot doctor 检查 Step 4 搬走后再 `git rm`）。
- **偏离计划两处**（均为保持跨 session 可启动）：
  1. 键位未拆进 `keybindings.el`。绝大多数是包内 keymap（`treemacs-mode-map`、
     `widget-keymap`、`pdf-view-mode-map`、`yas-minor-mode-map` 等），按键位归属
     规则本就该留在主题文件；仅 `C-z`、`C-c w s` 两个真·全局绑定暂留
     `defaults.el` / `ui.el`，Step 2 统一时迁走。
  2. 新建了**临时** `config.d.new/org.el`（原样搬 `config.d/org.el`，含头部注释）。
     计划要求 org 配置直接下沉到模块 init.el，但那是 Step 5（Session D）。为避免
     Step 1→5 之间 `org-directory` / notes 目录派生失效，先留桥接文件，Step 5
     删除它及其 `config.el` 注册。

## Step 2 — 键位统一（大 · ~450 行重写 · **建议新开 session**）

把 `modules/cc/bindings/config.el`（241 行）全部并入
`config.d.new/keybindings.el`（208 行），加上 Step 1 移交过来的约 50 行，改写为
统一的 `defvar-keymap` + `keymap-global-set` + `keymap-set` 体系；随后删除
`modules/cc/bindings/`（含 `.doommodule`、`autoload.el`）并从 `init.el` 的
`:cc` 列表移除 `bindings`。

需要新增的前缀 keymap（沿用现有 `cc/xxx-keymap` + `cc/xxx-map-prefix` 常量模式）：
`cc/ai-keymap`(C-c a)、`cc/debug-keymap`(C-c d)、`cc/edit-keymap`(C-c e)、
`cc/insert-keymap`(C-c i)、`cc/note-keymap`(C-c n)、`cc/project-keymap`(C-c p)、
`cc/profiling-keymap`(C-c P)、`cc/workspace-keymap`(C-c w)、
`cc/snippet-keymap`(C-c y)、`cc/checker-keymap`(C-c 1)、`cc/agenda-keymap`(C-x a)。

**已知冲突点，逐条核对（这是本步骤的主要风险）：**

- `C-c a` — `modules/cc/bindings` 声明为 `<ai>` 前缀，而 `modules/cc/ai/config.el`
  用 `(map! "C-c a" #'ai-code-menu)` 把它整个绑成命令。按 `:cc` 模块加载顺序
  （bindings 在 ai 之前）现状是**前缀被覆盖**，`C-c a` 实为 `ai-code-menu`。
  → 推荐：`C-c a` 保持前缀（`cc/ai-keymap`），`C-c a a` = `ai-code-menu`，
  与已有的 `C-c g`(gptel) 并列。若倾向保留单键行为，则删除该前缀声明。
- `C-z` — bindings 模块 `undefine-key!` 解绑，`config.d/emacs.el` 又绑回
  `undo-fu-only-undo`。合并后必须保证解绑在前、重绑在后，或直接只写重绑。
- `C-c t` — `cc/toggle-keymap` 是前缀，但 `completion.el` 用字符串
  `"C-c t o"` / `"C-c t n"` 直接 `map!` copilot 开关，`keybindings.el` 又用
  `"C-c t p"` 绑 org-present。统一改为 `keymap-set cc/toggle-keymap`。
- `C-c 1` — 前缀内容在 `checkers.el`，which-key 描述在 bindings 模块。合并后
  描述随定义走（放 keybindings.el）。
- `C-c p` — bindings 的 `<project>` 前缀、projectile 的 `C-c p c` 重映射、
  `config.d/ui.el` 的 `(map! :map persp-mode-map "C-c p" nil)` 三者交织。
- `C-c m` — `cc/local-mode-keymap` 是全局前缀，但 dired 的 `C-c m e` 与
  org-download 的 `C-c m d` 是 mode-local，必须带 `:map` 限定，否则互相覆盖。
- `C-c n` — bindings 模块的 org-roam 大块（~40 行）与
  `modules/cc/notes/config.el` 里的 `C-c n p` / `C-c n k` / `C-c n P` 分属两处。
  按新规则全部收进 keybindings.el，`(:when (modulep! :lang org +roam))` 守卫。

**`modules/cc/bindings/autoload.el` 的处理**：该文件无 cookie、从未执行。删除前
逐一确认 `ssh-deploy-*`（8 个）、`org-capture-goto-target`、`recentf-open-files`、
`projectile-recentf` 是否已由 Doom 的 `:tools upload` / org / recentf / projectile
自身 autoload。确实缺失的，改为在 `keybindings.el` 顶部直接 `(autoload ...)`，
或在绑定处用 `:when` + `after!`。

## Step 3 — modules/cc/ai 吸收 config.d.new/ai.el（中 · ~180 行 · 建议新 session，与 Step 4 同 session）

拆分 `config.d.new/ai.el` 到模块：

- `modules/cc/ai/init.el`（**新建**）— 6 个 defcustom：`cc/openai-api-key`、
  `cc/anthropic-api-key`、`cc/deepseek-api-key`、`cc/gemini-api-key`、
  `cc/gptel-enable-copilot`、`cc/gptel-default-backend`。放 init.el 是因为
  `modules/README.org` 明确要求模块的 user option 定义在此。
- `modules/cc/ai/config.el` — `cc/gptel-backends` 注册表、
  `cc/gptel-backend-fallback-order`、`cc/gptel-select-backend`、
  `after! gptel` 的注册块；与现有 `use-package! gptel` 合并，去掉
  「Provider... lives in config.d.new/ai.el」的注释。
- `modules/cc/ai/+magit.el`（**新建**）— `after! gptel-magit` 段（prompt、
  `cc/gptel-magit--truncate-subject`、`define-advice`），由 `config.el` 末尾
  `(load! "+magit")` 引入。
- 删除 `config.d.new/ai.el`，从 `config.el` 移除其注册。

> ⚠️ **加载顺序风险**：模块 `config.el` 早于 `$DOOMDIR/config.el`，而 API key 来自
> `custom-vars.el`（在 `$DOOMDIR/config.el` 中加载）。现状安全的原因是 gptel 走
> `:commands` 懒加载，`after! gptel` 实际在用户首次调用时才求值，那时 custom-vars
> 已就绪。**迁移后不得让任何东西在启动期 require gptel**。验证方法见下方
> Verification 第 4 条；若验证失败，退路是把注册块挂到 `doom-after-init-hook`。

## Step 4 — 新建 modules/cc/completion（中 · ~90 行 · 与 Step 3 同 session）

把 `config.d.new/completion.el` 里的 copilot（~25 行）与 minuet（~50 行）提成模块：

- `modules/cc/completion/packages.el` — 迁入顶层 `packages.el` 的 `minuet`、
  `copilot` 声明。**后端二选一必须用模块 flag 而非 defcustom**：模块
  `packages.el` 在隔离环境下读取，`custom-vars.el` 尚未加载，读不到 defcustom
  的值。写成 `(if (modulep! +minuet) (disable-packages! copilot) (disable-packages! minuet))`。
- `modules/cc/completion/config.el` — copilot 的 `use-package!` 与 minuet 的
  `use-package!` / `cc/minuet--use-deepseek` / `cc/minuet-toggle-auto-suggestion` /
  `cc/minuet-only-on-change-p` / `cc/minuet--last-trigger-tick`。两个
  `use-package!` 可并存无需 `:if` 守卫 —— `disable-packages!` 掉的包，其
  `use-package!` / `after!` 自动 no-op。
- `modules/cc/completion/doctor.el`（**新建**）— 从 `modules/cc/dev/doctor.el`
  搬来 copilot 的 editorconfig / jsonrpc 检查（它现在放错模块了）。搬完后
  `modules/cc/dev/doctor.el` 已空（eglot 检查在修订 A 已挪走），配合 Step 1 把
  `rainbow-mode` 挪走后即可 `git rm -r modules/cc/dev` 并从 `init.el` 移除 `dev`。
- `init.el`：`:cc` 列表加 `(completion +minuet)`；顶层新增
  `(defgroup cc-completion ...)`。
- 顶层 `packages.el`：删除 `use-minuet-p` defvar 与 minuet/copilot 声明。
- `config.d.new/completion.el` 只留 vertico / corfu 部分（约 20 行）+ Step 1
  移交的 yas capf `remove-hook!`。
- minuet 的 `minuet-active-mode-map` 与 copilot 的 `copilot-completion-map` 按
  键位规则留在模块内；`C-c t o/n/c` 三个开关移交 keybindings.el（Step 2 已处理，
  此处只需确认没有重复绑定残留）。

## Step 5 — defcustom 规范化与文档同步（小 · ~60 行 · 可与 Step 4 同 session 或单独收尾）

- **`modules/cc/agenda/init.el`（新建）** — 顶层 `init.el` 新增
  `(defgroup cc-agenda ... :group 'cc)`；把 `modules/cc/agenda/config.el:37-48`
  的 `cc/org-agenda-dir` 及 `cc/agenda-habits-file` / `-projects-file` /
  `-work-file` / `-study-file` 从 `defvar` 改为 `defcustom`（`:type 'file` /
  `'directory`）移到 init.el。新增 `cc/default-org-dir` defcustom 并在此设置
  `org-directory`（必须早于 org 加载，模块 init.el 时机正确）——
  这替换掉 `config.d/org.el` 前半段的 `boundp` 兜底。
- **`modules/cc/notes/init.el`** — 为 `cc/roam-notes-dir`、`cc/org-pdf-notes-dir`、
  `cc/roam-dailies-dir` 补 defcustom（三者当前只被 `setopt` 从未定义）。给
  `cc/notes-root-dir` 加 `:set` 函数，在其中派生上述三个值，取代
  `config.d/org.el` 后半段的手工派生逻辑。
- **删除 Step 1 的临时桥接文件** `config.d.new/org.el` 及其在 `config.el` 的
  `(cc/load-config "org.el")` 注册（内容已被上面两条模块化）。
- **`custom-vars.example.el`** — 按 AGENTS.md 要求补齐每个新 defcustom 的示例：
  `cc/default-org-dir`、`cc/notes-root-dir`、`cc/org-agenda-dir`。
- **`packages.el` / `init.el`** — 删除手写的 `(package! ghostel)`，改为在
  `doom!` 块启用 `:term ghostel`（Doom 自带该模块，见
  `~/.config/emacs/sources/doom+/modules/term/ghostel/`）。`keybindings.el` 的
  `C-c o t` → `#'ghostel` 因此获得正确的 autoload 与 doctor 检查。
- **`AGENTS.md`** — 更新 Repository layout（`config.d/` 已删、新增
  `cc/completion`、删除 `cc/bindings`）、更新 `config.el` 加载顺序清单、把
  「Custom variables」一节的例子从不存在的 `cc/code-completion-backend` 换成真实
  存在的 `cc/python-lsp-backend`、`cc/gptel-default-backend`。补充「键位归属规则」
  一节。

## Step 6 — 纯函数 ERT 测试（小 · ~120 行 · 收尾，与 Step 5 同 session）

只覆盖**真有逻辑的纯函数**，约 6 个。刻意不测 `setopt` / `map!` / `use-package!`
的结果——那是在测 Emacs 而不是测这份配置，且每次调参数都会变红。

**前置改造（本来就该做，顺带完成）**：把纯函数从 `after!` 块里提到文件顶层，
否则批处理加载不到。具体是 Step 3 的 `cc/gptel-magit--truncate-subject`
（现嵌在 `after! gptel-magit` 内），以及 Step 5 的路径派生逻辑写成独立命名函数
`cc/notes--derive-directories`（而不是内联在 `:set` lambda 里）。

| 测试文件 | 覆盖 | 关注点 |
|---|---|---|
| `test/test-gptel.el` | `cc/gptel-magit--truncate-subject` | 恰好 72 / 73 字符、无空格长串、末尾多空格、空串——正则找词边界是 off-by-one 温床 |
| | `cc/gptel-select-backend` | 默认后端可用、默认不可用时按 `cc/gptel-backend-fallback-order` 回退、全空返回 nil |
| `test/test-notes.el` | `modules/cc/notes/autoload.el` 的 category 逻辑 | 全仓逻辑最重的一块（118 行）。`make-temp-file` 造目录树，测目录过滤（`cc/org-roam-non-category-directories`）、路径前缀判断、节点移动 |
| | `cc/notes--derive-directories` | 尾斜杠有无、`~` 展开、dailies 落在 roam root 之内 |
| `test/test-agenda.el` | `cc/org-clock-in-switch-state` | 纯 `cond`，两行搞定 |
| `test/test-completion.el` | `cc/minuet-only-on-change-p` | `with-temp-buffer` + 修改 tick，验证「无改动则阻断」 |

**明确不测**：所有 `cc/cmake-*`（就是 `format` 拼字符串后交给 `cmake-command-run`，
测了等于测 `format`）、`cc/cpp-quick-run` / `cc/cpp-quick-debug`（起子进程）、
`cc/python-dis-region-or-buffer`（依赖 python3）、所有 `*-set-*-capf`
（`setq-local` 一个字面量列表）。

⚠️ **主要摩擦点**：被测的 `autoload.el` 里引用了 `org-roam-*`、`cape-capf-super`
等批处理环境中不存在的符号。对策按优先级：(a) 只 `load` 目标文件而不调用相关分支
——未执行的分支不会因符号未定义而报错；(b) 需要时用 `cl-letf` 打桩；(c) 若某文件
加载即失败，说明纯逻辑与包耦合过紧，把纯函数进一步抽离（这是改进信号，不是绕过）。

顺带记一笔：项目级 `no-byte-compile: t` 把「字节编译告警」这层免费的静态检查
（void-function、参数个数不符、未使用变量）也关掉了。`test/` 下的文件不带这个
header，让编译告警在测试代码上生效；被测文件因自身 file-local 变量拿不到这层，
退而在 lint 里用 `checkdoc-file` 补文档字符串检查。是否取消项目级
`no-byte-compile` 属于独立议题，本次不动。

`make test` 目标：

```sh
emacs -Q --batch -l ert $(for f in test/test-*.el; do echo -n "-l $f "; done) \
      -f ert-run-tests-batch-and-exit
```

---

## Session 划分建议

| Session | 内容 | 规模 | 说明 |
|---|---|---|---|
| **A** | Step -1 + Step 0 + Step 0.5 + Step 1 | ~300 行 | 先落地计划、修 bug、**建立 lint**，再平移。lint 必须早于 Step 1/2 |
| **B** | Step 2 | ~450 行 | 键位统一。量最大、冲突点最多，**必须新开 session 专注做** |
| **C** | Step 3 + Step 4 | ~270 行 | 模块化。都要 `doom sync` + 重启验证，一起做 |
| **D** | Step 5 + Step 6 | ~180 行 | 收尾：defcustom 规范化、文档同步、ERT 测试（依赖 Step 3/5 的纯函数提取） |

每个 session 结束时应处于可启动状态，便于分段验证与提交，并在「进度」表打勾。

**新 session 的接手方式**：读 `.agents/plans/config-d-migration.md` 的「进度」表
找到第一个未勾选项，从该 Step 读起；`git log --oneline` 可交叉确认已落地的提交。

---

## Verification

Step 0.5 之后有了机械检查，其余仍需实际启动验证（Doom 2.2.3 没有测试 CLI——
`~/.config/emacs/lisp/cli/` 只有 make/autoloads/loaddefs/print/sh，
`modules/README.org` 里的 `test/*.el` 是未实现的 TODO）。每步之后：

1. **机械检查（不进 GUI，秒级）**
   ```bash
   cd ~/.config/doom
   make lint                                # Step 0.5 起可用，每步都跑
   make test                                # Step 6 起可用
   ~/.config/emacs/bin/doom sync            # 改了 init.el 或 packages.el 时必须跑
   ~/.config/emacs/bin/doom doctor          # 确认新 doctor.el 生效、无缺失依赖
   ```
   `make lint` 里的 `check-parens` 会覆盖全部 `.el`，`config.d/term.el` 就是
   括号不闭合的前车之鉴；模块名有效性检查会直接报出 `:ui doom-dashboard` 这类
   静默失效。

2. **启动无警告**：`emacs --debug-init`，检查 `*Messages*` 与 `*Warnings*` 中没有
   void-variable / void-function / "Couldn't find module"。

3. **键位回归（Step 2 之后逐个按一遍）**：
   `C-c f` `C-c s` `C-c l` `C-c .` `C-c c` `C-c o` `C-c g` `C-c t` `C-c a`
   `C-c d` `C-c e` `C-c i` `C-c n` `C-c p` `C-c P` `C-c w` `C-c y` `C-c 1`
   `<f5>` `C-x a` —— which-key 弹窗应显示正确描述，无 "prefix 被命令覆盖"。
   另外单测 `C-z`（undo）、`C-c m e`（dired 中 wdired）、`C-c m d`（org 中
   org-download）三个已知冲突点。

4. **AI 后端（Step 3 关键验证）**：冷启动 Emacs 后**先不做任何操作**，直接
   `M-x gptel` → 检查 `gptel-backend` 是否为 custom-vars 中配置的后端，且
   `*Warnings*` 中没有 "No gptel backend is configured"。若出现该警告，说明
   `after! gptel` 在 custom-vars 之前求值了，改用 `doom-after-init-hook`。
   再跑一次 `M-x doom/reload`，确认注册表重建正常（`clrhash` 路径）。

5. **补全后端（Step 4）**：在 `*.py` 缓冲区输入若干字符，确认 minuet 自动建议
   出现；`C-c t c` 能开关；`M-RET` 能接受建议。切到 `+copilot` flag 重跑
   `doom sync` 一次，确认 copilot 侧也能起来。

6. **笔记/议程路径（Step 5）**：`C-h v org-directory`、`C-h v org-roam-directory`、
   `C-h v cc/org-pdf-notes-dir` 三个值应与 `custom-vars.el` 中 `cc/default-org-dir`
   / `cc/notes-root-dir` 一致；`C-c n f`（find note）与 `C-x a a`（org-agenda）
   能正常打开。
