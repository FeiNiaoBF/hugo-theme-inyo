---
title: "Portable theme smoke test"
date: 2026-08-12T00:00:00+08:00
description: "An independent article description used by the consumer fixture."
summary: "This article confirms that Inyo renders a custom main section without relying on the bundled example site. It also exercises portable navigation, taxonomy, metadata, and summary behavior."
draft: false
labels:
  - portability
---

The consumer fixture deliberately uses `notes` instead of `posts` and `labels` instead of `tags`.

```go
func portable() bool {
    return true
}
```
