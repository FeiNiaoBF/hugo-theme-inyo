# Post and Series Layouts Implementation Plan

**Implementation status:** verified

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an explicit Hugo-native `post`/`series` content model where ordinary articles keep the current detail layout and each series becomes one catalog entry with its own overview and ordered article navigation.

**Architecture:** Treat `layout` as Hugo's template filename selector: `layout: post` targets `layouts/_default/post.html`, `layout: series` targets `layouts/_default/series.html`, and omitted layouts fall back through `layouts/_default/single.html` to the same post partial. Pure partials build ordered series context and a mixed catalog-entry slice; homepage and the configured main section consume that shared data without introducing a taxonomy or theme parameter.

**Tech Stack:** Hugo Extended 0.164.0, Go Templates, native CSS, YAML Front Matter, PowerShell smoke tests.

**Spec:** `docs/superpowers/specs/2026-08-22-post-series-content-model.md`

## Global Constraints

- Hugo Extended remains exactly `0.164.0`; Go remains exactly `1.26.1`.
- Use Go Templates, native CSS, and native JavaScript only; add no framework, preprocessor, or runtime package.
- `layout: post` is the explicit ordinary-page layout; omitted `layout` must render identically through `_default/single.html`.
- `layout: series` is valid only on a direct child section `_index.md` under a configured `params.mainSections` root.
- Do not add a `series` taxonomy, parse numbered titles, or add a public theme parameter.
- Preserve configurable section/taxonomy paths, multilingual `RelPermalink` behavior, `/blog/` subpaths, summary and SEO fallback chains, and homepage-only poetry resources.
- Use existing CSS color tokens in both paper and ink modes; gate hover feedback with `@media (hover: hover)` and preserve focus-visible behavior.
- Preserve unrelated worktree changes. Generated `public/`, `resources/`, `.hugo_build.lock`, and temporary fixture output must not remain.
- Do not commit, tag, push, create a PR, or publish a release unless the user separately authorizes that Git action.

---

## File Structure

### New runtime files

- `layouts/partials/series/pages.html`: returns direct series articles in the approved weight/date order.
- `layouts/partials/series/effective-date.html`: returns `.Lastmod` with an explicit `.Date` fallback for catalog freshness.
- `layouts/partials/series/context.html`: returns series pages, count, latest page, and effective update date.
- `layouts/partials/series/navigation.html`: returns current position plus previous/next pages from the same ordered collection.
- `layouts/partials/series/icon.html`: renders the decorative, token-colored inline SVG.
- `layouts/partials/catalog/entries.html`: returns the mixed, sorted post/series directory model.
- `layouts/partials/catalog/item.html`: renders one ordinary or series directory item.
- `layouts/partials/post/single.html`: owns the shared ordinary article markup and optional series context.
- `layouts/_default/post.html`: named template selected by `layout: post`.
- `layouts/_default/series.html`: named branch template selected by `layout: series`.
- `archetypes/series.md`: creates a series `_index.md` with child `post` cascade.

### Modified runtime files

- `layouts/index.html`: keeps the poetry Hero, then renders pinned/latest mixed catalog entries.
- `layouts/_default/list.html`: uses the mixed catalog only for the configured main section; other list kinds retain their current behavior.
- `layouts/_default/single.html`: becomes the no-layout compatibility wrapper around the post partial.
- `assets/css/main.css`: styles series marks, metadata, overview, progress, and responsive navigation.
- `i18n/zh-cn.toml`, `i18n/en.toml`, `i18n/ja.toml`: provide all visible series copy.
- `archetypes/default.md`: explicitly emits `layout: post`.

### Fixtures, Demo, and gates

- `scripts/fixtures/consumer-site/content/notes/series-smoke/`: proves ordering, pinning, deduplication, and `/blog/` paths with a custom main section.
- `scripts/fixtures/consumer-site/content/notes/solo-series/`: proves one published article is still a series.
- `exampleSite/content/zh-cn/posts/series-writing/`: provides the visual two-article Demo series.
- `scripts/verify-theme.ps1`: verifies template contracts, Demo output, i18n, accessibility, and project-site paths.
- `scripts/verify-consumer.ps1`: verifies custom-section behavior, series output, ordering, archetypes, and subpaths.

### Documentation synchronization

- `DESIGN.md`, `AGENTS.md`, `README.md`, `README.en.md`, `CHANGELOG.md`.
- `exampleSite/content/zh-cn/about.md`, `exampleSite/content/zh-cn/posts/theme-usage.md`.
- `.pi/README.md`, `.pi/skills/inyo-theme-development/SKILL.md`, `.pi/skills/inyo-content-authoring/SKILL.md`, `.pi/skills/inyo-theme-release/SKILL.md`.

---

### Task 1: Build the series and catalog data interfaces

**Files:**

- Create: `layouts/partials/series/pages.html`
- Create: `layouts/partials/series/effective-date.html`
- Create: `layouts/partials/series/context.html`
- Create: `layouts/partials/series/navigation.html`
- Create: `layouts/partials/catalog/entries.html`
- Modify: `scripts/verify-theme.ps1`

**Interfaces:**

- Consumes: a Hugo section `Page` whose `.Layout` is `series`; `site`; `params.mainSections`.
- Produces: `partial "series/pages.html" $section -> []Page`; `partial "series/effective-date.html" $page -> time.Time`; `partial "series/context.html" $section -> dict{page,pages,count,latest,updated}`; `partial "series/navigation.html" (dict "page" $page "context" $context) -> dict{position,previous,next}`; `partial "catalog/entries.html" (dict "site" site "sections" $mainSections) -> []dict{kind,page,latest,count,date,dateKey,pinned}`.

- [x] **Step 1: Add failing structural assertions**

