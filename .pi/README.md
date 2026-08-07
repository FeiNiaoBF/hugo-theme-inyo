# Inyo 项目本地 pi Skills

本项目在 `.pi/skills/` 内提供 Inyo 主题开发与配色设计技能，pi 会在信任该项目后自动发现。源数据来自 [zhongguo-traditional-colors](https://github.com/nevertoday/zhongguo-traditional-colors)（MIT License，作者 xiaoxiaodong）。

技能不是项目规范的第二份事实来源：颜色、布局、版本和验证规则以根目录 `AGENTS.md`、`DESIGN.md`、`config/_default/` 与 `scripts/verify-theme.ps1` 为准；skill 只负责把这些规则转成可执行的工作流。

三个 `xxd-*` 技能自带完整 `references/`（742 中华传统色数据），**离线可用，无需联网**；项目专用技能复用这些数据。移动或更新技能后，在当前 pi 会话中运行 `/reload`。

## 技能清单

| 技能 | 用途 | 触发场景 |
|---|---|---|
| `xxd-palette-builder` | 从 742 色筛选主/辅/背景/强调色板 + 比例 | 需要角色化色板时 |
| `xxd-accessible-color` | WCAG 对比度检查 + 同库替代色修复 | 文字/按钮/图表可读性校验 |
| `xxd-existing-design-audit` | 盘点旧色资产，判定保留/合并/替换/移除 | 改版/设计系统清理 |
| `inyo-theme-development` | 执行 Inyo 模板、CSS、token 与发布约束 | 开发或发布主题时 |
| `color-harmony-oklch` | OKLCH 和谐分析、目标对比度搜索与 742 色排序 | 主题或 UI 选色时 |

开发主题时优先使用 `inyo-theme-development`；需要选色或审计时再组合 `xxd-palette-builder`、`xxd-existing-design-audit`、`xxd-accessible-color` 和 `color-harmony-oklch`。不要引用项目中不存在的 `xxd-ui-token`、`xxd-brand-system`、`xxd-palette-applier` 等名称。

## 安装到 Claude Code（可选）

```powershell
Copy-Item -Recurse .pi\skills\xxd-* "$env:USERPROFILE\.claude\skills\"
```

## 安装到 Hermes（可选）

将 `.pi\skills\xxd-*` 复制到 `%LOCALAPPDATA%\hermes\skills\`（或按 Hermes 文档的 skills 目录）。

## 主题开发门禁

```powershell
hugo --source exampleSite --minify
pwsh -File scripts/verify-theme.ps1
git diff --check
```

`inyo-theme-development` 必须与以下项目事实保持同步：Hugo Extended `0.164.0`、Go `1.26.1`、`config/_default/` 默认配置、首页 Hero 资源边界、favicon 固定品牌色例外，以及 `.github/workflows/verify-theme.yml` 的 CI 门禁。

## 与 Inyo 主题的关系

- 本主题的配色（DESIGN.md §2）就是用 `xxd-palette-builder` 的方法论从 742 库点名生成
- `xxd-accessible-color` 负责所有 token 的 WCAG 实测背书
- 主题独有增强（OKLCH 色相和谐分析 + 对比度目标驱动明度搜索）见 [DESIGN.md §6 ADR-1](../DESIGN.md)
