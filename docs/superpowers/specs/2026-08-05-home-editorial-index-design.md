# Inyo Home Editorial Index Design

## Context

Inyo already has a stable identity: a `40em` long-form reading column, paper/ink dual themes, restrained cinnabar interaction, generous whitespace, and no runtime JavaScript beyond theme switching. The current homepage renders every post with the same title, date, and tags, giving readers no clear entrance into the archive and producing an incorrect heading hierarchy.

The new homepage should feel like a quiet literary index rather than a card feed. It may learn from mature Hugo themes' content hierarchy and edge-state handling, but it must not copy their UI, palette, framework, or feature surface.

## Goals

- Give the newest article one clear but restrained point of emphasis.
- Keep older articles easy to scan without visual competition.
- Preserve Inyo's existing shell, colors, typography, and reading width.
- Produce semantic, accessible markup for zero, one, and many posts.
- Keep implementation native to Hugo templates and the existing CSS file.

## Non-goals

- Redesigning article, section, taxonomy, or list pages.
- Adding cards, shadows, cover images, pinned posts, year groups, pagination, or new configuration flags.
- Adding colors, JavaScript, frameworks, view transitions, or a fixed site sidebar.
- Creating a reusable post-entry partial before markup reuse proves it is needed.

## Page Structure

### Global shell

Keep the existing top header, horizontal navigation, seal, footer, and centered `40em` container. The homepage introduces no fixed-position elements.

### Opening

Render a visually hidden `<h1>` containing the site title so the page has one semantic primary heading without repeating the visible header title. Continue rendering `_index.md` through `.Content`; authors should keep this introduction to one restrained sentence, but the theme does not truncate user-authored content.

Place the existing brush motif after the introduction as a decorative transition. Render the small SVG inline with `stroke="currentColor"`, style it through an existing CSS token, and set `aria-hidden="true"`; it must not communicate structure by itself. Keep the markup local until a second use justifies extracting a partial.

### Featured article

Select the newest post in the `posts` section as the featured article. Render:

- an `<h2>` linked title;
- publication date;
- Hugo `.ReadingTime` with a localized minutes label;
- one plain-text summary derived from `.Summary | plainify`, truncated to approximately 160 characters.

The featured article remains an unboxed text block. It receives hierarchy from type size and whitespace only: no card background, border, badge, permanent accent color, tags, or “read more” button. Cinnabar remains an interaction color.

### Archive

Render every remaining post as a compact row containing only:

- an `<h2>` linked title;
- a machine-readable publication date.

Do not repeat summaries, reading time, or tags. Use whitespace rather than a border after every row. Do not group by year until real archive size demonstrates that need.

## Content States

### Zero posts

Render the introduction and brush divider, followed by one localized empty-state sentence. Do not render featured or archive wrappers.

### One post

Render the featured article only. Omit the archive wrapper entirely.

### Multiple posts

Render one featured article followed by the archive of remaining posts.

## Data Flow

1. Start with `where site.RegularPages "Section" "posts"`.
2. Apply `.ByDate.Reverse` explicitly so publication order does not depend on Hugo's default collection ordering.
3. Bind the first page as the featured article.
4. Bind the remaining pages as the archive collection.
5. Branch explicitly for zero, one, and multiple results.

No partial is introduced for a post row in this milestone because featured and archive markup have different responsibilities and no proven reuse.

## Responsive Behavior

Use the existing `600px` breakpoint.

- Above `600px`, archive rows place title on the left and date on the right.
- At or below `600px`, archive rows stack naturally with date below the title.
- The featured summary remains visible at all widths because it is the page's primary content entrance.
- Mobile spacing contracts modestly, but font, line-height, and color tokens remain unchanged.
- No absolute positioning is allowed for post content or metadata.

## Semantics and Accessibility

- The homepage contains exactly one `<h1>` and uses `<h2>` for every post title.
- Every `<time>` includes a valid `datetime` attribute.
- The brush divider is decorative, hidden from assistive technology, and colored only through an existing CSS token.
- Links retain native keyboard behavior and visible browser focus.
- New text receives `zh-cn`, `en`, and `ja` translations.
- The implementation must not use color alone to distinguish the featured article.

## Styling Boundaries

Add only component classes needed by the new homepage to `assets/css/main.css`. All colors must come from existing tokens. Both themes inherit the same layout and semantic hierarchy; no new dark-mode color override is expected because no color role is introduced.

Use existing typography variables and spacing conventions. Avoid selectors tied to generated Hugo element order when a named class expresses the role more clearly.

## Files

Expected implementation surface:

- Modify `layouts/index.html` for collection branching and semantic markup.
- Modify `assets/css/main.css` for featured/archive responsive layout.
- Modify `i18n/zh-cn.toml`, `i18n/en.toml`, and `i18n/ja.toml` for reading-time and empty-state text.
- Modify `DESIGN.md` to record the accepted homepage hierarchy and responsive behavior.

Do not modify the unrelated `.gitignore` working-tree change.

## Verification

1. Build with `hugo --source exampleSite --minify` without warnings.
2. Inspect generated homepage HTML and verify one `<h1>`, post `<h2>` elements, valid dates, one featured summary, and no archive summaries.
3. Build temporary zero-post and one-post fixtures outside the repository and verify wrappers are omitted correctly.
4. Check desktop and mobile layouts in a browser in both light and dark themes.
5. Confirm the brush divider is decorative and all new text is translated.
6. Run `git diff --check` and review the focused diff for hardcoded colors, unrelated files, new JavaScript, or unnecessary abstractions.
