---
title: "定制主题"
date: 2026-08-07
description: "在不引入框架和运行时依赖的前提下，定制 Inyo 的字体、Logo、颜色和首页 Hero。"
categories: ["文档"]
tags: ["定制", "字体", "Logo", "Hero"]
---

适合想保留 Inyo 排版骨架，同时调整品牌信息或首页素材的主题使用者。优先使用站点参数；只有在参数无法覆盖时，才使用 Hugo 的模板覆盖机制。

## 字体

在站点 `hugo.toml` 的 `[params]` 中选择字体：

```toml
[params]
font = "wenkai"
webfonts = true
```

- `font = "wenkai"` 使用主题自托管的霞鹜文楷分片。
- `font = "serif"` 使用思源宋体 Web 字体。
- `webfonts = false` 禁止加载 Web 字体，改用系统字体栈。

## 颜色 token

主题运行时颜色集中在 `assets/css/main.css` 的 CSS 变量中。主题维护者修改颜色前，应先查看根目录 `DESIGN.md` 的色表和对比度记录：

```css
:root {
  --paper: ...;
  --ink: ...;
  --cinnabar: ...;
  --camel: ...;
}
```

不要在模板或组件 CSS 中重新写十六进制颜色。新增颜色必须同时考虑亮色、暗色和 WCAG 对比度。

## Logo 与 favicon

网页内联 Logo 使用以下角色 token：

- 圆盘：`--seal-disc`
- 黑鱼：`--seal-ink`
- 白鱼：`--seal-light`
- 外环：`--cinnabar`

它们会随 `data-theme="light"` / `data-theme="dark"` 适配。`static/img/seal-yang.svg` 作为 favicon 没有 CSS 变量上下文，因此继续使用固定品牌色；这是主题明确记录的例外。

## 首页 Hero

Hero 只在首页加载。背景图放在主题或站点的 `assets/img/`，然后配置：

```toml
[params]
heroImage = "img/hero-beauty.jpg"
heroImageQuality = 72
```

Hugo 会在构建期将资源处理为 WebP；文章页、标签页、About 和 404 不会渲染 Hero overlay，也不会加载该背景资源。触屏设备和 `prefers-reduced-motion: reduce` 环境不会启动悬停动画。

选图建议使用低信息密度的古画、水墨、山水或花鸟素材，避免文字和高对比主体。原始宽度建议至少 `1600px`，文件大小控制在 `5MB` 以内。

## 覆盖模板

Hugo 会优先使用站点自己的同名模板。需要改变模板时，在站点中创建对应路径，例如：

```text
layouts/partials/footer.html
layouts/partials/head.html
```

当前主题可覆盖的常用 partial 包括 `head.html`、`footer.html`、`social.html`、`seal.html` 和 `inky-overlay.html`。覆盖前先阅读主题原文件，保留无障碍属性、主题切换脚本和 SEO 输出。

不要为了修改一个文字而复制整套布局；优先使用 `[params]`、内容 Front Matter 或小型 partial 覆盖。

## 下一步

- 查看参数完整列表：阅读[配置参考](/posts/configuration-reference/)。
- 查看实际组件输出：打开[功能展厅](/posts/markdown-style-guide/)。
- 发布前验证定制没有回归：阅读[发布清单](/posts/release-checklist/)。

