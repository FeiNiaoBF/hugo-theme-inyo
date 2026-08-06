# Project-local pi Skills

本项目在 `.pi/skills/` 内提供配色设计技能，pi 会在信任该项目后自动发现。源数据来自 [zhongguo-traditional-colors](https://github.com/nevertoday/zhongguo-traditional-colors)（MIT License，作者 xiaoxiaodong）。

每个技能自带完整 `references/`（742 中华传统色数据），**离线可用，无需联网**。移动或更新技能后，在当前 pi 会话中运行 `/reload`。

## 技能清单

| 技能 | 用途 | 触发场景 |
|---|---|---|
| `xxd-palette-builder` | 从 742 色筛选主/辅/背景/强调色板 + 比例 | 需要角色化色板时 |
| `xxd-accessible-color` | WCAG 对比度检查 + 同库替代色修复 | 文字/按钮/图表可读性校验 |
| `xxd-existing-design-audit` | 盘点旧色资产，判定保留/合并/替换/移除 | 改版/设计系统清理 |

## 安装到 Claude Code

```bash
cp -r .pi/skills/xxd-* ~/.claude/skills/
```

## 安装到 Hermes

将 `.pi/skills/xxd-*` 复制到 `~/AppData/Local/hermes/skills/`（或按 Hermes 文档的 skills 目录）。

## 与 Inyo 主题的关系

- 本主题的配色（DESIGN.md §2）就是用 `xxd-palette-builder` 的方法论从 742 库点名生成
- `xxd-accessible-color` 负责所有 token 的 WCAG 实测背书
- 主题独有增强（OKLCH 色相和谐分析 + 对比度目标驱动明度搜索）见 [DESIGN.md §6 ADR-1](../DESIGN.md)
