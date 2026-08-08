---
title: "Front Matter 指南"
date: 2026-08-07
description: "使用最小而清晰的 Front Matter 控制文章标题、摘要、标签、日期和数学公式。"
summary: "本文提供一份可复制的 Inyo 文章 Front Matter 模板，并解释标题、日期、摘要、分类与标签的页面影响。你还会看到页面级数学开关、图片替代文本和 SEO 字段的推荐写法。"
categories: ["文档"]
tags: ["写作", "Front Matter", "SEO"]
---

适合已经安装好主题，准备创建第一篇文章的作者。Front Matter 放在 Markdown 文件最顶部，用来告诉 Hugo 如何组织、摘要和渲染这篇内容。

## 最小文章模板

当前 Demo 使用 YAML Front Matter：

```yaml
---
title: "一篇文章的标题"
date: 2026-08-07
description: "用于目录和搜索引擎的一句话摘要。"
categories: ["随笔"]
tags: ["写作", "Inyo"]
---

正文从这里开始。
```

Hugo 也支持 TOML 和 JSON，但同一篇文章只使用一种格式。项目文档中的站点配置统一使用 TOML；文章示例使用 YAML，是因为它更适合阅读和复制。

## 字段速查

| 字段 | 示例 | 影响 |
|---|---|---|
| `title` | `"文章标题"` | 文章页标题、目录标题、页面标题 |
| `date` | `2026-08-07` | 日期显示、目录排序、文章元数据 |
| `description` | `"一句话摘要"` | 目录摘要、`description`、OGP 和 Twitter 描述 |
| `summary` | 一段文字 | 可显式提供 Hugo 摘要；未提供时主题按描述、首段和 Hugo 摘要回退 |
| `categories` | `["随笔"]` | 分类整理和分类 taxonomy |
| `tags` | `["Inyo"]` | 文章页标签、标签索引和标签详情页 |
| `math` | `true` | 仅当前文章加载 KaTeX |
| `aliases` | `["/old-path/"]` | 保留旧地址的跳转入口 |

## 摘要写法

目录摘要的回退顺序是：

1. 当前页面的 `description`。
2. 正文第一个有效段落。
3. Hugo 生成的摘要。

推荐为教程、发布说明和配置参考显式写 `description`，让首页目录在不打开全文时也能说明页面用途。

## 标签与分类

标签适合描述可交叉检索的主题，例如 `Hugo`、`配置`、`写作`。分类适合较稳定的内容分组，例如 `文档`、`随笔`、`设计`。标签会直接显示在文章页并链接到 `/tags/`。

## 单篇启用数学公式

主题默认关闭数学公式。只需要在当前文章开启：

```yaml
math: true
```

正文中即可使用：

```markdown
行内公式：$E = mc^2$

行间公式：

$$
\sum_{k=1}^{n} k = \frac{n(n+1)}{2}
$$
```

不使用公式的页面不要开启 `math`，这样可以避免加载不需要的 KaTeX 资源。

## 图片与可访问性

Markdown 图片的方括号内容就是替代文本：

```markdown
![双鱼太极品牌图形](/img/seal-yang.svg)
```

不要使用“图片”“截图”这类无法说明内容的 `alt`。如果图片只是装饰，也应根据页面语义决定是否使用空替代文本，而不是省略 `alt`。

## 下一步

- 查看这些字段实际如何渲染：打开[功能展厅](/posts/markdown-style-guide/)。
- 调整站点参数：阅读[配置参考](/posts/configuration-reference/)。
- 发布前逐项检查：阅读[发布清单](/posts/release-checklist/)。
