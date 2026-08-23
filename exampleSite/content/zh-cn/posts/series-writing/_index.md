---
layout: series
title: "把文章连成一条路"
description: "用 Hugo section 组织系列文章，同时保留每篇文章的独立阅读体验。"
summary: "系列不是把标题写成（一）（二），而是给一组文章一张可以返回、浏览和继续写作的地图。"
draft: false
cascade:
  layout: post
---

我把系列理解成一条有入口的阅读路径。入口负责说明为什么写、现在写到哪里；每一篇文章仍然应该能被单独打开、加入标签和放进归档。

这个 Demo 使用 Hugo 的 `_index.md`、`layout`、`weight` 和 `lastmod`，没有额外 taxonomy，也不从标题猜测文章关系。
