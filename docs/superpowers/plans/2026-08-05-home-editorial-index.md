# Inyo Home Editorial Index Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the flat homepage post list with a semantic editorial index that features the newest post and renders older posts as a sparse archive.

**Architecture:** `layouts/index.html` owns the one-off featured/archive branching because the two entry forms are not reusable components. `assets/css/main.css` supplies role-named layout classes using existing tokens, while Hugo i18n supplies the only new copy. Temporary generated-site assertions cover zero, one, and many post states without adding permanent test infrastructure.

**Tech Stack:** Hugo 0.164.0 extended, Go templates, native CSS, Hugo i18n, Bash/Python verification commands.

## Global Constraints

- Preserve the existing centered `40em` reading column and all existing color tokens.
- Use `.ByDate.Reverse`; the newest page in the `posts` section is featured.
- Render exactly one visually hidden homepage `<h1>` and use `<h2>` for post titles.
- Render no cards, shadows, cover images, tags, buttons, repeated borders, pagination, or year grouping.
- Use no new JavaScript, dependency, configuration flag, or reusable post-entry partial.
- At `600px` and below, archive metadata stacks below its title; the featured summary remains visible.
- Modify only `layouts/index.html`, `assets/css/main.css`, three i18n files, and `DESIGN.md` for the implementation.
- Preserve the unrelated `.gitignore` working-tree modification.

---

### Task 1: Semantic Homepage and Localized Content States

**Files:**
- Modify: `layouts/index.html`
- Modify: `i18n/zh-cn.toml`
- Modify: `i18n/en.toml`
- Modify: `i18n/ja.toml`

**Interfaces:**
- Consumes: Hugo `site.RegularPages`, `.ByDate.Reverse`, `.Summary`, `.ReadingTime`, `after`, and existing `date_format` translations.
- Produces: `.home-featured`, `.home-archive`, `.home-empty`, `.brush-divider`, and `.visually-hidden` markup for Task 2.

- [ ] **Step 1: Build the current example and prove the new semantic contract fails**

Run:

```bash
out="$TEMP/pi-agent/inyo-home-before"
rm -rf "$out"
hugo --source exampleSite --destination "$out" --minify
python - "$out/index.html" <<'PY'
from pathlib import Path
import re, sys
html = Path(sys.argv[1]).read_text(encoding="utf-8")
assert len(re.findall(r"<h1(?:\s|>)", html)) == 1
assert "home-featured" in html
assert "home-archive" in html
PY
```

Expected: FAIL because the current homepage has no `<h1>` and no editorial-index classes.

- [ ] **Step 2: Implement the collection split and semantic markup**

Replace `layouts/index.html` with:

```go-html-template
{{ define "main" }}
<h1 class="visually-hidden">{{ site.Title }}</h1>
{{ with .Content }}
<div class="prose">{{ . }}</div>
{{ end }}
<div class="brush-divider" aria-hidden="true">
  <svg viewBox="0 0 400 20" preserveAspectRatio="none" focusable="false">
    <path d="M4 14 Q 90 6, 190 11 T 396 9" fill="none" stroke="currentColor" stroke-width="1.6" opacity="0.55" />
    <path d="M20 16 Q 120 9, 240 12 T 380 11" fill="none" stroke="currentColor" stroke-width="0.8" opacity="0.4" />
  </svg>
</div>

{{ $posts := (where site.RegularPages "Section" "posts").ByDate.Reverse }}
{{ if eq (len $posts) 0 }}
<p class="home-empty">{{ i18n "no_posts" }}</p>
{{ else }}
{{ $featured := index $posts 0 }}
<article class="home-featured">
  <header>
    <h2 class="home-featured-title"><a href="{{ $featured.RelPermalink }}">{{ $featured.Title }}</a></h2>
    <div class="home-featured-meta">
      <time datetime="{{ $featured.Date.Format "2006-01-02" }}">{{ $featured.Date.Format (i18n "date_format" | default "2006-01-02") }}</time>
      <span aria-hidden="true">·</span>
      <span>{{ i18n "reading_time" $featured.ReadingTime }}</span>
    </div>
  </header>
  <p class="home-featured-summary">{{ $featured.Summary | plainify | htmlUnescape | truncate 160 }}</p>
</article>

{{ if gt (len $posts) 1 }}
<ul class="home-archive">
  {{ range after 1 $posts }}
  <li class="home-archive-item">
    <h2 class="home-archive-title"><a href="{{ .RelPermalink }}">{{ .Title }}</a></h2>
    <time class="home-archive-date" datetime="{{ .Date.Format "2006-01-02" }}">{{ .Date.Format (i18n "date_format" | default "2006-01-02") }}</time>
  </li>
  {{ end }}
</ul>
{{ end }}
{{ end }}
{{ end }}
```

