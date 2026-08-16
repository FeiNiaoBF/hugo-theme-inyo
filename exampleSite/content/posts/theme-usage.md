---
title: "用 Inyo 写一篇文章"
date: 2026-08-14T09:00:00+08:00
description: "从安装主题到写出第一篇文章，记录 Inyo Demo 的最小使用路径。"
summary: "我把 Inyo 接到一个空白 Hugo 站点里，从模块安装、文章创建到首页置顶走了一遍。这里留下最少但够用的配置，方便下一次重新开始。"
pinned: true
categories:
  - 使用
tags:
  - Inyo
  - Hugo
  - 开始
math: false
---

我第一次把 Inyo 接到自己的 Blog 时，手边只有一个空目录。没有先改颜色，也没有急着换字体，先把一篇文章从文件写到首页，比较容易知道主题到底顺不顺手。

## 从一个空站点开始

Hugo Modules 是我更推荐的安装方式。它把主题当作模块管理，站点配置也留在自己的仓库里。最小流程只需要几条命令：

```shell
hugo new site my-blog --format yaml
cd my-blog
hugo mod init example.com/my-blog
hugo mod get github.com/FeiNiaoBF/hugo-theme-inyo@latest
hugo server
```

## 更新主题

Hugo Modules 会把解析后的主题版本写入站点的 `go.mod`。更新 Inyo 时，在站点根目录运行：

```shell
hugo mod get github.com/FeiNiaoBF/hugo-theme-inyo@latest
hugo mod tidy
hugo --minify
```

`@latest` 只出现在更新命令中，不要直接写进 `go.mod`。如果 Go 代理还没有同步最新 release，可以临时使用 `GOPROXY=direct` 后重试；PowerShell 可先执行 `$env:GOPROXY = "direct"`。对于 Hugo 站点，请使用 `hugo mod tidy`；单独运行 `go mod tidy` 可能因为站点没有 Go 包而移除主题依赖。

站点的 `hugo.yaml` 可以先保持简单：

```yaml
baseURL: "https://example.com/"
title: "我的 Blog"
defaultContentLanguage: "zh-cn"

module:
  imports:
    - path: "github.com/FeiNiaoBF/hugo-theme-inyo"

params:
  subtitle: "写字，读书，留下几页"
  author: "你的名字"

markup:
  _merge: "deep"
```

这里的 `hugo.yaml` 是站点配置，不是文章 Front Matter。文章本身也使用 YAML，但写在 Markdown 文件最上方并由 `---` 包围。

## 启动 Hugo

完成站点配置后，在站点根目录启动本地预览：

```shell
hugo server --buildDrafts
```

然后访问 `http://localhost:1313/`。`--buildDrafts` 会同时渲染标记为 `draft: true` 的文章；如果只想预览正式内容，可以运行 `hugo server`。按 `Ctrl+C` 停止本地服务器。

正式发布前，可以先生成压缩后的静态文件：

```shell
hugo --minify
```

## 写下第一篇文章

```shell
hugo new content posts/first-note.md
```

生成文章后，我通常只先填这些字段：

```yaml
---
title: "第一篇文章"
date: 2026-08-14T10:00:00+08:00
description: "一行说明这篇文章要写什么。"
summary: "这里写给首页读者看的两句导读，可以比 description 更完整一些。"
pinned: false
categories:
  - 随笔
tags:
  - 写作
math: false
---
```

`description` 更像文章的名片，会参与页面描述和社交分享；`summary` 是目录里的导读，适合把文章真正的开头交代清楚。`pinned: true` 会让文章进入首页的置顶区域，可以有多篇置顶文章。

## 页面之间怎么走

首页只负责把文章列出来。点击标题进入文章页，文章页会显示正文、日期、阅读时间和标签；点击标签后可以继续查看同一类文章。归档页则把文章按年份收起来，适合回头找旧内容。

首页的 Hero 诗句也是一个很小的入口：点击或按下 Enter、Space，它会换一条诗句。网页没有背景画，亮暗模式只改变纸与墨的关系，文章本身仍然是页面的主角。

## 下一步

- 先看看 [Markdown 基础：先把字排好](/posts/markdown-basics/)，确认常用语法在页面上的样子。
- 如果准备写长文，接着读 [Markdown 高效写作](/posts/markdown-efficient/)。
- 想知道这个主题为什么这样设计，可以读[纸、墨与朱红](/posts/brand-design/)。
