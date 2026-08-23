---
name: inyo-content-authoring
description: Use when writing or revising Inyo exampleSite articles, About copy, YAML front matter, Markdown feature examples, summaries, internal links, or KaTeX demonstrations. Use this for content quality and content contracts, not for runtime template changes.
---

# Inyo Content Authoring

## Purpose

Maintain a small Demo that reads like a person wrote it while still proving the theme's real Markdown, taxonomy, summary, pinning, math, accessibility, and subpath behavior.

`AGENTS.md` defines project rules, `DESIGN.md` defines brand intent, and `scripts/verify-theme.ps1` defines the executable Demo contract. Do not invent capabilities that are absent from the theme.

## Content map

The Demo keeps six independent articles directly under `exampleSite/content/zh-cn/posts/`:

| File | Job |
| --- | --- |
| `theme-usage.md` | Install Inyo, create a post, explain `description`, `summary`, and `pinned` |
| `markdown-basics.md` | Show headings, prose, emphasis, lists, quotes, links, images, code, tables, and heading attributes |
| `markdown-efficient.md` | Show long-form structure, task lists, anchors, keyboard markup, and link safety |
| `katex.md` | Show page-level math and representative KaTeX forms |
| `faq.md` | Hold only questions learned from real use; honest placeholders are allowed |
| `brand-design.md` | Explain paper, ink, cinnabar, reading priority, and the poetry Hero |

The Demo also contains one series tree:

| File | Job |
| --- | --- |
| `series-writing/_index.md` | Define the series overview, metadata, and article defaults |
| `series-writing/01-boundary.md` | Demonstrate the first explicitly weighted article |
| `series-writing/02-navigation.md` | Demonstrate series progress and previous/next navigation |

`exampleSite/content/zh-cn/about.md` is the Chinese Demo index and must link to all six root independent articles plus the series overview. English and Japanese pages live under `exampleSite/content/en/` and `exampleSite/content/ja/`. Do not restore removed guide files or aliases unless a separate migration task explicitly requires them.

## Voice and editing standard

- Write from concrete use, observation, or design intent. Prefer “我第一次接入主题时……” over generic claims such as “本主题提供强大的功能”。
- Keep paragraphs focused and varied. Avoid repeated “首先 / 其次 / 最后”, inflated conclusions, and symmetrical boilerplate.
- Demonstrate a feature in context instead of explaining every Markdown token abstractly.
- Do not fabricate FAQ answers, benchmarks, user feedback, browser support, or future features.
- Keep the Blog itself central: typography, summary, spacing, and navigation matter more than feature count.

## Front Matter contract

Articles and `archetypes/default.md` use YAML `---` Front Matter. A normal Demo article includes:

```yaml
---
title: "文章标题"
date: 2026-08-15T09:00:00+08:00
layout: post
description: "用于 SEO 和分享的一句话说明。"
summary: "首页目录使用的两句完整导读。"
categories:
  - 写作
tags:
  - Inyo
math: false
---
```

A series overview uses a branch bundle `_index.md`:

```yaml
---
title: "系列标题"
layout: series
pinned: false
cascade:
  layout: post
---
```

A direct child article records its own publication, update, and reading order:

```yaml
---
title: "系列子文章"
layout: post
date: 2026-08-15T09:00:00+08:00
lastmod: 2026-08-18T09:00:00+08:00
weight: 10
---
```

- `description` is concise page metadata; `summary` is the catalog introduction. Do not lengthen SEO copy merely to fill the homepage.
- Use `layout: post` for ordinary articles. It is explicit in the archetype even though the shared single fallback preserves articles that omit it.
- Use `layout: series` only on the series `_index.md`; its direct child articles inherit `layout: post` through `cascade`, while an explicit `layout: post` remains valid and makes a standalone child example unambiguous.
- In a series, nonzero `weight` values sort ascending before zero or missing weights, which sort by `date` ascending.
- Use `lastmod` for a real article update; otherwise the theme falls back to `date` when calculating the series update.
- Use `pinned: true` on an ordinary article or the series `_index.md` only for intentional homepage promotion. Child article pinning does not promote the folded series entry.
- Use `math: true` only on pages containing formulas.
- Use arrays for `categories` and `tags`; do not switch content back to TOML `+++` Front Matter.

## Markdown examples

- Use triple backticks, never `~~~`.
- Label generic command blocks as `shell`:

```shell
hugo server --source exampleSite
```

- Label configuration blocks with their actual format (`yaml`, `toml`, `markdown`).
- Every image needs descriptive alt text. Preserve the Markdown image example that verifies `static/img/seal-yang.svg` and project subpaths.
- External links should be meaningful and use trusted sources; unsafe-link examples belong only in the dedicated Markdown security demonstration.
- Internal links must target existing Demo pages and pass the GitHub Pages subpath build.
- Keep raw HTML limited to features the Demo intentionally enables through Goldmark, such as `<kbd>`.
- KaTeX examples must render under the existing delimiters; do not imply that non-math pages load KaTeX.

## Workflow

1. Read the target article, its neighboring links, `about.md`, and the relevant brand section in `DESIGN.md`.
2. Preserve the article's assigned job; move unrelated material instead of letting one guide become a catch-all.
3. Update Front Matter, prose, examples, and next-step links together.
4. If the six-root-article plus series-tree structure changes, synchronize About, both READMEs, `.pi/README.md`, this skill, and smoke assertions.
5. Render the Demo and inspect the actual output, not only the Markdown source.

## Verification

Run from the repository root:

```shell
hugo --source exampleSite --minify --printPathWarnings
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
pwsh -File scripts/verify-hugo-basic-example.ps1
git diff --check
```

For prose or layout changes, also preview `hugo server --source exampleSite` and read the affected pages in light/dark modes and at `390×844`. Confirm code blocks scroll internally, links resolve, images retain alt text, math loads only on `katex.md`, and summaries stay within the catalog rhythm.
