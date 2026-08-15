# Official Hugo Compatibility Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将官方 HugoBasicExample 兼容性检查固化到 Inyo 的本地与 CI 验证流程，并补齐主题分发元数据。

**Architecture:** 保留现有主题运行时与 consumer smoke。新增一个 PowerShell 验证脚本，在临时目录克隆官方空白 HugoBasicExample，并通过 `themesDir` 直接加载当前工作区主题；同时让根 `hugo.toml` 显式声明 Extended，并让 `theme.toml` 指向现有 GitHub Pages Demo。

**Tech Stack:** Hugo Extended 0.164.0、PowerShell、GitHub Actions、HugoBasicExample。

## Global Constraints

- 不修改 Hero、诗词 API、文章布局、颜色 token、字体实现和 Demo 内容。
- 不修改 `demo-shots/`、`exampleSite/public/`、`resources/` 或其他构建产物。
- 官方基准脚本的临时目录必须在结束时清理。
- Markdown 新增代码块使用三个反引号和 `shell` 标记，不使用 `~~~` 或 `powershell`。
- 保留当前工作区已有修改，不重置、不覆盖无关文件。

---

### Task 1：增加分发元数据和验证失败断言

**Files:**

- Modify: `hugo.toml`
- Modify: `theme.toml`
- Modify: `scripts/verify-theme.ps1`

- [x] 在 `verify-theme.ps1` 增加 `module.hugoVersion.extended = true` 和 `theme.toml demosite` 断言。
- [x] 运行 smoke，确认当前实现因两个字段缺失而失败。
- [x] 在根 `hugo.toml` 声明 `extended = true`。
- [x] 在 `theme.toml` 增加 GitHub Pages Demo 地址。
- [x] 重新运行 smoke，确认断言通过。

### Task 2：固化 HugoBasicExample 官方基准

**Files:**

- Create: `scripts/verify-hugo-basic-example.ps1`
- Modify: `scripts/verify-theme.ps1`

- [x] 先让 `verify-theme.ps1` 断言官方基准脚本存在且引用 HugoBasicExample。
- [x] 创建脚本：在临时目录克隆官方 `HugoBasicExample`，以当前主题父目录作为 `themesDir`，运行 Hugo 构建并检查退出码、首页和 CSS 输出。
- [x] 用本地 Hugo 运行脚本，确认经典主题加载通过。
- [x] 脚本在 `finally` 中清理自己的临时目录。

### Task 3：接入 CI 和文档

**Files:**

- Modify: `.github/workflows/verify-theme.yml`
- Modify: `README.md`
- Modify: `README.en.md`
- Modify: `CONTRIBUTING.md`
- Modify: `AGENTS.md`
- Modify: `.pi/skills/inyo-theme-development/SKILL.md`

- [x] 在 CI 增加官方基准 job，继续使用 Windows、Hugo Extended 0.164.0 和根 `go.mod` 的 Go 版本。
- [x] 在中英文 README、贡献指南和项目 skill 中记录官方基准命令。
- [x] 更新项目规则，明确 `hugo.toml` 的 Extended 声明和 `theme.toml` 的 Demo 地址。
- [x] 执行完整 Hugo、theme smoke、consumer smoke、官方基准和 diff 检查。

## Final Verification

```shell
hugo --source exampleSite --minify --printPathWarnings
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
pwsh -File scripts/verify-hugo-basic-example.ps1
git diff --check
```
