---
title: "功能展厅：Markdown 与主题输出"
date: 2026-08-06
description: "用一篇真实页面检查 Inyo 的 Markdown、图片、代码、表格、数学公式、链接和无障碍输出。"
summary: "本文通过一篇真实页面集中展示 Inyo 对标题、链接、图片、代码、表格、引用和数学公式的渲染效果。它也用于检查亮暗模式、首页诗词 Hero、移动端布局与基础无障碍输出。"
categories: ["功能展厅"]
tags: ["Markdown", "样式", "功能展厅"]
math: true
---

这是 Inyo 的功能展厅，不是抽象的 Markdown 语法教程。每个区块都在展示主题实际生成的页面结果；修改主题后，可以用它快速检查亮暗模式、渲染 hook、代码 token 和内容可读性。

## 功能索引

| 能力 | 本页位置 | 观察重点 |
|---|---|---|
| 标题层级与锚点 | [标题](#标题层级与锚点) | 标题结构、悬停锚点和键盘焦点 |
| 链接 | [链接](#链接) | 站外新窗口、安全 rel 和站内链接 |
| 图片与 `alt` | [图片](#图片) | 图片缩放、懒加载和替代文本 |
| 引用与列表 | [引用与列表](#引用与列表) | 长文节奏和嵌套内容 |
| 表格 | [表格](#表格) | 横向滚动和简洁分隔线 |
| 代码块 | [代码块](#代码块) | Chroma class token 和内部滚动 |
| 数学公式 | [数学公式](#数学公式) | 页面级 KaTeX 开关 |
| 暗色与 Hero | [主题交互](#主题交互) | 主题切换、随机诗句和 reduced-motion |

## 标题层级与锚点

本页使用从 `h1` 到 `h4` 的层级。标题锚点由 render hook 生成，悬停标题时会出现 `#`：

### 一个三级标题

#### 一个四级标题

点击标题右侧的锚点可以复制章节链接；键盘用户也应该能够看到焦点环。

## 链接

站内链接会留在当前页面，例如[宣纸与墨](/posts/paper-and-ink/)。站外链接会自动在新窗口打开，并添加 `noopener noreferrer`，例如 [Hugo 官方文档](https://gohugo.io/documentation/)。

下面两个链接专门用于检查安全策略：[协议相对链接](//example.org) 与 [不安全链接](javascript:alert(1))。

## 图片

Markdown 图片会经过主题的 image render hook：

![双鱼太极 Markdown 图片](/img/seal-yang.svg)

图片的替代文本必须说明图片内容；不要把 `alt` 留空或只写“图片”。

## 引用与列表

> 天地不仁，以万物为刍狗。
>
> **提示**：引用块内仍然可以使用 _Markdown 语法_。

1. 第一项
2. 第二项
3. 第三项

- 内容项
  - 嵌套内容
- 另一项

## 表格

| 主题能力 | 结果 | 检查方式 |
|---|---|---|
| 亮暗模式 | 使用同一套语义 token | 点击主题按钮 |
| 代码高亮 | 使用 Chroma class | 查看生成 HTML |
| 图片 | 有替代文本并按需加载 | 检查 DOM |

表格使用横向分隔线，不依赖卡片、斑马纹或额外背景色。

## 代码块

主题保留 Chroma 的语义 class，让 CSS token 同时服务亮色和暗色模式：

```toml
[params]
font = "wenkai"
math = false
```

```go
package main

import "fmt"

func main() {
	fmt.Println("Inyo")
}
```

长代码块应在代码区域内部滚动，而不是让整个页面产生横向溢出。

## 行内 HTML

站点配置开启 `markup.goldmark.renderer.unsafe` 后，可以使用主题支持的语义元素：

H<sub>2</sub>O、X<sup>n</sup>、<abbr title="Graphics Interchange Format">GIF</abbr>、<kbd>Ctrl</kbd> + <kbd>K</kbd>、<mark>重点内容</mark> 和 <del>删除内容</del>。

## 数学公式

本页的 Front Matter 设置了 `math: true`，因此会加载 KaTeX。

行内公式：$E = mc^2$

行间公式：

$$
\sum_{k=1}^{n} k = \frac{n(n+1)}{2}
$$

不需要公式的文章不要开启这个开关，以免加载额外资源。

## 主题交互

- 点击身份栏的 ☯ 按钮，在亮色和暗色之间切换。
- 回到首页，点击或聚焦 Hero 后按 Enter / Space，可以抽取“诗句 + 作者出处”。
- 远程接口不可用时，Hero 会继续从本地诗句中抽取，不显示错误状态。
- 文章页、标签页、About 和 404 不会加载 Hero 诗句数据或交互脚本。
- 在系统中启用“减少动态效果”后，Hero 直接换句，不执行墨线落字动画。

## 无障碍检查点

- 使用跳到正文链接进入 `#main-content`。
- 标题、链接和按钮都能通过键盘访问。
- 图片拥有有意义的 `alt`。
- 外部新窗口链接带有 `noopener noreferrer`。
- 页面正文保持横排，不依赖竖排才能理解内容。

## 下一步

- 开始安装：阅读[主题入门](/posts/getting-started/)。
- 创建自己的文章：阅读 [Front Matter 指南](/posts/front-matter/)。
- 修改视觉与交互：阅读[定制主题](/posts/customization/)。

## Render hook 测试

这个带属性的标题和链接用于验证主题的渲染 hook：

### Hook fixture {#render-hook-fixture data-kind="hook"}

[协议相对链接](//example.org) 与 [不安全链接](javascript:alert(1)) 用于验证主题的链接渲染策略。
