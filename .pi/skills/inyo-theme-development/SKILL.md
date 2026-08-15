---
name: inyo-theme-development
description: Use when modifying Inyo Hugo templates, runtime parameters, CSS tokens, navigation, summaries, SEO, accessibility, fonts, or the homepage poetry interaction. Do not use for content-only edits or release-only work.
metadata:
  category: software-development
---

# Inyo Theme Development

## Purpose

Implement runtime changes without breaking Inyo's paper-and-ink design, configurable Hugo paths, homepage-only poetry boundary, or consumer portability. This skill is a workflow; `AGENTS.md`, `DESIGN.md`, source files, and `scripts/verify-*.ps1` remain authoritative.

## Route the task

- Use this skill for `layouts/`, `assets/css/`, `config/_default/`, `data/inyo/`, `i18n/`, or runtime smoke checks.
- Use `inyo-content-authoring` for Demo articles, About, Markdown examples, or YAML Front Matter.
- Use `inyo-theme-release` for README/CHANGELOG, distribution metadata, CI, Pages, tags, or releases.
- Combine with a color skill only when changing color roles or contrast.

## Read before editing

1. Read the relevant sections of `AGENTS.md` and `DESIGN.md`.
2. Inspect the current template consumer, default parameter, Demo override, fixture, and existing assertion.
3. Run `git status --short` and preserve unrelated worktree changes.
4. State the observable contract, then add a failing assertion before changing runtime behavior.

## Configuration contract

- `hugo.toml` declares theme compatibility; it is not a consumer site config.
- `config/_default/params.toml` and `markup.toml` provide mergeable defaults.
- `exampleSite/hugo.yaml` is the canonical Demo override and contains only Hugo basics, parameters Inyo actually reads, Demo Markdown settings, and taxonomy.
- `scripts/fixtures/consumer-site/hugo.yaml` proves custom `notes`, `labels`, and subpath behavior.
- Public parameters require four aligned pieces: a default when appropriate, a real template consumer, a Demo or fixture example only when useful, and a smoke assertion.
- Consumer markup overrides retain `_merge: "deep"` so class-based Chroma defaults survive.

Do not reintroduce removed `heroImage` parameters or add generic Hugo options that the theme does not consume.

## Runtime invariants

### Navigation and content collections

- The navigation roles are Home, Blog, Tags, Archives, and About; their paths remain configurable.
- Resolve Blog from `site.Params.mainSections[0]` and Tags/Archives/About from `site.Params.navigation`.
- Resolve article terms with the taxonomy plural key in `site.Params.taxonomy.tag`, then use Hugo term pages and `.RelPermalink`; `site.Params.navigation.tags` is only the index navigation path.
- Resolve the 404 article entry from `mainSections[0]`. Root-relative authored content links and ordinary internal social links use `relLangURL` so project and language prefixes survive.
- Pinned posts (`pinned: true`) appear before normal posts; each collection is date-descending.
- Archives use `GroupByDate` and remain a low-noise title/date list.

### Summary and SEO

- Catalog source: Hugo `.Summary` → `.Description`; then apply the existing 140-unit truncation and three-line clamp.
- SEO source: page `.Description` → `summary-source.html` → site description → subtitle → title.
- Do not duplicate either fallback chain in a second template.
- Default social output uses `static/img/seal-yang-og.png`; favicon remains the fixed-color `static/img/seal-yang.svg` exception.

### CSS, motion, and accessibility

- Runtime colors come from `assets/css/main.css` tokens; record new roles and measured contrast in `DESIGN.md`.
- Links on `--paper-2` use `--link-raised`, Chroma keywords use `--syntax-keyword`, and prose links retain a solid non-color underline cue.
- Support both paper and ink modes. Keep body, navigation, and footer horizontal.
- Footer is a single semantic `<footer>` (`shell-footer`) in document flow after `main`; a full-width page footer with a `--border` top rule on every viewport — never `position: fixed` over the identity rail.
- Gate hover effects with `@media (hover: hover)` and provide `prefers-reduced-motion` behavior.
- Preserve skip link, focus ring, landmarks, image alt text, safe external links, and theme-button ARIA.
- Self-hosted font URLs remain relative to generated CSS through `../fonts/`; `/blog/` is a required fixture scenario.

### Poetry Hero

- Only the homepage may contain local poem JSON, API details, or the interaction script.
- Initial content is local; remote requests happen only after activation and must fail back silently.
- Keep the current native button, busy protection, timeout, API adapter, and live-region behavior.
- Immediate feedback is the **朱红双翼墨线** tracing the rounded Hero border from the bottom center to the **顶部中央**. It runs once and is disabled under reduced motion.

## Verification

Run from the repository root:

```shell
hugo --source exampleSite --minify --printPathWarnings
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
pwsh -File scripts/verify-hugo-basic-example.ps1
git diff --check
```

For visual or interaction changes, also run:

```shell
hugo server --source exampleSite
```

Check light/dark modes, desktop and `390×844`, keyboard activation, reduced motion, `scrollWidth === clientWidth`, Hero absence outside the homepage, and API failure fallback. Stop the server after review.

## Known failure modes

- Minified HTML may omit attribute quotes; generated-output assertions must accept both forms.
- Theme application belongs before styles in `head.html`; moving it to the body causes dark-mode FOUC.
- Root-relative `/posts/`, `/tags/`, `/fonts/`, or `/img/` URLs break custom sections or project-site deployments unless a render hook deliberately rewrites them.
- API responses are accepted only through the existing normalization adapter; missing or duplicate content falls back locally.
- Generated `public/`, `resources/`, `.hugo_build.lock`, and temporary fixture output must not remain in the worktree.

## Baseline

Hugo Extended `0.164.0` and Go `1.26.1` must match `hugo.toml`, `theme.toml`, `go.mod`, and CI. Do not update only one declaration.