- [ ] **Step 3: Add exact translations**

Add these messages:

```toml
# zh-cn.toml
[reading_time]
other = "阅读约 {{ .Count }} 分钟"

[no_posts]
other = "暂时还没有文章。"
```

```toml
# en.toml
[reading_time]
one = "{{ .Count }} minute read"
other = "{{ .Count }} minute read"

[no_posts]
other = "No articles yet."
```

```toml
# ja.toml
[reading_time]
other = "読了約{{ .Count }}分"

[no_posts]
other = "まだ記事はありません。"
```

- [ ] **Step 4: Build and verify the many-post HTML contract**

Run:

```bash
out="$TEMP/pi-agent/inyo-home-many"
rm -rf "$out"
hugo --source exampleSite --destination "$out" --minify
python - "$out/index.html" <<'PY'
from pathlib import Path
from html.parser import HTMLParser
import sys

class HomeParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.h1 = self.h2 = self.featured = self.archive = self.summaries = 0
        self.datetimes = []
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        classes = set(attrs.get("class", "").split())
        self.h1 += tag == "h1"
        self.h2 += tag == "h2"
        self.featured += "home-featured" in classes
        self.archive += "home-archive" in classes
        self.summaries += "home-featured-summary" in classes
        if tag == "time": self.datetimes.append(attrs.get("datetime"))

p = HomeParser()
p.feed(Path(sys.argv[1]).read_text(encoding="utf-8"))
assert p.h1 == 1
assert p.h2 == 2
assert p.featured == 1
assert p.archive == 1
assert p.summaries == 1
assert p.datetimes == ["2026-08-05", "2026-08-04"]
PY
```

Expected: Hugo succeeds and all assertions pass.

### Task 2: Token-Based Editorial Layout and Design Record

**Files:**
- Modify: `assets/css/main.css`
- Modify: `DESIGN.md`

**Interfaces:**
- Consumes: role classes produced by Task 1 and existing `--ink`, `--cinnabar`, `--camel`, and `--srf-3` tokens.
- Produces: desktop/mobile editorial hierarchy and a durable homepage rule in the design authority.

- [ ] **Step 1: Add minimal role-based styles**

Add this utility near the base image rule:

```css
.visually-hidden {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
```

Add `color: var(--srf-3);` to `.brush-divider`, then place this block before the existing generic post-list styles:

```css
/* 首页：文集目录 */
.home-featured { margin: 0 0 3em; }
.home-featured-title { margin: 0; font-size: 1.55em; }
.home-featured-title a,
.home-archive-title a { color: var(--ink); border: 0; }
.home-featured-title a:hover,
.home-archive-title a:hover { color: var(--cinnabar); }
.home-featured-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 0.45em;
  margin-top: 0.4em;
  color: var(--camel);
  font-size: 0.8em;
  letter-spacing: 1px;
}
.home-featured-summary { margin: 0.9em 0 0; }
.home-archive { list-style: none; margin: 0; padding: 0; }
.home-archive-item {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  align-items: baseline;
  gap: 1.5em;
  padding: 0.65em 0;
}
.home-archive-title { margin: 0; font-size: 1.05em; line-height: 1.6; }
.home-archive-date {
  color: var(--camel);
  font-size: 0.8em;
  letter-spacing: 1px;
  white-space: nowrap;
}
.home-empty { margin: 0; color: var(--camel); }
```

- [ ] **Step 2: Add the mobile stack**

Inside the existing `@media (max-width: 600px)` block, add:

```css
.brush-divider { margin: 2em 0; }
.home-featured { margin-bottom: 2.5em; }
.home-archive-item {
  grid-template-columns: 1fr;
  gap: 0.1em;
  padding: 0.7em 0;
}
```

Do not hide `.home-featured-summary` and do not change its font tokens.

- [ ] **Step 3: Record the accepted homepage rules**

Add this section before the ADR section in `DESIGN.md`:

