---
name: inyo-theme-release
description: Use when maintaining Inyo's README or CHANGELOG, distribution metadata, compatibility fixtures, GitHub Actions, GitHub Pages demo, or release readiness. Also use for project-wide documentation synchronization after public behavior changes.
---

# Inyo Theme Release

## Purpose

Keep the public project entry points and release machinery aligned with the theme that actually builds. This skill coordinates existing facts and gates; it does not redefine runtime or visual behavior from `AGENTS.md`, `DESIGN.md`, or source.

## Source map

- Compatibility: `hugo.toml`, `theme.toml`, `go.mod`, `.github/workflows/verify-theme.yml`.
- Theme defaults: `config/_default/params.toml`, `config/_default/markup.toml`.
- Canonical Demo: `exampleSite/hugo.yaml`; local module replacement remains in `exampleSite/go.mod`.
- Consumer portability: `scripts/fixtures/consumer-site/hugo.yaml` and its fixed `go.mod` replacement `=> ../../..`.
- Distribution assets: `theme.toml`, `images/screenshot.png`, `images/tn.png`, `static/img/seal-yang-og.png`.
- Pages: `.github/workflows/deploy-demo.yml` and `exampleSite/public` as an untracked build artifact.
- Public docs: `README.md`, `README.en.md`, `CONTRIBUTING.md`, `CHANGELOG.md`.

## Preflight

1. Run `git status --short --untracked-files=all` and preserve unrelated changes.
2. Read the current implementation and verifier before editing claims.
3. Use Git history for superseded implementation records; current API documentation lives in the maintained project documents.
4. Do not commit generated `public/`, `resources/`, lock files, or temporary fixture output.

## Documentation synchronization

- README is the user entry point: what Inyo is, supported versions, copyable installation, minimal YAML, Demo, feature overview, docs links, validation, roadmap, contribution, acknowledgements, and license.
- `README.md` and `README.en.md` must match semantically. Keep the centered language switch near the top of each file.
- Installation defaults to `github.com/FeiNiaoBF/hugo-theme-inyo@latest`. Document Modules and classic `themes/` as alternatives, never as simultaneous requirements.
- Link detailed configuration to `exampleSite/hugo.yaml` and defaults in `config/_default/`; do not create a duplicate full parameter table.
- The Demo documentation index contains exactly `theme-usage.md`, `markdown-basics.md`, `markdown-efficient.md`, `katex.md`, `faq.md`, and `brand-design.md`.
- CONTRIBUTING explains contributor setup, synchronization responsibilities, validation, and artifact hygiene.
- CHANGELOG follows Keep a Changelog, preserves released history, and records only implemented changes under `Unreleased`.
- User-facing Markdown uses triple-backtick fences; generic command blocks use `shell`.

When public behavior changes, use the synchronization matrix in `AGENTS.md` instead of copying every implementation detail into every document.

## Compatibility and Pages checks

- Hugo Extended remains `0.164.0` in theme metadata and CI; Go remains `1.26.1` in `go.mod` and CI.
- `scripts/verify-consumer.ps1` must continue proving custom `notes`, `labels`, real term links, class-based Chroma, 404 routing, archetype output, and `/blog/` paths without downloading the theme.
- `scripts/verify-hugo-basic-example.ps1` must continue building the official HugoBasicExample against the current workspace theme.
- Pages deploys only from `main` or manual dispatch, uses `actions/configure-pages`, `upload-pages-artifact`, and `deploy-pages`, and builds with `steps.pages.outputs.base_url`.
- Project-site output must keep the repository subpath for canonical URLs, CSS, fonts, images, RSS, navigation, and article links; multilingual authored links must also keep the active language segment.

## Full release gate

Run from the repository root:

```shell
hugo --source exampleSite --minify --printPathWarnings
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
pwsh -File scripts/verify-hugo-basic-example.ps1
git diff --check
```

After verification, confirm `git status --short` contains only intended source and documentation changes.

## Versioned release

Only when the user explicitly requests a release:

1. Prepare the verified release notes and public documentation.
2. Hand off commit grouping, release commits, annotated tags, and any approved push to `inyo-git-release`.
3. Create release notes from the corresponding CHANGELOG entry only when the user requests a GitHub Release.

Never infer the next version, tag, push, pull request, or GitHub Release from a documentation-only request. `inyo-git-release` owns the Git mutation boundary.

## Failure routing

- Runtime or template failure → use `inyo-theme-development`.
- Demo article or Front Matter failure → use `inyo-content-authoring`.
- Consumer failure → inspect `mainSections`, `params.navigation`, `params.taxonomy.tag`, Hugo taxonomies, markup deep merge, relative replacement, and generated URL paths.
- Pages failure → inspect `RelPermalink`, render hooks, base URL handling, and root-relative assets.
- Documentation contract failure → correct the stale claim or link; do not weaken the assertion to preserve inaccurate text.
