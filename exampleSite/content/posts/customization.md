---
title: "定制主题"
date: 2026-08-07
description: "在不引入框架和运行时依赖的前提下，定制 Inyo 的字体、Logo、颜色和首页 Hero。"
summary: "本文介绍如何在保持 Inyo 排版骨架和零依赖约束的前提下定制字体、Logo、颜色与首页诗词 Hero。内容同时说明 CSS token、favicon 品牌色例外、本地诗句和远程 API 的覆盖方式。"
categories: ["文档"]
tags: ["定制", "字体", "Logo", "Hero"]
---

适合想保留 Inyo 排版骨架，同时调整品牌信息或首页诗句的主题使用者。优先使用站点参数；只有在参数无法覆盖时，才使用 Hugo 的模板覆盖机制。

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

Hero 只在首页渲染，初始内容来自 `data/inyo/hero_poems.toml`。点击、触摸、Enter 或 Space 会抽取下一句；文章页、标签页、About 和 404 不会输出诗句数据或交互脚本。

远程诗词是可选增强，主题默认关闭：

```toml
[params.heroPoetry.api]
enabled = true
endpoint = "https://poetry.palemoky.com/api/poems/random"
lang = "zh-Hans"
```

接口仅在用户主动交互后请求。超时、跨域失败、响应字段不完整或连续重复时，主题会静默改用本地诗句，不显示错误文案。

“朱红双翼墨线”只在 Hero 横条内部发生：点击后两条线从底部中央沿底边、左右圆角和侧边上行，最后沿顶部边框在中央合墨；远程或本地诗句就绪后，旧句淡出，新句与作者出处依次落定。等待期间不会增加 loading 文案或图标，`prefers-reduced-motion: reduce` 下则直接替换文字。若要维护自己的本地诗句，可在站点覆盖同路径数据文件，并保持每条记录包含 `text` 与 `source`：

```toml
[[poems]]
text = "行到水穷处，坐看云起时。"
source = "王维《终南别业》"
```

## 首页摘要

文章列表优先使用 Hugo `.Summary`，因此可以在 Front Matter 中写两句 `summary`，或按 Hugo 的内容摘要规则放置手动分隔符。没有手动摘要时 Hugo 会自动生成内容摘要；只有摘要为空时才使用 `description` 兜底。

```yaml
summary: "这里写首页显示的两句文章导读。它可以比 SEO description 更完整。"
```

主题继续使用 CJK/半角宽度感知截断，并将目录摘要限制为最多 3 行。

## 覆盖模板

Hugo 会优先使用站点自己的同名模板。需要改变模板时，在站点中创建对应路径，例如：

```text
layouts/partials/footer.html
layouts/partials/head.html
```

当前主题可覆盖的常用 partial 包括 `head.html`、`footer.html`、`social.html`、`seal.html` 和 `hero-poetry-script.html`。覆盖前先阅读主题原文件，保留 Hero button 的无障碍属性、主题切换脚本和 SEO 输出。

不要为了修改一个文字而复制整套布局；优先使用 `[params]`、内容 Front Matter 或小型 partial 覆盖。

## 下一步

- 查看参数完整列表：阅读[配置参考](/posts/configuration-reference/)。
- 查看实际组件输出：打开[功能展厅](/posts/markdown-style-guide/)。
- 发布前验证定制没有回归：阅读[发布清单](/posts/release-checklist/)。