Add these variables beside the existing template paths in `scripts/verify-theme.ps1`:

```powershell
$seriesPagesPartial = Join-Path $repoRoot "layouts\partials\series\pages.html"
$seriesEffectiveDatePartial = Join-Path $repoRoot "layouts\partials\series\effective-date.html"
$seriesContextPartial = Join-Path $repoRoot "layouts\partials\series\context.html"
$seriesNavigationPartial = Join-Path $repoRoot "layouts\partials\series\navigation.html"
$catalogEntriesPartial = Join-Path $repoRoot "layouts\partials\catalog\entries.html"
```

Add assertions before the generated Demo build:

```powershell
foreach ($path in @($seriesPagesPartial, $seriesEffectiveDatePartial, $seriesContextPartial, $seriesNavigationPartial, $catalogEntriesPartial)) {
  Assert-FileExists $path "Series failure: required data partial is missing: $path"
}
Assert-Contains $seriesPagesPartial '\.RegularPages' "Series failure: ordering must use direct regular pages."
Assert-Contains $seriesPagesPartial '\.ByWeight' "Series failure: weighted pages must use Hugo ByWeight."
Assert-Contains $seriesPagesPartial '\.ByDate' "Series failure: unweighted pages must use ascending publication date."
Assert-Contains $seriesEffectiveDatePartial '\.Lastmod' "Series failure: effective update must prefer Hugo Lastmod."
Assert-Contains $seriesEffectiveDatePartial '\.Date' "Series failure: effective update must fall back to Date."
Assert-Contains $catalogEntriesPartial '\.CurrentSection\.Layout' "Catalog failure: series children are not excluded through their current section."
Assert-Contains $catalogEntriesPartial 'site\.Params|\.sections|sections' "Catalog failure: collection does not consume configured main sections."
Assert-NotContains $catalogEntriesPartial '"posts"' "Catalog failure: collection hard-codes the posts section."
```

- [x] **Step 2: Run the gate and confirm the red state**

Run:

```shell
pwsh -File scripts/verify-theme.ps1
```

Expected: FAIL because `layouts/partials/series/pages.html` is missing.

- [x] **Step 3: Implement direct-child series ordering**

Create `layouts/partials/series/pages.html` with this contract:

```go-html-template
{{- $weighted := where .RegularPages "Weight" "ne" 0 -}}
{{- $dated := where .RegularPages "Weight" "eq" 0 -}}
{{- $ordered := $weighted.ByWeight -}}
{{- $ordered = $ordered | append $dated.ByDate -}}
{{- return $ordered -}}
```

`RegularPages` is intentional: the approved first version supports direct article children, while `RegularPagesRecursive` would silently add chapter sub-sections.

- [x] **Step 4: Implement reusable series context**

Create `layouts/partials/series/effective-date.html` first:

```go-html-template
{{- $updated := .Lastmod -}}
{{- if le $updated.Unix 0 -}}
  {{- $updated = .Date -}}
{{- end -}}
{{- return $updated -}}
```

Then create `layouts/partials/series/context.html`:

```go-html-template
{{- $pages := partial "series/pages.html" . -}}
{{- $latest := false -}}
{{- $updated := .Date -}}
{{- range $pages -}}
  {{- $candidateUpdated := partial "series/effective-date.html" . -}}
  {{- if or (not $latest) (gt $candidateUpdated.Unix $updated.Unix) -}}
    {{- $latest = . -}}
    {{- $updated = $candidateUpdated -}}
  {{- end -}}
{{- end -}}
{{- return dict
  "page" .
  "pages" $pages
  "count" (len $pages)
  "latest" $latest
  "updated" $updated
-}}
```

The helper honors Hugo's `.Lastmod` while still satisfying Inyo's explicit `.Date` fallback when a consumer config leaves Lastmod at its zero value. It is used only for catalog freshness; reading order remains weight-first, then publication-date ascending.

- [x] **Step 5: Implement previous/next lookup from the same order**

Create `layouts/partials/series/navigation.html`:

```go-html-template
{{- $page := .page -}}
{{- $context := .context -}}
{{- $position := 0 -}}
{{- $previous := false -}}
{{- $next := false -}}
{{- range $index, $candidate := $context.pages -}}
  {{- if $candidate.Eq $page -}}
    {{- $position = add $index 1 -}}
    {{- if gt $index 0 -}}
      {{- $previous = index $context.pages (sub $index 1) -}}
    {{- end -}}
    {{- if lt (add $index 1) $context.count -}}
      {{- $next = index $context.pages (add $index 1) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- return dict "position" $position "previous" $previous "next" $next -}}
```

- [x] **Step 6: Implement the mixed catalog collection**

Create `layouts/partials/catalog/entries.html`. It must:

1. Range `site.RegularPages` whose `.Section` belongs to `.sections`.
2. Exclude a page when `.CurrentSection.Layout == "series"`.
3. For each configured main section, resolve `site.GetPage (printf "/%s" $sectionName)` and inspect only its direct `.Sections` for `.Layout == "series"`.
4. Skip a series whose context count is zero.
5. Append the following dictionaries, then `sort $entries "dateKey" "desc"`.

```go-html-template
{{- $source := . -}}
{{- $entries := slice -}}
{{- $regularPages := where $source.site.RegularPages "Section" "in" $source.sections -}}
{{- range $regularPages -}}
  {{- if ne .CurrentSection.Layout "series" -}}
    {{- $entries = $entries | append (dict
      "kind" "post"
      "page" .
      "latest" false
      "count" 0
      "date" .Date
      "dateKey" .Date.Unix
      "pinned" (eq .Params.pinned true)
    ) -}}
  {{- end -}}
{{- end -}}

{{- range $sectionName := $source.sections -}}
  {{- with $source.site.GetPage (printf "/%s" $sectionName) -}}
    {{- range .Sections -}}
      {{- if eq .Layout "series" -}}
        {{- $context := partial "series/context.html" . -}}
        {{- if gt $context.count 0 -}}
          {{- $entries = $entries | append (dict
            "kind" "series"
            "page" .
            "latest" $context.latest
            "count" $context.count
            "date" $context.updated
            "dateKey" $context.updated.Unix
            "pinned" (eq .Params.pinned true)
          ) -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- return (sort $entries "dateKey" "desc") -}}
```

