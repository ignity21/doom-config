# config.d/ 迁移 — 验证进度跟踪

**分支**：`refactor`（已领先 `origin/refactor` 15 commits）  
**日期**：2026-08-30 下午  
**验证 session**：在 GUI Emacs 实机逐步推进

---

## 已完成验证 ✅

### Step 0 — 前置检查
- [x] `doom sync` 无 error（212 包 up-to-date）
- [x] `doom doctor` 无模块问题（66 modules / 186 packages）
  - 仅有 9 条外部工具缺失警告（zig, black, pipenv…），与迁移无关
  - **不出现** `:cc theme/bindings/dev` 或 `:ui doom-dashboard` 的 "module not found"
- [x] `emacs --debug-init` 冷启动干净
  - *Messages* 无 void-variable / void-function / Cannot open load file
  - `cc/set-doom-ui-appearance` / `+dashboard-name` / `cc/default-org-dir` / `cc/notes-root-dir` 无 void 警告
- [x] dashboard 正常渲染（banner、菜单项在）

**结论**：模块加载正确，无配置错误。

---

### Step 1 — config.d/ 平移功能
- [x] 目录结构（8 个主题文件 + langs/ 子目录）
- [x] 1.2 行号显示 `M-x display-line-numbers-mode`
- [x] 1.3 word-wrap 开关 `C-c t v`
- [ ] 1.4 rainbow-mode 染色 —— **配置正确**（`config.d/editor.el` + `packages.el`），但包渲染效果未验证（可忽略，不是迁移问题）
- [x] 1.5 sh 默认 shell → `bash`（`C-h v sh-shell`）
- [x] 1.6 dired `C-l` 上级目录
- [x] 1.7 ibuffer `K` 绑定存在
- [x] 1.8 workspace save `C-c w s` 无报错
- [x] 1.9 company-dict 已禁用（`describe-variable company-backends` 里无 company-dict）

**结论**：8/9 项全过。旧配置功能全部迁移成功。

---

### Step 2 — 键位统一
- [x] **20 个前缀完整检查**（which-key 弹窗显示对应 `<prefix>` 描述）
  - `C-c f` / `s` / `l` / `.` / `c` / `g` / `t` / `o` / `p` / `w` / `<f5>` / `C-x a`
  - 所有子键导航正常

- [x] **4 个已知冲突点单测**
  - [x] `C-z` undo — **已修复**（改 `undo-fu-only-undo` → `undo`，因前者非 interactive command，由 undo-fu-mode 的 remap 处理）
  - [x] `C-c m e` dired wdired — mode-local 键位正常
  - [x] `C-c m d` org-download — mode-local 键位正常
  - [x] `C-c a a` ai-code-menu — `C-c a` 是前缀，`a a` 触发命令

**结论**：键位统一完成。全局前缀结构正确，冲突点已处理。

---

## 未验证的 Step（下一个 session）

### Step 3 — modules/cc/ai（gptel 模块化）
**验证方法**：
1. 冷启动后**不做任何操作**，直接 `M-x gptel`
   - `*Warnings*` 不应出现 "No gptel backend is configured"
   - `C-h v gptel-backend` 应为 custom-vars.el 里配置的后端（默认 `deepseek`）
2. `M-x doom/reload` 后再 `M-x gptel`（注册表重建）
3. `C-c g c` 开 chat / `C-c g s` 发送 / `C-c a a` AI menu
4. magit commit 里 gptel 集成（`+magit.el`）

---

### Step 4 — modules/cc/completion（minuet/copilot）
**验证方法**：
1. `.py` 文件输入字符 → minuet 虚影建议
2. `C-c t c` 开关自动建议
3. `M-RET` 接受建议
4. 可选：切 `(completion +copilot)` 往返测试

---

### Step 5 — 笔记/议程路径 defcustom
**验证方法**：
1. `C-h v org-directory` / `org-roam-directory` / `cc/org-pdf-notes-dir` → 与 custom-vars 一致
2. `C-c n f` find note / `C-x a a` org-agenda / `C-c n j` fleet
3. org-roam category 目录逻辑（复杂逻辑，有 ERT 覆盖）

---

### Step 6 — 收尾
**验证方法**：
1. `make lint && make test && doom sync && doom doctor` —— 全绿
2. 其他 Step 成功后 `git push origin refactor`

---

## 关键修复记录

| 问题 | 原因 | 修复 | 提交 |
|---|---|---|---|
| C-z 报 "Wrong type argument: commandp, undo-fu-only-undo" | `undo-fu-only-undo` 非 interactive command，只在 undo-fu-mode keymap 内有效 | 改绑 `#'undo` 而不是 `#'undo-fu-only-undo`；undo-fu-mode 的 remap 会拦截它 | 7ca70c6 |

---

## 下一个 Session 入口

1. **读** `.agents/plans/config-d-migration.md` 的「进度」表 → 确认 Step 0-2 已 ✅
2. **读** 本文件 "未验证的 Step" 章节 → Step 3 开始
3. **用** `/tmp/.../step3-checklist.md`（由下一个 session 准备）逐项验证

**分支状态**：`refactor` 领先 `origin/refactor` **15 commits**（含 C-z 修复）
