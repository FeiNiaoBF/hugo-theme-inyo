---
title: "主题入门"
date: 2026-08-07
description: "用 Hugo Modules 在五分钟内安装 Inyo，并确认主题已经正确工作。"
categories: ["文档"]
tags: ["Inyo", "安装", "入门"]
aliases:
  - /posts/theme-guide/
---

适合第一次使用 Inyo，或刚开始接触 Hugo 主题的站点作者。完成本文后，你会得到一个可以本地预览的 Inyo 站点，并知道接下来应该去哪里查配置和写作规则。

如果你只想先看主题能渲染什么，请先打开[功能展厅](/posts/markdown-style-guide/)。如果你已经安装完成，可以直接阅读[配置参考](/posts/configuration-reference/)和 [Front Matter 指南](/posts/front-matter/)。

## 环境要求

- Hugo Extended `0.164.0`
- Go `1.26.1` 或更高版本（仅 Hugo Modules 流程需要）
- Git

确认版本：

```powershell
hugo version
go version
```

## 方式一：Hugo Modules

这是新站点的推荐方式。先创建站点并初始化模块：

```powershell
hugo new site my-inyo-site
Set-Location my-inyo-site
hugo mod init example.org/my-inyo-site
```

在站点根目录创建或编辑 `hugo.toml`：

```toml
baseURL = "https://example.org/"
title = "我的 Inyo 站点"
defaultContentLanguage = "zh-cn"

[module]
[[module.imports]]
path = "github.com/FeiNiaoBF/hugo-theme-inyo"

[params]
subtitle = "纸墨二元 · 落字有间"
author = "你的名字"

[markup]
_merge = "deep"
```

拉取模块并启动本地服务器：

```powershell
hugo mod tidy
hugo server --buildDrafts
```

打开终端显示的本地地址。首页应出现 Inyo 的身份栏和文章目录；文章页、标签页和 About 页会共用同一套纸墨主题样式。

### 本地联调主题源码

如果你正在修改 Inyo 源码，可以在站点的 `go.mod` 中临时增加 Go Modules 的 `replace` 指令：

```text
replace github.com/FeiNiaoBF/hugo-theme-inyo => ../hugo-theme-inyo
```

本仓库的 `exampleSite/go.mod` 使用 `../` 指向仓库根目录；你的站点应按实际目录关系填写路径。修改后运行：

```powershell
hugo mod tidy
```

发布前删除这行本地替换，保留远程模块依赖。不要把只存在于本机的相对路径带到 Vercel、Netlify 或 GitHub Actions；全新构建环境应能直接下载远程模块。

## 方式二：经典 `themes/` 目录

不使用 Hugo Modules 时，可以将主题放进站点的 `themes/` 目录：

```powershell
git clone https://github.com/FeiNiaoBF/hugo-theme-inyo.git themes/inyo
```

然后在 `hugo.toml` 中指定主题：

```toml
theme = "inyo"
```

两种安装方式只能选择一种。已经使用 `module.imports` 时，不需要再配置 `theme`。

## 下一步

- 需要知道每个参数的默认值：阅读[配置参考](/posts/configuration-reference/)。
- 准备写第一篇文章：阅读 [Front Matter 指南](/posts/front-matter/)。
- 想检查所有渲染能力：打开[功能展厅](/posts/markdown-style-guide/)。