- [x] **Step 7: Run the structural gate**

Run:

```shell
pwsh -File scripts/verify-theme.ps1
```

Expected: PASS with the helpers present but not yet used by rendered pages.

- [x] **Step 8: Review the task diff**

Run:

```shell
git diff --check
git diff -- layouts/partials scripts/verify-theme.ps1
```

Expected: no whitespace errors; only the five data partials and their assertions are present. If the user separately authorizes commits, use `feat: add series content collections`.

---

### Task 2: Render one series entry on Home and Blog

**Files:**

- Create: `layouts/partials/series/icon.html`
- Create: `layouts/partials/catalog/item.html`
- Modify: `layouts/index.html`
- Modify: `layouts/_default/list.html`
- Modify: `i18n/zh-cn.toml`
- Modify: `i18n/en.toml`
- Modify: `i18n/ja.toml`
- Create: `scripts/fixtures/consumer-site/content/notes/series-smoke/_index.md`
- Create: `scripts/fixtures/consumer-site/content/notes/series-smoke/weighted-first.md`
- Create: `scripts/fixtures/consumer-site/content/notes/series-smoke/weighted-second.md`
- Create: `scripts/fixtures/consumer-site/content/notes/series-smoke/unweighted-new.md`
- Create: `scripts/fixtures/consumer-site/content/notes/series-smoke/unweighted-old.md`
- Create: `scripts/fixtures/consumer-site/content/notes/solo-series/_index.md`
- Create: `scripts/fixtures/consumer-site/content/notes/solo-series/only.md`
- Modify: `scripts/verify-theme.ps1`
- Modify: `scripts/verify-consumer.ps1`

**Interfaces:**

- Consumes: catalog dictionaries from Task 1 and existing `summary.html`.
- Produces: one linked `<li>` per ordinary article or series; Home receives grouped entries and Blog receives a flat list.

- [x] **Step 1: Add deterministic consumer fixture content**

Use this branch front matter for `series-smoke/_index.md`:

```yaml
---
layout: series
title: "Portable Systems Notes"
description: "A section-backed series in a custom main section."
summary: "A portable series used to verify catalog folding, ordering, pinning, and subpath-safe links."
pinned: true
draft: false
cascade:
  layout: post
---
```

Create four children with these exact ordering fields:

| File | Title | Date | Lastmod | Weight |
| --- | --- | --- | --- | --- |
| `weighted-first.md` | Weighted First | `2026-08-10T00:00:00+08:00` | `2026-08-18T00:00:00+08:00` | `10` |
| `weighted-second.md` | Weighted Second | `2026-08-11T00:00:00+08:00` | `2026-08-14T00:00:00+08:00` | `20` |
| `unweighted-new.md` | Unweighted New | `2026-08-16T00:00:00+08:00` | omit | omit |
| `unweighted-old.md` | Unweighted Old | `2026-08-12T00:00:00+08:00` | omit | omit |

Each file must include `layout: post`, `description`, `summary`, `draft: false`, and `labels: [portability]`, followed by one plain-text paragraph naming the fixture. The effective latest page is `Weighted First`, proving that explicit `lastmod` wins over newer publication dates. `Solo Series` proves the explicit `date` fallback when `lastmod` is absent.

Use this one-article fixture for `solo-series/_index.md`:

```yaml
---
layout: series
title: "Solo Series"
description: "A one-article series remains explicitly a series."
summary: "This branch proves that series identity comes from layout, not article count."
draft: false
cascade:
  layout: post
---
```

`solo-series/only.md` uses `layout: post`, title `Only Entry`, date `2026-08-09T00:00:00+08:00`, `weight: 10`, `draft: false`, and `labels: [portability]`.

- [x] **Step 2: Add failing catalog assertions**

Add this helper to `scripts/verify-consumer.ps1`:

```powershell
function Assert-MatchCount($Path, $Pattern, $Expected, $Message) {
  $text = Get-Content -Raw $Path
  $actual = [regex]::Matches($text, $Pattern).Count
  if ($actual -ne $Expected) { throw "$Message Expected $Expected, got $actual." }
}
```

Add all new fixture files to `$fixtureContent`, then assert after the build:

```powershell
Assert-MatchCount $homePage 'href=("|'''')?/notes/series-smoke/' 1 "Series failure: homepage must contain one series entry."
Assert-MatchCount $notes 'href=("|'''')?/notes/series-smoke/' 1 "Series failure: notes list must contain one series entry."
Assert-Contains $homePage 'Portable Systems Notes.*Weighted First' "Series failure: homepage title must include the last-modified article title."
Assert-Contains $homePage 'Series.*4 articles|4 articles.*updated' "Series failure: homepage series metadata is missing."
Assert-NotContains $homePage 'href=("|'''')?/notes/series-smoke/(?:weighted|unweighted)-' "Series failure: child articles leaked into the homepage catalog."
Assert-NotContains $notes 'href=("|'''')?/notes/series-smoke/(?:weighted|unweighted)-' "Series failure: child articles leaked into the main-section catalog."
Assert-Contains $homePage '(?s)>Pinned<.*?Portable Systems Notes' "Series failure: pinned series is not in the pinned group."
Assert-Contains $homePage 'Solo Series.*Only Entry' "Series failure: a one-article series is not cataloged as a series."
```