```markdown
## 6. 首页：文集目录

- **开场**：保留 `40em` 阅读栏；以视觉隐藏的站点标题 `<h1>` 建立语义层级，随后呈现 `_index.md` 导语与 token 着色的装饰性毛笔笔触。
- **最新文章**：只突出按发布日期倒序后的第一篇，显示 `<h2>` 标题、日期、阅读时间和约 160 字纯文本摘要；层级只靠字号与留白建立。
- **旧文索引**：其余文章只显示 `<h2>` 标题与日期；桌面同排、`≤600px` 上下堆叠。
- **内容状态**：零篇显示本地化空状态；一篇只显示最新文章；多篇才创建旧文索引。
- **禁止项**：不使用卡片面、阴影、重复边框、标签、按钮、封面图或额外强调色。
```

Renumber `ADR 记录` and `致谢与来源` to sections 7 and 8.

- [ ] **Step 4: Verify CSS and the production build**

Run:

```bash
hugo --source exampleSite --minify
python - <<'PY'
from pathlib import Path
css = Path("assets/css/main.css").read_text(encoding="utf-8")
block = css[css.index("/* 首页：文集目录 */"):css.index("/* 文章列表 */")]
assert "grid-template-columns: minmax(0, 1fr) auto" in block
assert "@media (max-width: 600px)" in css
assert "color: var(--srf-3)" in css
assert "#" not in block
PY
git diff --check
```

Expected: build and assertions pass; no new hardcoded color appears in the homepage CSS.

### Task 3: Edge-State and Final Scope Verification

**Files:**
- Test only: temporary fixture content under `$TEMP/pi-agent/`

**Interfaces:**
- Consumes: completed homepage implementation.
- Produces: evidence that wrapper branching and generated semantics work for zero, one, and many posts.

- [ ] **Step 1: Create temporary zero- and one-post content fixtures**

Run:

```bash
root="$TEMP/pi-agent/inyo-home-fixtures"
rm -rf "$root"
mkdir -p "$root/zero" "$root/one/posts"
printf '%s\n' '---' 'title: "Empty"' '---' 'Introduction.' > "$root/zero/_index.md"
printf '%s\n' '---' 'title: "One"' '---' 'Introduction.' > "$root/one/_index.md"
printf '%s\n' '---' 'title: "Only article"' 'date: 2026-08-05' '---' 'One article summary.' > "$root/one/posts/only.md"
```

- [ ] **Step 2: Build both fixtures through the example site**

Run:

```bash
root="$TEMP/pi-agent/inyo-home-fixtures"
hugo --source exampleSite --contentDir "$root/zero" --destination "$root/zero-public" --minify
hugo --source exampleSite --contentDir "$root/one" --destination "$root/one-public" --minify
```

Expected: both builds succeed.

- [ ] **Step 3: Assert omitted wrappers and localized output**

Run:

```bash
python - "$TEMP/pi-agent/inyo-home-fixtures" <<'PY'
from pathlib import Path
import sys
root = Path(sys.argv[1])
zero = (root / "zero-public/index.html").read_text(encoding="utf-8")
one = (root / "one-public/index.html").read_text(encoding="utf-8")
assert "home-empty" in zero
assert "home-featured" not in zero
assert "home-archive" not in zero
assert "暂时还没有文章。" in zero
assert "home-featured" in one
assert "home-archive" not in one
assert "home-featured-summary" in one
PY
```

Expected: all assertions pass.

- [ ] **Step 4: Perform final visual and diff review**

Run `hugo server --source exampleSite --disableFastRender`, inspect desktop and a viewport at or below `600px` in light and dark themes, then stop the server. Confirm there is no card surface, archive border, hidden featured summary, layout overflow, or lost focus indicator.

Review:

```bash
git diff -- layouts/index.html assets/css/main.css i18n/zh-cn.toml i18n/en.toml i18n/ja.toml DESIGN.md
git status --short
```

Expected: only the six implementation files and this plan are part of the feature; `.gitignore` remains unstaged and unchanged by the agent.

- [ ] **Step 5: Commit the focused implementation**

```bash
git add layouts/index.html assets/css/main.css i18n/zh-cn.toml i18n/en.toml i18n/ja.toml DESIGN.md docs/superpowers/plans/2026-08-05-home-editorial-index.md
git commit -m "feat: add editorial index homepage"
```
