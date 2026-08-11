---
title: "配置参考"
date: 2026-08-07
description: "查阅 Inyo 的主题默认值、站点参数、Markdown 合并规则和语言配置。"
summary: "本文说明 Inyo 的主题默认配置、站点覆盖关系和 Hugo Modules 合并规则。你可以查到字体、数学公式、SEO、作者信息和诗词 Hero 等已实现参数。"
categories: ["文档"]
tags: ["Inyo", "配置", "Hugo Modules"]
---

适合已经完成安装，需要调整站点身份、字体、数学公式、社交卡片或首页 Hero 的站点作者。本文只记录当前主题真实支持的配置；主题默认值来自 `config/_default/`，站点自己的 `hugo.toml` 可以覆盖它们。

## 配置文件的职责

| 文件 | 负责什么 |
|---|---|
| `config/_default/params.toml` | Inyo 的主题运行时默认参数 |
| `config/_default/markup.toml` | 主题默认的 Markdown 高亮行为 |
| `exampleSite/hugo.toml` | 本 Demo 的域名、标题、语言、作者和社交链接 |
| 站点根目录 `hugo.toml` | 使用主题的站点应修改这里 |

Hugo Modules 会把主题默认配置合并到站点配置中；站点配置优先级更高。站点已经定义 `[markup]` 时，要保留 `_merge = "deep"`，否则可能覆盖主题的代码高亮默认值。

## 主题参数

| 参数 | 默认值 | 可选值 | 作用 | 作用范围 |
|---|---|---|---|---|
| `font` | `"wenkai"` | `"wenkai"`、`"serif"` | 选择霞鹜文楷或思源宋体 | 全站 |
| `webfonts` | `true` | `true`、`false` | 是否加载主题字体资源；关闭后使用系统字体栈 | 全站 |
| `subtitle` | `""` | 字符串 | 身份栏标题下方的签名 | 全站 |
| `math` | `false` | `true`、`false` | 全站加载 KaTeX；站点关闭时，单篇文章可用 `math: true` 补充开启 | 全站 / 单页 |
| `mainSections` | `["posts"]` | section 名称数组 | 决定首页目录展示哪些 section | 首页 |
| `ogImage` | `"img/seal-yang.svg"` | `static/` 下的图片路径 | Open Graph 和 Twitter 分享图 | SEO |
| `heroPoetry.api.enabled` | `false` | `true`、`false` | 是否在用户点击 Hero 后请求远程诗词 | 仅首页 |
| `heroPoetry.api.endpoint` | `https://poetry.palemoky.com/api/poems/random` | 可返回兼容 JSON 的 URL | 远程随机诗词端点 | 仅首页 |
| `heroPoetry.api.lang` | `"zh-Hans"` | `"zh-Hans"`、`"zh-Hant"` | 传给诗词接口的语言参数 | 仅首页 |
| `author` | 未设置 | 字符串 | 作者元数据和文章作者信息 | 站点 / 文章 |
| `social` | 未设置 | `name`、`url` 对象数组 | 身份栏社交链接和 Schema `sameAs` | 全站 |

示例：

```toml
[params]
font = "wenkai"
webfonts = true
subtitle = "纸墨二元 · 落字有间"
math = false
mainSections = ["posts"]
ogImage = "img/seal-yang.svg"
author = "Inyo"

[params.heroPoetry.api]
enabled = true
endpoint = "https://poetry.palemoky.com/api/poems/random"
lang = "zh-Hans"

[[params.social]]
name = "GitHub"
url = "https://github.com/FeiNiaoBF/hugo-theme-inyo"
```

`ogImage` 读取 `static/` 路径。Hero 不再使用图片资源；本地诗句来自主题的 `data/inyo/hero_poems.toml`，即使远程接口关闭或失败也能正常交互。

远程接口需要返回对象本身或 `data` 包装对象，并至少提供：

```json
{
  "data": {
    "content": ["第一条非空诗句"],
    "author": { "name": "作者" },
    "title": "作品名"
  }
}
```

主题只取 `content` 的第一条非空内容；缺少有效诗句、作者或作品名时，直接使用本地 fallback。完整 fixture 位于 `scripts/fixtures/chinese-poetry-api-random.json`。

### 可复制的 TOML 示例

```toml
baseURL = "https://example.org/"
title = "Inyo 陰陽"
defaultContentLanguage = "zh-cn"
enableRobotsTXT = true

[languages.zh-cn]
label = "中文"
locale = "zh-CN"
weight = 1

[module]
[[module.imports]]
path = "github.com/FeiNiaoBF/hugo-theme-inyo"

[params]
subtitle = "纸墨二元 · 落字有间"
author = "Inyo"

[params.heroPoetry.api]
enabled = false
endpoint = "https://poetry.palemoky.com/api/poems/random"
lang = "zh-Hans"

[markup]
_merge = "deep"

[markup.goldmark.renderer]
unsafe = true
```

远程 API 默认关闭。开启后，浏览器仅在用户点击首页 Hero 时发起请求；失败、超时或响应不符合上述合同时会静默使用本地诗句。

## Markdown 与代码高亮

站点配置使用：

```toml
[markup]
_merge = "deep"

[markup.goldmark.renderer]
unsafe = true

[markup.goldmark.parser.attribute]
block = true

[markup.highlight]
noClasses = false
```

`unsafe = true` 允许 Demo 使用 `<mark>`、`<kbd>`、`<figure>` 等内联 HTML；`noClasses = false` 保留 Chroma 的语义 class，让主题在亮色和暗色模式下分别提供 token。

## 语言配置

当前 Demo 使用 TOML：

```toml
defaultContentLanguage = "zh-cn"

[languages.zh-cn]
label = "中文"
locale = "zh-CN"
weight = 1
```

主题翻译文件包含 `zh-cn`、`en`、`ja` 的基础 UI key。站点添加更多语言时，需要为内容文件建立对应语言版本，并为语言配置提供 `label`、`locale` 和 `weight`。

## 下一步

- 先创建文章：阅读 [Front Matter 指南](/posts/front-matter/)。
- 查看最终渲染结果：打开[功能展厅](/posts/markdown-style-guide/)。
- 修改字体、Logo 或 Hero：阅读[定制主题](/posts/customization/)。