Add equivalent `/blog/notes/series-smoke/` assertions for `$subpathHome`.

Append these keys to `$requiredI18nKeys` in `verify-theme.ps1`:

```powershell
"series", "series_count", "series_updated", "series_progress", "series_catalog_title", "back_to_series", "back_to_posts"
```

- [x] **Step 3: Run the consumer gate and confirm the red state**

Run:

```shell
pwsh -File scripts/verify-consumer.ps1
```

Expected: FAIL because the existing homepage emits each regular child and does not emit the series section.

- [x] **Step 4: Add the complete localized series vocabulary**

Use these meanings:

| Key | zh-cn | en | ja |
| --- | --- | --- | --- |
| `series` | 系列 | Series | シリーズ |
| `series_count` | `{{ .Count }} 篇` | singular/plural article(s) | `{{ .Count }}本` |
| `series_updated` | `最近更新 {{ .Date }}` | `Updated {{ .Date }}` | `最終更新 {{ .Date }}` |
| `series_progress` | `第 {{ .Current }} / {{ .Total }} 篇` | `{{ .Current }} of {{ .Total }}` | `{{ .Current }} / {{ .Total }}本` |
| `series_catalog_title` | `{{ .Series }}：{{ .Latest }}` | `{{ .Series }} — {{ .Latest }}` | `{{ .Series }}：{{ .Latest }}` |
| `back_to_series` | 返回系列 | Back to series | シリーズへ戻る |
| `back_to_posts` | 返回博客 | Back to blog | ブログへ戻る |

Define English `series_count` with TOML `one` and `other`; keep every key present in all three locales before rendering the catalog.

- [x] **Step 5: Create the decorative series icon**

Create `layouts/partials/series/icon.html` as an inline stroke icon. Keep it at a 16×16 view box, use `fill="none"`, `stroke="currentColor"`, `aria-hidden="true"`, and `focusable="false"`. Use two offset page outlines so the mark reads as a small bound sequence rather than a folder or play button.

```go-html-template
<svg class="series-icon" viewBox="0 0 16 16" fill="none" aria-hidden="true" focusable="false">
  <path d="M4.5 2.5h7v9h-7z" />
  <path d="M2.5 4.5v9h7" />
</svg>
```

- [x] **Step 6: Create the shared catalog item**

`layouts/partials/catalog/item.html` receives `dict "entry" $entry "level" 2|3 "showDate" true|false`. Render:

- `catalog-item--series` only for series.
- One title anchor whose contents include the SVG plus localized combined title for series.
- `Series · N articles · Updated DATE` metadata for series.
- Existing date/reading-time metadata for post entries.
- `partial "summary.html" $entry.page` for both kinds, so a series uses its `_index.md` summary/description.

Use separate `h2` and `h3` branches instead of generating heading tags through `safeHTML`, so titles remain escaped by Hugo.

- [x] **Step 7: Refactor Home to the mixed collection**

Keep the entire Hero block unchanged. Replace only the post collection below it:

```go-html-template
{{- $mainSections := site.Params.mainSections | default (slice "posts") -}}
{{- $entries := partial "catalog/entries.html" (dict "site" site "sections" $mainSections) -}}
{{- $pinned := where $entries "pinned" true -}}
{{- $latest := where $entries "pinned" "ne" true -}}
```

Render pinned entries with `catalog/item.html`, level 3, and `showDate: true`. Render latest entries in the existing date-group visual rhythm by comparing each sorted entry's `$entry.date.Format "2006-01-02"`; open a new group when the date key changes, use that date as the heading, and call the item partial with level 3 and `showDate: false`.

- [x] **Step 8: Refactor only the main-section branch of `_default/list.html`**

When `.IsSection` and `.Section == index $mainSections 0`, resolve the same `catalog/entries.html` collection and render level-2 items with dates. For all other list pages, retain the existing `.Pages` loop so custom sections outside `mainSections`, taxonomy behavior, and generic Hugo compatibility do not change.

- [x] **Step 9: Run consumer and theme gates**

Run:

```shell
pwsh -File scripts/verify-consumer.ps1
pwsh -File scripts/verify-theme.ps1
```

Expected: PASS; the pinned series appears once, the one-article series appears once, and no series child permalink appears on Home or the main Blog list.

- [x] **Step 10: Review the task diff**

Run `git diff --check` and inspect only the files listed in this task. If commits are separately authorized, use `feat: add series entries to blog catalogs`.

---

### Task 3: Add the series overview page

**Files:**

- Create: `layouts/_default/series.html`
- Modify: `scripts/verify-consumer.ps1`
- Modify: `scripts/verify-theme.ps1`

**Interfaces:**

- Consumes: `series/context.html`, `catalog/item.html`, and the branch page's `.Content`.
- Produces: a semantic series landing page selected directly by `layout: series`.

- [x] **Step 1: Add failing generated-output assertions**

Resolve these outputs in `verify-consumer.ps1`:

```powershell
$seriesOverview = Join-Path $out "notes\series-smoke\index.html"
$soloOverview = Join-Path $out "notes\solo-series\index.html"
```

Add an order helper:

```powershell
function Assert-InOrder($Path, $Patterns, $Message) {
  $text = Get-Content -Raw $Path
  $cursor = -1
  foreach ($pattern in $Patterns) {
    $match = [regex]::Match($text, $pattern)
    if (-not $match.Success -or $match.Index -le $cursor) { throw $Message }
    $cursor = $match.Index
  }
}
```

Assert:

