---
title: "发布清单"
date: 2026-08-07
description: "在部署 Inyo 站点前，完成构建、生成物合同、空白字符和浏览器复核。"
summary: "本文整理 Inyo 发布前必须执行的 Hugo 构建、PowerShell smoke test 与 Git 空白检查。清单还覆盖亮暗模式、移动端、诗词 API fallback、双翼墨线和 reduced-motion 的浏览器复核。"
categories: ["文档"]
tags: ["发布", "CI", "验证"]
---

适合准备把站点部署到生产环境，或准备提交主题修改的作者。本文只使用项目已经存在的验证门禁，不要求浏览器自动化或新的测试框架。

## 自动化门禁

在主题仓库根目录执行：

```powershell
hugo --source exampleSite --minify
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
git diff --check
```

四条命令分别确认：

- Hugo 可以用当前模块和配置生成站点。
- P1/P2、配置、SEO、a11y、颜色 token 和 Hero 诗词合同通过。
- 独立消费者站点、可配置导航和默认 archetype 合同通过。
- 修改没有引入尾随空格或其他空白字符错误。

GitHub Actions 会在 `push` 和 `pull_request` 上分别执行 Demo smoke 与独立 consumer smoke。CI 通过是发布主题前的必要门禁。

Consumer smoke 还会用自定义的 `notes` section 和 `labels` taxonomy 构建一次站点，并覆盖 `/blog/` 子路径部署。需要单独复核时执行：

```powershell
hugo --source scripts/fixtures/consumer-site `
     --baseURL "https://consumer.example/blog/" `
     --minify
```

这次子路径检查应确认生成的 CSS 使用 `../fonts/` 加载自托管字体；不要把 `assets/css/wenkai.css` 改回根路径 `/fonts/...`。

## 模块发布检查

如果你之前使用了本地主题替换，发布前确认模块配置指向远程仓库：

```powershell
hugo mod graph
hugo mod tidy
```

不要提交只能在本机解析的 `../hugo-theme-inyo` 路径。部署平台需要能够下载公开的远程模块和其依赖。

## 浏览器复核

在桌面默认视口检查：首页、文章页、文章列表、标签索引、标签详情、About 和 404。

再用 `390×844` 检查：首页、文章页、标签索引和标签详情。

- 亮色与暗色主题都可读，主题按钮可以键盘操作。
- Skip link 可以跳到 `#main-content`，焦点环清晰可见。
- 页面没有横向溢出，代码块在代码区域内部滚动。
- Hero 只出现在首页；文章页没有诗句数据、API 地址或交互脚本。
- 点击、触摸、Enter 与 Space 都能换句；点击后 100ms 内出现即时反馈，慢 API 下当前诗句保持不变。
- 朱红双翼墨线沿 Hero 圆角边框从底部中央向左右上行，并在顶部中央合墨；API 失败或超时会使用本地 fallback。
- 描边路径与 Hero 边框重合，只播放一次，不形成持续循环；低性能设备没有明显卡顿。
- `prefers-reduced-motion` 下 Hero 直接换句，不启动双翼墨线、位移或模糊动画。
- 首页文章摘要来自 Hugo `.Summary`，稳定显示 2–3 行；Front Matter `summary` 与 Hugo 手动摘要分隔符均有效。
- 文章图片有有意义的 `alt`，外部新窗口链接包含 `noopener noreferrer`。

## 常见失败

| 现象 | 优先检查 |
|---|---|
| 代码高亮颜色异常 | 站点 `[markup]` 是否保留 `_merge = "deep"`，以及 `noClasses = false` |
| 本地可以构建，CI 失败 | 是否残留本地模块替换、版本是否使用 Hugo Extended `0.164.0` |
| Consumer 文章标签仍指向 `/tags/` | 检查 `params.navigation.tags`，标签链接不能在模板中硬编码 |
| Consumer 404 仍指向 `/posts/` | 检查 `params.mainSections[0]`，404 返回入口不能固定文章 section |
| `/blog/` 部署后字体丢失 | 检查 `assets/css/wenkai.css` 是否仍使用相对 `../fonts/` 路径 |
| 文章没有公式 | 页面 Front Matter 是否写了 `math: true` |
| Hero 在文章页出现 | 是否覆盖了 `baseof.html`，并把首页诗词 partial 放到了全站 |
| 点击 Hero 没有远程诗句 | 检查 endpoint、CORS 和网络；本地 fallback 应仍然可用 |
| 暗色 Logo 不清晰 | 是否使用了 `seal` 角色 token，而不是固定颜色 |

## 下一步

- 返回[主题入门](/posts/getting-started/)。
- 查看[配置参考](/posts/configuration-reference/)。
- 继续检查[功能展厅](/posts/markdown-style-guide/)中的真实输出。
