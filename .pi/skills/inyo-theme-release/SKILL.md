---
name: inyo-theme-release
description: Use when 发布或验证 hugo-theme-inyo 的可分发性、Hugo Modules 兼容性、consumer fixture、GitHub Pages Demo、README/CHANGELOG 或版本基线。
---

# Inyo Theme Release

## Overview

按 Inyo 当前真实仓库结构执行发布前检查：主题元数据、示例站、独立 consumer、子路径资源、GitHub Pages、用户文档和生成物清理。它只编排已有脚本和 CI 合同，不替代 `AGENTS.md`、`DESIGN.md` 或 `scripts/verify-*.ps1`。

## Source of truth

- 版本：Hugo Extended `0.164.0`、Go `1.26.1`。
- 分发：`theme.toml`、`images/screenshot.png`、`images/tn.png`、`static/img/seal-yang-og.png`。
- 验证：`scripts/verify-theme.ps1`、`scripts/verify-consumer.ps1`、`.github/workflows/verify-theme.yml`。
- Demo：`.github/workflows/deploy-demo.yml`，构建 `exampleSite` 并部署到项目 Pages 子路径。
- 兼容性：`scripts/fixtures/consumer-site/go.mod` 必须使用固定 `replace ... => ../../..`。
- 规则冲突时，以根目录 `AGENTS.md` 和 `DESIGN.md` 为准。

## 发布前工作流

### 1. 检查范围

- 先运行 `git status --short --untracked-files=all`，保留用户已有修改。
- 不修改 `demo-shots/`、`exampleSite/public/`、`resources/`；后两者只作为可清理的生成物处理。
- 发布文档只描述仓库中已实现的参数、模板和验证命令，不新增未实现的配置。

### 2. 运行自动门禁

从仓库根目录按顺序运行：

```shell
hugo --source exampleSite --minify --printPathWarnings
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
git diff --check
```

`verify-theme.ps1` 已覆盖：主题分发资源、README 合同、SEO、导航、a11y、i18n、Hero、摘要、颜色 token 和 GitHub Pages 子路径输出。`verify-consumer.ps1` 已覆盖：自定义 `notes` section、`labels` taxonomy、文章标签、404、`/blog/` 字体路径和 archetype。

### 3. 检查用户文档

- `README.md` 是中文入口，顶部应提供居中的 `README.en.md` 链接；英文 README 必须包含 Quick Start、Modules、Demo、Docs、Contributing 和 License。
- 安装示例使用 `github.com/FeiNiaoBF/hugo-theme-inyo@latest`，不要把旧 tag 当默认安装版本。
- README 不放完整参数表；参数详情留在 `exampleSite/content/posts/configuration-reference.md`。
- 维护文档使用三反引号代码围栏；通用命令块标记为 `shell`，不要新增 `~~~` 围栏。
- 致谢必须使用“借鉴/参考”，并保留 zhongguo-traditional-colors、pianpker、LXGW WenKai 与 Hugo 的链接。

### 4. 检查 GitHub Pages

- workflow 只在 `main` push 或手动触发时部署；Pull Request 由验证 workflow 检查，不部署。
- 必须使用 `actions/configure-pages`、`actions/upload-pages-artifact` 和 `actions/deploy-pages`，权限包含 `pages: write` 与 `id-token: write`。
- Hugo 使用 `steps.pages.outputs.base_url` 构建 `exampleSite`，不得写死根路径资源。
- 重点确认首页、文章页、Markdown 图片、RSS、CSS、favicon、字体和文章内链保留项目子路径。

### 5. 发布与版本

- 先更新 `CHANGELOG.md` 的 `Unreleased`，再根据真实 Git 历史整理版本条目。
- `theme.toml` 的 `min_version`、根目录 `go.mod`、CI 的 Go 版本和 Hugo 版本必须一致。
- 只有用户明确要求时才创建 tag、commit、push 或 PR；默认只验证本地工作区。
- 不提交 `exampleSite/public/`、`resources/`、`.hugo_build.lock` 或临时 consumer 输出。

## 失败处理

- 构建失败：先读 Hugo 错误位置和当前配置，不用删除用户内容来“让测试通过”。
- consumer 失败：优先检查 `mainSections`、`params.navigation`、taxonomy 配置和固定相对 `replace`。
- Pages 子路径失败：检查模板是否使用 `RelPermalink`、`urls.Parse` 或经过验证的 Hugo URL 处理；禁止恢复 `/posts/`、`/tags/`、`/fonts/` 等根路径硬编码。
- 文档合同失败：只补充缺失的真实文案或链接，不放宽 smoke 正则。