```powershell
Assert-Contains $seriesOverview 'class=("|'''')?series-overview' "Series overview failure: semantic wrapper is missing."
Assert-Contains $seriesOverview 'Portable Systems Notes' "Series overview failure: title is missing."
Assert-Contains $seriesOverview '4 articles' "Series overview failure: article count is missing."
Assert-Contains $seriesOverview '2026-08-18' "Series overview failure: lastmod did not determine latest update."
Assert-InOrder $seriesOverview @('Weighted First', 'Weighted Second', 'Unweighted Old', 'Unweighted New') "Series overview failure: weight/date order is incorrect."
Assert-Contains $soloOverview '1 article' "Series overview failure: singular count is incorrect."
Assert-Contains $seriesOverview 'href=("|'''')?/notes/' "Series overview failure: back link does not use the section permalink."
```

- [x] **Step 2: Run the consumer gate and confirm the red state**

Run `pwsh -File scripts/verify-consumer.ps1`.

Expected: FAIL because the default list template lacks the `series-overview` structure and stats.

- [x] **Step 3: Implement `_default/series.html`**

Use `{{ define "main" }}` and build `$context := partial "series/context.html" .`. The semantic order is:

```go-html-template
<section class="series-overview">
  <header class="series-header">
    <a class="back-link" href="{{ .Parent.RelPermalink }}">← {{ i18n "back_to_posts" | default (i18n "back") }}</a>
    <p class="series-kicker">{{ partial "series/icon.html" . }}<span>{{ i18n "series" }}</span></p>
    <h1>{{ .Title }}</h1>
    <p class="series-stats">
      <span>{{ i18n "series_count" $context.count }}</span>
      <time datetime="{{ $context.updated.Format "2006-01-02" }}">{{ i18n "series_updated" (dict "Date" ($context.updated.Format (i18n "date_format" | default "2006-01-02"))) }}</time>
    </p>
  </header>
  {{ with .Content }}<div class="prose series-introduction">{{ . }}</div>{{ end }}
  <ol class="series-list">
    {{ range $index, $page := $context.pages }}
      <li class="series-list-item">
        <span class="series-list-index">{{ printf "%02d" (add $index 1) }}</span>
        <div>
          <h2><a href="{{ $page.RelPermalink }}">{{ $page.Title }}</a></h2>
          <div class="catalog-meta">
            <time datetime="{{ $page.Date.Format "2006-01-02" }}">{{ $page.Date.Format (i18n "date_format" | default "2006-01-02") }}</time>
            <span>{{ i18n "reading_time" $page.ReadingTime }}</span>
          </div>
          {{ partial "summary.html" $page }}
        </div>
      </li>
    {{ end }}
  </ol>
</section>
```

Do not add an empty-state branch because empty series are already excluded from catalogs; direct visits may show the header and zero-count state without inventing content.

- [x] **Step 4: Add template lookup assertions**

In `verify-theme.ps1`, assert that `layouts/_default/series.html` exists and that it consumes `series/context.html`, `.Parent.RelPermalink`, `.Content`, and the localized series keys. Also assert there is no `layouts/series/list.html`; that path would incorrectly treat `layout` as a template directory.

- [x] **Step 5: Run the gates**

Run:

```shell
pwsh -File scripts/verify-consumer.ps1
pwsh -File scripts/verify-theme.ps1
```

Expected: PASS with weighted pages first and unweighted pages in ascending publication-date order.

- [x] **Step 6: Review the task diff**

Run `git diff --check`. If commits are separately authorized, use `feat: add series overview layout`.

---

### Task 4: Make Post explicit and add series article navigation

**Files:**

- Create: `layouts/partials/post/single.html`
- Create: `layouts/_default/post.html`
- Modify: `layouts/_default/single.html`
- Modify: `scripts/verify-theme.ps1`
- Modify: `scripts/verify-consumer.ps1`

**Interfaces:**

- Consumes: ordinary Hugo Page, configured tag taxonomy, `.CurrentSection`, `series/context.html`, and `series/navigation.html`.
- Produces: identical ordinary article HTML for explicit `post` and omitted layout, plus series-only context/progress/navigation.

- [x] **Step 1: Add failing post-layout assertions**

In `verify-theme.ps1`, replace `$singleTemplate` as the taxonomy consumer with `$postPartial`, while retaining assertions that `_default/single.html` exists. Add:

```powershell
$postLayout = Join-Path $repoRoot "layouts\_default\post.html"
$postPartial = Join-Path $repoRoot "layouts\partials\post\single.html"
Assert-FileExists $postLayout "Post failure: explicit post layout is missing."
Assert-FileExists $postPartial "Post failure: shared post partial is missing."
Assert-Contains $postLayout 'partial\s+"post/single\.html"' "Post failure: named post layout does not use the shared post renderer."
Assert-Contains $singleTemplate 'partial\s+"post/single\.html"' "Post failure: default single fallback does not use the post renderer."
Assert-Contains $postPartial 'site\.Params\.taxonomy\.tag' "Taxonomy failure: shared post renderer lost the configured taxonomy."
Assert-Contains $postPartial '\.CurrentSection\.Layout' "Series navigation failure: post renderer does not detect series context."
```

In `verify-consumer.ps1`, resolve `weighted-second.html` and assert:

```powershell
Assert-Contains $article 'class=("|'''')?post-single' "Post failure: no-layout ordinary article lost the default post renderer."
Assert-NotContains $article 'class=("|'''')?series-context' "Post failure: ordinary article received series-only context."
Assert-Contains $seriesArticle 'class=("|'''')?series-context' "Series post failure: series context is missing."
Assert-Contains $seriesArticle '2 of 4' "Series post failure: localized progress is incorrect in the English consumer fixture."
Assert-Contains $seriesArticle 'href=("|'''')?/notes/series-smoke/weighted-first/' "Series post failure: previous article is incorrect."
Assert-Contains $seriesArticle 'href=("|'''')?/notes/series-smoke/unweighted-old/' "Series post failure: next article is incorrect."
Assert-Contains $seriesArticle 'href=("|'''')?/notes/series-smoke/' "Series post failure: overview return link is missing."
```

