# Inyo Blog Information Architecture Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align Inyo with the common Hugo personal-blog pattern: Home, Blog, Tags, Archives, and article detail pages.

**Architecture:** Keep the existing `/posts/` section URL for compatibility, but expose it as “博客” in navigation. Add a dedicated `/archives/` section page whose template groups regular pages from `mainSections` by year. Home will build one collection with pinned pages first, followed by non-pinned pages ordered by date.

**Tech Stack:** Hugo Extended 0.164.0, Go templates, TOML front matter, native CSS, PowerShell smoke checks.

## Global Constraints

- Do not rename `/posts/` or change existing article URLs.
- Do not add search, pagination, comments, or new runtime dependencies.
- Keep tags configurable through `params.navigation.tags`.
- Keep About as an auxiliary page, not a primary blog content type.
- Use `pinned = true` for multiple pinned articles; pinned articles are ordered by date descending.
- Do not commit `public/`, `resources/`, or `.hugo_build.lock`.

---

### Task 1: Add failing contracts for the blog structure

**Files:**

- Modify: `scripts/verify-theme.ps1`

- [ ] Assert the default generated navigation displays the i18n value for `posts` as `博客`.
- [ ] Assert `/archives/` is generated and contains an archive heading plus at least one year group.
- [ ] Assert `layouts/archives/list.html` exists and uses `GroupByDate`.
- [ ] Assert `layouts/index.html` contains a pinned collection and merges it before the normal collection.
- [ ] Run `hugo --source exampleSite --minify` and `pwsh -File scripts/verify-theme.ps1`; the new assertions must fail before implementation.

### Task 2: Implement the archive page

**Files:**

- Create: `layouts/archives/list.html`
- Create: `exampleSite/content/archives/_index.md`
- Modify: `config/_default/params.toml`
- Modify: `layouts/_default/baseof.html`

- [ ] Add `navigation.archives = "archives"` to the default parameters.
- [ ] Resolve the archive page through `site.Params.navigation.archives`, only rendering the link when the page exists.
- [ ] Render `site.RegularPages` filtered by `site.Params.mainSections`, grouped with `.GroupByDate "2006" "desc"`.
- [ ] Render each year as a heading and each article as a compact date/title link using `.RelPermalink`.
- [ ] Add the Demo branch page with `title = "归档"` and a short description.

### Task 3: Implement the pinned-first home collection

**Files:**

- Modify: `layouts/index.html`
- Modify: `archetypes/default.md`
- Modify: `exampleSite/content/posts/front-matter.md`

- [ ] Add `pinned = false` to the default TOML archetype.
- [ ] Build `$all` from `site.RegularPages` filtered by `mainSections`.
- [ ] Build `$pinned = where $all "Params.pinned" true` and sort it by date descending.
- [ ] Build `$latest` from the remaining pages and sort it by date descending.
- [ ] Concatenate `$pinned` and `$latest` so multiple pinned articles appear first without duplication.
- [ ] Preserve the current date grouping and summary rendering after ordering.
- [ ] Document that `pinned = true` supports multiple pinned articles and that date determines their order.

### Task 4: Align navigation copy and project documentation

**Files:**

- Modify: `i18n/zh-cn.toml`
- Modify: `i18n/en.toml`
- Modify: `i18n/ja.toml`
- Modify: `README.md`
- Modify: `README.en.md`
- Modify: `DESIGN.md`
- Modify: `AGENTS.md`
- Modify: `.pi/skills/inyo-theme-development/SKILL.md`

- [ ] Change the `posts` translation to “博客” in Chinese and the equivalent “Blog” labels in the other languages.
- [ ] Add the `archives` translation key to all three language files.
- [ ] Document the page model: Home, Blog section, article detail, Tags, Archives, and auxiliary About.
- [ ] Document `pinned = true` and the pinned-first ordering contract.
- [ ] Document that `/posts/` remains the compatibility URL while its navigation label is “博客”.

### Task 5: Verify all generated contracts

**Files:**

- Modify: `scripts/verify-theme.ps1`

- [ ] Verify Home, `/posts/`, article detail, `/tags/`, `/archives/`, and `/about/` are generated.
- [ ] Verify archive links use article permalinks and do not hardcode `/posts/`.
- [ ] Verify the default navigation includes Home, Blog, Tags, and Archives, with About auxiliary.
- [ ] Run:

```bash
hugo --source exampleSite --minify --printPathWarnings
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
git diff --check
```

- [ ] Remove generated `public/`, `resources/`, and `.hugo_build.lock` files before handoff.
