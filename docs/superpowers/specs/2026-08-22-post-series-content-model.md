# Inyo Post 与 Series 内容模型设计

日期：2026-08-22
状态：已实施并验证

## 目标

在不改变普通文章使用体验的前提下，为 Inyo 增加由 Hugo section 驱动的系列文章能力。普通文章和系列文章使用明确的 `layout` 语义；首页与博客目录把一个系列显示为一个入口，系列内部文章仍是可独立阅读、归档和标记标签的普通页面。

## Hugo 模型

### `layout: post`

- 表示普通文章详情页。
- 普通文章和系列中的单篇文章都使用这套格式。
- `layout` 省略时仍按 `post` 渲染，以兼容现有内容。
- `archetypes/default.md` 显式生成 `layout: post`，让新文章的语义清楚。

### `layout: series`

- 仅用于系列目录中的 `_index.md` branch bundle。
- 一个系列目录只直接包含文章，不支持章节子 section。
- 系列身份来自 `.Layout == "series"`，不解析 `xxx(1)`、`xxx(2)` 等标题，也不通过文章数量推断。
- 一个已发布子文章的目录也属于系列。

Hugo 的 `layout` 字段是模板文件名选择器。主题使用：

```text
layouts/_default/post.html
layouts/_default/series.html
layouts/_default/single.html
```

其中 `single.html` 是未声明 `layout` 时的 `post` 兼容回退。这个路径选择遵循 Hugo 0.164 之后的官方模板查找规则：

- <https://gohugo.io/templates/lookup-order/>
- <https://gohugo.io/methods/page/layout/>

## 内容结构

```text
content/posts/
├── ordinary-post.md
└── mit-6s081/
    ├── _index.md
    ├── 01-file-descriptor.md
    └── 02-process.md
```

普通文章：

```yaml
---
layout: post
title: "一篇普通文章"
date: 2026-08-22T09:00:00+08:00
description: "用于 SEO 的说明。"
summary: "用于目录的导读。"
draft: false
math: false
categories: []
tags: []
---
```

系列目录：

```yaml
---
layout: series
title: "MIT 6.S081"
description: "MIT 6.S081 操作系统课程笔记。"
summary: "从系统调用开始，逐步整理进程、文件系统和并发模型。"
pinned: false
draft: false
cascade:
  layout: post
---
```

系列文章：

```yaml
---
layout: post
title: "文件描述符"
date: 2026-08-22T09:00:00+08:00
lastmod: 2026-08-23T09:00:00+08:00
weight: 10
description: "文件描述符的阅读笔记。"
summary: "从进程打开文件时获得的整数句柄，理解 Unix 的统一 I/O 接口。"
draft: false
math: false
categories: []
tags: []
---
```

## 首页与博客目录

首页和主博客 section 使用同一份组合目录数据：

1. 收集 `params.mainSections` 下不属于 `layout: series` section 的普通文章。
2. 收集每个主 section 的直接子 section 中显式声明 `layout: series` 的系列。
3. 不把系列内部文章作为独立目录条目，避免系列和章节重复出现。
4. 普通文章仍链接文章详情；系列标题链接系列总览。

系列条目显示为：

```text
[SVG 系列图标] MIT 6.S081：文件描述符
系列 · 共 10 篇 · 最近更新 2026-08-23
```

- 标题由“系列名 + 最新更新文章标题”组成。
- SVG 图标属于标题链接，使用 `currentColor`，并设置 `aria-hidden="true"`；可见的“系列”文字负责语义，不依赖颜色或图标独立传达。
- 目录摘要来自系列 `_index.md` 的 `.Summary`，为空时回退 `.Description`，继续使用既有 140 全宽单位和三行截断。
- 系列最近更新时间取所有子文章“有效更新时间”的最大值：优先 `.Lastmod`，零值时明确回退 `.Date`。这个时间只负责目录新鲜度，不改变系列阅读顺序。
- 系列 `_index.md` 的 `pinned: true` 置顶整个系列；系列内部文章的 `pinned` 不单独进入目录。
- 普通文章继续按 `.Date` 排序；系列按计算出的最近更新时间排序。置顶组与普通组都按各自条目的目录日期倒序。
- 首页继续按目录日期分组；博客 section 保持平铺目录。
- 空系列不进入首页或博客目录；有一篇已发布文章的系列正常进入。

归档页、标签页和 RSS 继续面向普通文章页面，因此系列文章仍可独立出现；只有首页与主博客目录进行系列折叠。

## 系列总览

系列总览页包含：

- H1 内的 SVG 系列图标和系列标题。
- `_index.md` 提供的可选正文简介；无正文时不输出简介容器。
- 仅由两位序号和文章标题组成的有序目录，每一行都是完整链接。
- 与普通文章相同的阅读宽度，并以留白而非分隔线组织目录。

总览不显示返回主博客、可见“系列”标记、篇数、最近更新时间、文章日期、阅读时间或摘要；这些数据仍可用于 Home/Blog 目录新鲜度与系列文章导航，不改变内容模型。

文章顺序分为两组后连接：

1. 非零 `weight` 的文章使用 Hugo `.ByWeight` 升序。
2. 没有 `weight` 或 `weight: 0` 的文章使用 `.ByDate` 按发布日期升序，保持从旧到新的自然阅读顺序。

这样既允许作者显式维护课程顺序，也让遗漏 `weight` 的文章按发布日期稳定接在显式顺序之后。`lastmod` 只影响系列入口的“最近更新”，不会重新排列篇章。

## 系列文章页

系列文章继续使用 `post` 详情模板，并额外显示：

- 标题上方包含系列名称的返回总览链接，例如“返回「MIT 6.S081」”。
- 当前进度，例如“第 2 / 10 篇”。
- 按系列总览同一顺序计算的上一篇、下一篇。

普通文章保留现有返回 section、日期、阅读时间、标签和 `PrevInSection` / `NextInSection` 行为。

## 多语言与可访问性

- 中文、英文、日文同时增加系列名称、篇数、最近更新、进度和返回系列的 i18n 文案。
- 系列图标不使用 emoji，不接受键盘焦点，不替代可见文字。
- 标题链接保留全局 `:focus-visible` 焦点环。
- hover 反馈放入 `@media (hover: hover)`；不新增非必要动画。
- 新样式复用现有颜色 token，同时覆盖亮色纸面、暗色墨面和 `390×844` 移动视口。

## 公开配置与非目标

- 不新增 `series` taxonomy。
- 不新增主题参数；`layout`、section、`_index.md`、`weight`、`date`、`lastmod`、`cascade` 均使用 Hugo 原生内容能力。
- 不自动解析标题中的序号。
- 不支持跨 section 系列、章节子 section、相关文章、搜索或自定义 shortcode。
- shortcode 保持独立的后续设计，不与本次内容模型耦合。

## 验收标准

- 没有 `layout` 的现有文章与 `layout: post` 文章生成相同结构。
- 首页和主博客目录各只显示一个系列入口，不显示该系列子文章的独立入口。
- 系列标题链接进入系列总览，组合标题、篇数和最近更新时间正确。
- 单篇系列、置顶系列、`lastmod` 回退、`weight` 排序和日期回退均有 fixture 断言。
- 系列文章显示正确进度以及上一篇、下一篇；普通文章导航无回归。
- 自定义 `notes` section、`labels` taxonomy 和 `/blog/` 子路径 fixture 继续通过。
- 亮暗模式、桌面、`390×844`、键盘焦点和横向溢出检查通过。
- 四个仓库门禁命令全部通过，生成目录和锁文件不进入工作区。