- [x] **Step 2: Run the gates and confirm the red state**

Run `pwsh -File scripts/verify-theme.ps1`.

Expected: FAIL because `_default/post.html` and the post partial are missing.

- [x] **Step 3: Extract the current single article markup**

Move the body currently inside `{{ define "main" }}` from `_default/single.html` into `layouts/partials/post/single.html`. Preserve:

- `site.Params.taxonomy.tag` and `.GetTerms` with `.RelPermalink`.
- Date and reading time.
- Existing ordinary `PrevInSection` and `NextInSection` links.
- `.Content` inside `.prose`.

Do not duplicate this markup in two layout files.

- [x] **Step 4: Add both Hugo lookup wrappers**

`layouts/_default/post.html`:

```go-html-template
{{ define "main" }}
  {{ partial "post/single.html" . }}
{{ end }}
```

`layouts/_default/single.html` uses the same content exactly. This proves `layout: post` and no `layout` converge on one renderer.

- [x] **Step 5: Add series-only context to the post partial**

At the top of the partial:

```go-html-template
{{- $seriesPage := false -}}
{{- if and .CurrentSection.IsSection (eq .CurrentSection.Layout "series") -}}
  {{- $seriesPage = .CurrentSection -}}
{{- end -}}
```

When `$seriesPage` is set:

1. Build `$seriesContext := partial "series/context.html" $seriesPage`.
2. Build `$seriesNavigation := partial "series/navigation.html" (dict "page" . "context" $seriesContext)`.
3. Render a `.series-context` row containing icon, linked series title, and localized `Current / Total` progress.
4. Change the back link label to `back_to_series` and keep `$seriesPage.RelPermalink`.
5. Render previous/next from `$seriesNavigation`.

Otherwise preserve the existing `.CurrentSection.RelPermalink`, `back`, `PrevInSection`, and `NextInSection` behavior.

- [x] **Step 6: Verify ordinary and series paths**

Run:

```shell
pwsh -File scripts/verify-consumer.ps1
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-hugo-basic-example.ps1
```

Expected: all PASS; the official basic example still uses the no-layout fallback, while series articles use custom progress and order.

- [x] **Step 7: Review the task diff**

Run `git diff --check`. If commits are separately authorized, use `feat: add explicit post layout and series navigation`.

---

### Task 5: Style the series interface

**Files:**

- Modify: `assets/css/main.css`
- Modify: `scripts/verify-theme.ps1`

**Interfaces:**

- Consumes: class names emitted by Tasks 2–4 and existing CSS tokens.
- Produces: responsive, focus-safe paper/ink presentation without new color roles.

- [x] **Step 1: Add failing CSS assertions**

Add assertions that the SVG uses `currentColor`, `aria-hidden`, and `focusable="false"`; that `.series-icon`, `.series-overview`, `.series-context`, `.series-list`, and `.series-progress` exist; and that series hover selectors occur inside `@media (hover: hover)`.

- [x] **Step 2: Run the theme gate and confirm the red state**

Run `pwsh -File scripts/verify-theme.ps1`.

Expected: FAIL because the series component classes are not styled.

- [x] **Step 3: Add restrained component styles**

Add styles near the existing catalog and post blocks:

- `.series-icon`: `width/height: 1em`, `stroke: currentColor`, `stroke-width: 1.25`, `vector-effect: non-scaling-stroke`, `flex: 0 0 auto`.
- `.catalog-series-link`: inline-flex, aligned to the first title line, `gap: 0.35em`, no wrapping of icon away from the first word.
- `.series-kicker`, `.series-stats`, `.series-context`, `.series-progress`: reuse `--camel`, mono/serif roles already used by catalog metadata; do not create a badge, pill, background fill, or shadow.
- `.series-list`: reset list styling and use whitespace plus the existing `--border` only where the article navigation already uses it.
- `.series-list-item`: two-column folio/content layout; collapse to a single readable column under `480px`.
- `.post-nav` series links: allow wrapping and preserve a visible focus ring.
- Move any touched catalog/post hover rule into the existing `@media (hover: hover)` block.

- [x] **Step 4: Run static and generated checks**

Run:

```shell
hugo --source exampleSite --minify --printPathWarnings
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
git diff --check
```

Expected: PASS with no raw color literals added to the runtime component CSS.

- [x] **Step 5: Review the task diff**

Confirm no new color token or raw color literal was introduced. If commits are separately authorized, use `style: design series reading interface`.

---

### Task 6: Add authoring defaults and a real Demo series

**Files:**

- Modify: `archetypes/default.md`
- Create: `archetypes/series.md`
- Create: `exampleSite/content/zh-cn/posts/series-writing/_index.md`
- Create: `exampleSite/content/zh-cn/posts/series-writing/01-boundary.md`
- Create: `exampleSite/content/zh-cn/posts/series-writing/02-navigation.md`
- Modify: `exampleSite/content/zh-cn/posts/theme-usage.md`
- Modify: `exampleSite/content/zh-cn/about.md`
- Modify: `scripts/verify-theme.ps1`
- Modify: `scripts/verify-consumer.ps1`

**Interfaces:**

- Consumes: the named layouts and authoring contract from Tasks 1–5.
- Produces: copyable Hugo archetypes, one visible Demo series, and executable authoring smoke tests.

- [x] **Step 1: Add failing archetype assertions**

In `verify-theme.ps1`, assert:

```powershell
$seriesArchetype = Join-Path $repoRoot "archetypes\series.md"
Assert-FileExists $seriesArchetype "Archetype failure: archetypes/series.md is missing."
Assert-Contains $defaultArchetype '(?m)^layout:\s*post\s*$' "Archetype failure: ordinary content must explicitly use post layout."
Assert-Contains $seriesArchetype '(?m)^layout:\s*series\s*$' "Archetype failure: series archetype must select the series layout."
Assert-Contains $seriesArchetype '(?ms)^cascade:\s*\r?\n\s+layout:\s*post\s*$' "Archetype failure: series children must inherit post layout."
```

Extend `verify-consumer.ps1` so the generated default archetype smoke file must contain `layout: post`. Add a second temporary path, run:

```shell
hugo new content --kind series notes/archetype-series/_index.md --source scripts/fixtures/consumer-site --clock 2026-08-12T12:00:00Z --noBuildLock
```

Assert `layout: series`, `cascade.layout: post`, YAML fences, and no TOML fences. Remove only `content/notes/archetype-series` in `finally` after resolving and validating that exact fixture path.

- [x] **Step 2: Run the consumer gate and confirm the red state**

Run `pwsh -File scripts/verify-consumer.ps1`.

Expected: FAIL because the default archetype lacks `layout: post` or the series archetype is missing.

- [x] **Step 3: Update the ordinary archetype**

Insert this directly after the generated title in `archetypes/default.md`:

```yaml
layout: post
```

Do not add `weight` to the ordinary archetype; it remains an optional series-order field.

- [x] **Step 4: Create the series archetype**

Create `archetypes/series.md`:

```yaml
---
layout: series
title: '{{ replace (path.Base .File.Dir) "-" " " | title }}'
description: ""
summary: ""
pinned: false
draft: true
cascade:
  layout: post
---
```

- [x] **Step 5: Create the Demo series overview**

Create `series-writing/_index.md`:

```markdown
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
```

- [x] **Step 6: Create the two Demo articles**

Create `01-boundary.md`:

```markdown
---
layout: post
title: "先写下系列的边界"
date: 2026-08-17T09:00:00+08:00
lastmod: 2026-08-18T09:00:00+08:00
weight: 10
description: "从系列入口、普通文章和目录边界开始组织一组长期笔记。"
summary: "系列的第一步不是编号，而是决定哪些文章需要共享入口，哪些文章仍然留在普通博客流里。"
categories:
  - 写作
tags:
  - Hugo
  - 系列
math: false
draft: false
---

一篇文章只要能独立读完，它仍然是一篇普通的 post。只有当几篇文章需要共同的介绍、顺序和返回入口时，我才把它们放进同一个 series section。

## 目录先于编号

标题里的“（一）”“（二）”可以帮助人阅读，却不应该承担网站的数据关系。目录中的 `_index.md` 才是系列身份，文章的 `weight` 才负责顺序。这样改标题不会破坏导航，也不会把相似标题误判成系列。

## 留下清楚的出口

系列入口说明这组文章为什么存在；单篇页面保留返回总览、上一篇和下一篇。读者可以沿着顺序继续，也可以随时回到标签或归档寻找别的内容。

## 下一步

[下一篇：让更新顺序来自内容本身](/posts/series-writing/02-navigation/)
```

Create `02-navigation.md`:

```markdown
---
layout: post
title: "让更新顺序来自内容本身"
date: 2026-08-18T09:00:00+08:00
lastmod: 2026-08-20T09:00:00+08:00
weight: 20
description: "使用 weight、date 和 lastmod 同时维护阅读顺序与目录更新时间。"
summary: "weight 回答先读哪一篇，lastmod 回答这个系列最近在写什么；两种顺序不必混在一起。"
categories:
  - 写作
tags:
  - Hugo
  - 系列
math: false
draft: false
---

系列里其实有两条时间线。`weight` 是阅读顺序，适合从基础到进阶；`lastmod` 是维护时间，适合告诉首页这个系列最近更新了什么。

## 阅读顺序保持稳定

我会把 `weight` 写成 `10`、`20`、`30`，中间需要插入文章时仍有余地。没有填写 `weight` 的文章排在显式顺序之后，再按发布日期从旧到新显示，不会悄悄挤进课程中间。

## 首页只留下一个入口

首页显示“把文章连成一条路：让更新顺序来自内容本身”，点击后进入系列总览。章节没有消失，它们仍然拥有独立 URL、标签和归档记录，只是不在首页重复占据多行。

## 下一步

[返回系列总览](/posts/series-writing/)
```

- [x] **Step 7: Teach the existing usage guide and About page**

Add a concise “普通文章与系列” section to `theme-usage.md` with these commands:

```shell
hugo new content posts/my-note.md
hugo new content --kind series posts/my-series/_index.md
hugo new content posts/my-series/01-introduction.md
```

Explain that default content is `post`, `series` belongs only on `_index.md`, and `weight` is optional. Update `about.md` from “六篇文章” to “六篇独立文章和一个两篇系列”, then add the series overview link without listing both child pages as separate top-level Demo entries.

- [x] **Step 8: Add Demo output assertions**

In `verify-theme.ps1`, keep the existing exact six root-level Demo article assertion; nested series articles must not weaken it. Add paths and assertions for:

- `/posts/series-writing/` exists and has `.series-overview`.
- Home and `/posts/` each link `/posts/series-writing/` exactly once.
- Neither page links the two child permalinks directly.
- The combined title contains `把文章连成一条路` and `让更新顺序来自内容本身`.
- The overview orders `先写下系列的边界` before `让更新顺序来自内容本身`.
- The second article shows `第 2 / 2 篇`, previous link, and overview link.
- The Pages build prefixes every new link with `/hugo-theme-inyo/`.
- The multilingual project-site build prefixes authored Demo links with `/project/zh-cn/`.

