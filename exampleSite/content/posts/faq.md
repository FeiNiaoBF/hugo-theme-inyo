---
title: "常见问题"
date: 2026-08-10T09:00:00+08:00
description: "Inyo 主题常见问题的记录入口，内容会随着真实使用逐步补充。"
summary: "记录 Inyo 安装、更新、置顶、字体、诗词接口和部署中容易遇到的问题。"
categories:
  - 主题
tags:
  - FAQ
  - Inyo
math: false
---

## 如何更新 Inyo 主题？

如果站点通过 Hugo Modules 安装 Inyo，请在站点根目录运行：

```shell
hugo mod get github.com/FeiNiaoBF/hugo-theme-inyo@latest
hugo mod tidy
hugo --minify
```

第一条命令会把 `@latest` 解析成具体版本，并更新 `go.mod` 与 `go.sum`。`go.mod` 中应保存具体的语义化版本号，不要直接写入 `@latest`。

如果 Go 代理尚未同步最新 release，可临时使用 `GOPROXY=direct` 后重试；PowerShell 可先执行 `$env:GOPROXY = "direct"`。Hugo 站点应使用 `hugo mod tidy`；单独运行 `go mod tidy` 可能因为站点没有 Go 包而移除仅由 `hugo.yaml` 引用的主题依赖。

更新后请检查构建输出；如果版本标签尚未发布到远程仓库，`@latest` 无法获取仅存在于本地的主题版本。

## `pinned: true` 是什么？

`pinned: true` 会把文章放入首页的“置顶”分组，并排在普通文章之前。置顶文章仍按日期倒序排列；多篇文章可以同时置顶。

```yaml
---
pinned: true
---
```

删除该字段或设置为 `pinned: false` 即可取消置顶。多语言文章的每个 `index.{lang}.md` 独立判断；如果三种语言都要置顶，需要分别添加该字段。

## 下一步

如果你刚开始使用 Inyo，可以先读[用 Inyo 写一篇文章](/posts/theme-usage/)。
