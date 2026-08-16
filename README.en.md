# Inyo 陰陽

[![Verify theme](https://github.com/FeiNiaoBF/hugo-theme-inyo/actions/workflows/verify-theme.yml/badge.svg)](https://github.com/FeiNiaoBF/hugo-theme-inyo/actions/workflows/verify-theme.yml)
[![License](https://img.shields.io/github/license/FeiNiaoBF/hugo-theme-inyo)](LICENSE)
[![Live Demo](https://img.shields.io/badge/demo-GitHub%20Pages-8f2f2f)](https://FeiNiaoBF.github.io/hugo-theme-inyo/)

> A Chinese-first Hugo theme for long-form reading, with paper-and-ink themes, a poetry hero, multilingual UI, page-level math, and portable navigation.

<h3 align="center">
  <a href="README.md">中文</a>
</h3>

[![Inyo light theme](https://raw.githubusercontent.com/FeiNiaoBF/hugo-theme-inyo/main/images/screenshot.png)](https://FeiNiaoBF.github.io/hugo-theme-inyo/)

## Status

Inyo is an early usable theme for personal blogs, notes, and editorial sites. Installation examples follow the latest release through `@latest`. Use a Git tag when you need to reproduce a historical version.

| Requirement | Version |
| --- | --- |
| Hugo | Extended `>= 0.164.0` |
| Go | `>= 1.26.1` for Hugo Modules |
| Runtime | Native CSS and JavaScript; no frontend framework |

Live demo: [FeiNiaoBF.github.io/hugo-theme-inyo](https://FeiNiaoBF.github.io/hugo-theme-inyo/)

## Features

- Paper-and-ink light and dark themes driven by CSS tokens
- Homepage poetry hero with a restrained red double-wing border animation
- Long-form reading layout with summaries, code blocks, and Markdown rendering
- A focused blog structure: Home, Blog, Tags, Archives, and About; articles remain detail pages, with About aligned to the primary navigation
- Multiple pinned posts via `pinned: true`, shown before the latest-post stream
- Portable navigation for custom content sections, taxonomy, archive, and About paths
- SEO metadata, Open Graph, Twitter Cards, JSON-LD, and description fallbacks
- Built-in Chinese, English, and Japanese translation keys
- Page-level KaTeX controlled by the `math` parameter
- Skip links, focus styles, ARIA states, and reduced-motion support
- Self-hosted LXGW WenKai font files with subpath-safe URLs

## Quick Start

### Requirements

Install Hugo Extended `0.164.0` or newer. Go is only required for the Hugo Modules workflow.

```shell
hugo version
go version
```

### Create a site and install Inyo

```shell
hugo new site my-inyo-site --format yaml
cd my-inyo-site

hugo mod init example.com/my-inyo-site
hugo mod get github.com/FeiNiaoBF/hugo-theme-inyo@latest
hugo mod tidy
```

Create or edit `hugo.yaml`:

```yaml
baseURL: "https://example.com/"
title: "My Inyo Blog"
defaultContentLanguage: "en"

module:
  imports:
    - path: "github.com/FeiNiaoBF/hugo-theme-inyo"

params:
  description: "My personal blog."
  author: "Your Name"
  subtitle: "Paper and ink."
```

Start the local server:

```shell
hugo server --buildDrafts
```

### Update Inyo

Run these commands from the site root to fetch the latest release, tidy Hugo Modules, and verify the build:

```shell
hugo mod get github.com/FeiNiaoBF/hugo-theme-inyo@latest
hugo mod tidy
hugo --minify
```

`@latest` resolves to a concrete version and writes it to the site's `go.mod`; do not write `@latest` directly in `go.mod`. If a Go proxy has not synchronized the newest release yet, retry with `GOPROXY=direct`; in PowerShell, set `$env:GOPROXY = "direct"` first. For Hugo sites, use `hugo mod tidy` instead of running `go mod tidy` alone, because the theme may be referenced only through the Hugo Module configuration in `hugo.yaml`.

### Classic `themes/` installation

If you do not use Hugo Modules, clone the theme into your site's `themes/` directory:

```shell
git clone https://github.com/FeiNiaoBF/hugo-theme-inyo.git themes/inyo
```

Then configure:

```yaml
theme:
  - "inyo"
```

Choose one installation method. Do not configure both `module.imports` and `theme`.

## Demo

The repository includes an `exampleSite` that is published to GitHub Pages:

```text
https://FeiNiaoBF.github.io/hugo-theme-inyo/
```

To run it locally:

```shell
git clone https://github.com/FeiNiaoBF/hugo-theme-inyo.git
cd hugo-theme-inyo
hugo server --source exampleSite
```

If you fork the repository, open `Settings → Pages`, select `GitHub Actions` as the source, then push to `main` or run the demo workflow manually.

## Configuration

Runtime defaults live in [`config/_default/params.toml`](config/_default/params.toml) and [`config/_default/markup.toml`](config/_default/markup.toml). Configure site identity and only override the options you need:

```yaml
params:
  description: "My long-form blog."
  font: "wenkai"
  math: false
  mainSections:
    - "posts"
  author: "Your Name"

  taxonomy:
    tag: "tags"

  navigation:
    tags: "tags"
    archives: "archives"
    about: "about"

  heroPoetry:
    api:
      enabled: false

markup:
  _merge: "deep"
```

`params.taxonomy.tag` is the taxonomy plural key used in article front matter, while `params.navigation.tags` is only the taxonomy index path. To rename the tag taxonomy to `labels`, align Hugo's `taxonomies.tag: "labels"`, `params.taxonomy.tag: "labels"`, and the navigation path. Keep `markup._merge: "deep"` whenever the site overrides `markup`, or the theme's class-based Chroma defaults will be replaced.

```yaml
taxonomies:
  tag: "labels"

params:
  taxonomy:
    tag: "labels"
  navigation:
    tags: "labels"
```

[`exampleSite/hugo.yaml`](exampleSite/hugo.yaml) is the complete demo configuration, not a file users must copy verbatim. Runtime defaults remain in `config/_default/`; a consumer site only needs to override its identity and the options it changes. Demo articles use YAML Front Matter. The final parameter contract is defined by the defaults and their template consumers; design constraints live in `DESIGN.md`.

## Documentation

- [Using Inyo](exampleSite/content/zh-cn/posts/theme-usage.md)
- [Markdown basics](exampleSite/content/zh-cn/posts/markdown-basics.md)
- [Efficient Markdown writing](exampleSite/content/zh-cn/posts/markdown-efficient.md)
- [KaTeX mathematics](exampleSite/content/zh-cn/posts/katex.md)
- [FAQ](exampleSite/content/zh-cn/posts/faq.md)
- [Brand design core](exampleSite/content/zh-cn/posts/brand-design.md)
- [Design document](DESIGN.md)
- [Changelog](CHANGELOG.md)

The detailed guides are currently Chinese-first. Contributions to English documentation are welcome.

## Development

Run the following checks from the repository root:

```shell
hugo --source exampleSite --minify --printPathWarnings
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
pwsh -File scripts/verify-hugo-basic-example.ps1
git diff --check
```

Do not commit `exampleSite/public/`, `resources/`, or `.hugo_build.lock`. See [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

`verify-hugo-basic-example.ps1` runs a compatibility build with the official empty HugoBasicExample site and the current workspace theme.

## FAQ

### Is the remote poetry API required?

No. The theme uses local poems from `data/inyo/hero_poems.toml` by default. The demo enables the remote API to show the integration, but failed requests fall back to local data.

### Can I deploy Inyo under a subpath?

Yes. Navigation, fonts, and static resources are designed for subpath deployments and are verified with a `/blog/` consumer fixture.

### Can I disable the self-hosted fonts?

Yes:

```yaml
params:
  webfonts: false
```

The font loading strategy is documented as a future improvement while the current reading experience is evaluated.

## Roadmap

- **Font loading performance**: LXGW WenKai is currently delivered as self-hosted Unicode-range subsets, so browsers request the subsets needed by the page. The current priority is collecting real-device and network feedback before considering fewer subsets, a different loading strategy, or a lighter default font.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening an issue or pull request.

## Acknowledgements

Inyo's design and implementation were informed by these open-source projects and tools:

- [zhongguo-traditional-colors](https://github.com/nevertoday/zhongguo-traditional-colors): reference for Chinese traditional colors and palette research
- [pianpker](https://pianpker.pages.dev/) and [astro-theme-pianpker](https://github.com/DRAG0NM/astro-theme-pianpker): reference for editorial reading and visual expression
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai): the default self-hosted font
- [Hugo](https://github.com/gohugoio/hugo): the static site generator and theme ecosystem

Inyo's templates, styles, interactions, and integrations are maintained by this project. Copyright and licenses for the referenced projects belong to their respective authors.

## License

MIT. See [LICENSE](LICENSE).

## 中文文档

中文主文档见 [README.md](README.md)。