- [x] **Step 9: Run authoring and compatibility gates**

Run:

```shell
hugo --source exampleSite --minify --printPathWarnings
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
pwsh -File scripts/verify-hugo-basic-example.ps1
git diff --check
```

Expected: all PASS, including both generated archetype smoke files and all subpath links.

- [x] **Step 10: Review the task diff**

Read the rendered Demo prose, not only source Markdown. If commits are separately authorized, use `docs: demonstrate post and series authoring`.

---

### Task 7: Synchronize design, public docs, and project skills

**Files:**

- Modify: `DESIGN.md`
- Modify: `AGENTS.md`
- Modify: `README.md`
- Modify: `README.en.md`
- Modify: `CHANGELOG.md`
- Modify: `.pi/README.md`
- Modify: `.pi/skills/inyo-theme-development/SKILL.md`
- Modify: `.pi/skills/inyo-content-authoring/SKILL.md`
- Modify: `.pi/skills/inyo-theme-release/SKILL.md`
- Modify: `scripts/verify-theme.ps1`

**Interfaces:**

- Consumes: verified runtime behavior from Tasks 1–6.
- Produces: one consistent public contract for users, contributors, agents, and smoke tests.

- [x] **Step 1: Add failing documentation assertions**

Require both READMEs to mention `layout: post`, `layout: series`, `_index.md`, `weight`, and `lastmod`. Require `DESIGN.md` and `AGENTS.md` to state that Home/Blog collapse a series to one entry while archives and tags retain individual articles. Require the development and content skills to name the new layout files and Demo series path.

- [x] **Step 2: Run the theme gate and confirm the red state**

Run `pwsh -File scripts/verify-theme.ps1`.

Expected: FAIL on the first missing public series contract.

- [x] **Step 3: Record the design decision**

In `DESIGN.md`:

- Extend the homepage directory section with the mixed post/series entry rules.
- Add a `post / series` subsection under content systems.
- Record an ADR stating that Inyo uses section + `_index.md` for ordered series, while tags remain taxonomy and titles remain presentation.
- Specify icon + visible text, no badge/pill/card, overview stats, and series article navigation.
- State that no new color token is introduced.

In `AGENTS.md`, update the current product contract, configuration/content boundary, Demo-content synchronization row, and project-skill routing with the exact template and archetype behavior.

- [x] **Step 4: Update both public READMEs semantically**

Add one feature bullet for section-backed series. Add a compact “普通文章与系列 / Posts and series” section containing:

```text
content/posts/my-series/_index.md
content/posts/my-series/01-introduction.md
```

and the approved YAML examples. Explain:

- ordinary content defaults to `post`;
- `layout: post` may be explicit;
- only series `_index.md` uses `layout: series`;
- `pinned` belongs on the series `_index.md`;
- non-zero `weight` controls reading order and `lastmod` controls recent-update ordering;
- no taxonomy configuration is required.

Keep Chinese and English feature, authoring, and verification claims equivalent.

- [x] **Step 5: Update project skills and Demo map**

- `inyo-theme-development`: add the named-layout lookup rule, catalog folding invariant, series ordering, ordinary fallback, and verification paths.
- `inyo-content-authoring`: retain the six standalone root articles, add `series-writing/_index.md` plus two child articles to the content map, and document the `post`/`series` Front Matter rules.
- `inyo-theme-release`: add the README synchronization requirement for public series behavior and archetype examples.
- `.pi/README.md`: replace “六篇 Demo 文章” with the exact “六篇独立文章 + 一个两篇系列” contract.

- [x] **Step 6: Record only implemented behavior in CHANGELOG**

Under `Unreleased`, add:

```markdown
### Added

- 新增 Hugo section 驱动的 `post` / `series` 内容模型：系列在首页和博客目录折叠为单一入口，并提供总览、篇数、更新时间、阅读进度与上一篇/下一篇导航。
- 新增普通文章默认 archetype 与系列 `_index.md` archetype，支持 `weight` 阅读顺序、`lastmod` 更新时间和系列级 `pinned`。
```

Do not assign a version number.

- [x] **Step 7: Run the full automated gate**

From the repository root:

```shell
hugo --source exampleSite --minify --printPathWarnings
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
pwsh -File scripts/verify-hugo-basic-example.ps1
git diff --check
```

Expected: all commands exit 0 and Hugo emits no duplicate-target warning.

- [x] **Step 8: Perform browser verification**

Run:

```shell
hugo server --source exampleSite
```

Inspect Home, `/posts/`, `/posts/series-writing/`, both series articles, and one ordinary article in:

- light and dark mode;
- desktop width;
- `390×844`;
- keyboard-only traversal;
- reduced-motion mode.

Confirm:

- the SVG and visible “系列” text remain attached to the linked title;
- the title link enters the overview, not the latest article;
- no child article appears separately on Home or Blog;
- focus indicators are visible;
- long titles and metadata wrap without overlap;
- `scrollWidth === clientWidth`;
- ordinary article appearance is unchanged;
- the poetry Hero and its data remain homepage-only.

Stop the server after review.

- [x] **Step 9: Verify artifact hygiene and final scope**

Run:

```shell
git status --short --untracked-files=all
```

Expected: only the spec, plan, intended source, fixture, Demo, documentation, and skill files appear. No generated `public/`, `resources/`, lock, log, or temporary archetype file remains.

- [x] **Step 10: Final review checkpoint**

Compare the implementation against every acceptance criterion in `docs/superpowers/specs/2026-08-22-post-series-content-model.md`. If commits are separately authorized, group verified runtime and synchronized documentation into reviewable conventional commits; otherwise leave the working tree uncommitted and report the exact validation results.
