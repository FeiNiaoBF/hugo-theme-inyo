# Inyo 陰陽

[![Verify theme](https://github.com/FeiNiaoBF/hugo-theme-inyo/actions/workflows/verify-theme.yml/badge.svg)](https://github.com/FeiNiaoBF/hugo-theme-inyo/actions/workflows/verify-theme.yml)
[![License](https://img.shields.io/github/license/FeiNiaoBF/hugo-theme-inyo)](LICENSE)
[![Live Demo](https://img.shields.io/badge/demo-GitHub%20Pages-8f2f2f)](https://FeiNiaoBF.github.io/hugo-theme-inyo/)

> A Chinese-first Hugo theme for long-form reading, with paper-and-ink themes, a poetry hero, multilingual UI, page-level math, and portable navigation.

[![Inyo light theme](images/screenshot.png)](https://FeiNiaoBF.github.io/hugo-theme-inyo/)

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
- Portable navigation for custom content sections and taxonomy paths
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
hugo new site my-inyo-site
cd my-inyo-site

hugo mod init example.com/my-inyo-site
hugo mod get github.com/FeiNiaoBF/hugo-theme-inyo@latest
hugo mod tidy
```

Create or edit `hugo.toml`:

```toml
baseURL = "https://example.org/"
title = "My Inyo Blog"
defaultContentLanguage = "en"

[module]
[[module.imports]]
path = "github.com/FeiNiaoBF/hugo-theme-inyo"

[params]
description = "My personal blog."
author = "Your Name"
subtitle = "Paper and ink."
```

Start the local server:

```shell
hugo server --buildDrafts
```

### Classic `themes/` installation

If you do not use Hugo Modules, clone the theme into your site's `themes/` directory:

```shell
git clone https://github.com/FeiNiaoBF/hugo-theme-inyo.git themes/inyo
```

Then configure:

```toml
theme = "inyo"
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

Runtime defaults live in `config/_default/params.toml` and `config/_default/markup.toml`. Configure site identity and only override the options you need:

```toml
[params]
description = "My long-form blog."
font = "wenkai"
math = false
mainSections = ["posts"]
author = "Your Name"

[params.navigation]
tags = "tags"
about = "about"

[params.heroPoetry.api]
enabled = false
```

See the [configuration reference](exampleSite/content/posts/configuration-reference.md) and [Front Matter guide](exampleSite/content/posts/front-matter.md) for the complete documentation.

## Documentation

- [Getting started](exampleSite/content/posts/getting-started.md)
- [Configuration reference](exampleSite/content/posts/configuration-reference.md)
- [Front Matter guide](exampleSite/content/posts/front-matter.md)
- [Markdown feature gallery](exampleSite/content/posts/markdown-style-guide.md)
- [Customization](exampleSite/content/posts/customization.md)
- [Release checklist](exampleSite/content/posts/release-checklist.md)
- [Design document](DESIGN.md)
- [Changelog](CHANGELOG.md)

The detailed guides are currently Chinese-first. Contributions to English documentation are welcome.

## Development

Run the following checks from the repository root:

```shell
hugo --source exampleSite --minify --printPathWarnings
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
git diff --check
```

Do not commit `exampleSite/public/`, `resources/`, or `.hugo_build.lock`. See [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## FAQ

### Is the remote poetry API required?

No. The theme uses local poems from `data/inyo/hero_poems.toml` by default. The demo enables the remote API to show the integration, but failed requests fall back to local data.

### Can I deploy Inyo under a subpath?

Yes. Navigation, fonts, and static resources are designed for subpath deployments and are verified with a `/blog/` consumer fixture.

### Can I disable the self-hosted fonts?

Yes:

```toml
[params]
webfonts = false
```

The font loading strategy is documented as a future improvement while the current reading experience is evaluated.

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
