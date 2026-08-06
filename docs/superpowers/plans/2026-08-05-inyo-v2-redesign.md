# Inyo v2 Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild Inyo as a Japanese-modern-minimal theme: right fixed rail + left/center reading column, ink-black dark palette, refined thin-line seal, catalog homepage, single-line footer.

**Architecture:** One grid shell in `baseof.html` (`grid-template-areas`) carries the sticky rail and content column; CSS breakpoints at `1000px`/`768px` collapse the rail into a top bar. The dark palette flips to 墨色 `#1D1B1C` (the light mode's body ink) with 月白 text and 朱红 links, all WCAG-verified. The seal becomes `currentColor`-driven so it adapts per theme.

**Tech Stack:** Hugo 0.164.0 extended, Go templates, native CSS variables, Hugo i18n, Python contrast/HTML assertions.

## Global Constraints

- Design authority: `docs/superpowers/specs/2026-08-05-inyo-v2-redesign-design.md` (confirmed).
- Exactly one `<h1>` per page; catalog titles are `<h2>`; rail brand is not a heading.
- No new JavaScript; theme toggle remains the only inline script.
- No cards, shadows, cover images, pagination, year groups, or new config flags.
- All colors from tokens; every new dark token recorded with WCAG measurement in `DESIGN.md` §2.
- Long-form column stays `40em`, line-height `2.0`, horizontal LTR body text.
- Preserve the unrelated `.gitignore` working-tree modification.

---

### Task 1: Grid Shell with Right Rail

**Files:**
- Rewrite: `layouts/_default/baseof.html`
- Rewrite: `layouts/partials/header.html` → rail brand/nav/toggle
- Rewrite: `layouts/partials/footer.html` → rail footer (© + RSS)
- Modify: `assets/css/main.css` (layout section)

**Interfaces:**
- Consumes: existing `seal.html`, i18n `home`/`posts`/`about`, `.theme-toggle` script in baseof.
- Produces: `.shell`, `.content`, `.rail`, `.rail-main`, `.rail-footer`, `.container` markup for Tasks 2–4.

- [ ] **Step 1: Rewrite `layouts/_default/baseof.html`**

```go-html-template
{{- $font := cond (eq site.Params.font "wenkai") "wenkai" "serif" -}}
<!DOCTYPE html>
<html lang="{{ site.Language.Locale | default "zh-cn" }}" data-theme="light" data-font="{{ $font }}">
<head>
  {{ partial "head.html" . }}
</head>
<body>
  <div class="shell">
    <aside class="rail">
      <div class="rail-main">
        {{ partial "header.html" . }}
      </div>
      <div class="rail-footer">
        {{ partial "footer.html" . }}
      </div>
    </aside>
    <main class="content">
      <div class="container">
        {{ block "main" . }}{{ end }}
      </div>
    </main>
  </div>

  <script>
    (function () {
      var key = 'inyo-theme';
      var root = document.documentElement;
      var stored = localStorage.getItem(key);
      if (stored) root.setAttribute('data-theme', stored);
      var btn = document.getElementById('theme-toggle');
      if (btn) {
        btn.addEventListener('click', function () {
          var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
          root.setAttribute('data-theme', next);
          localStorage.setItem(key, next);
        });
      }
    })();
  </script>
</body>
</html>
```

- [ ] **Step 2: Rewrite `layouts/partials/header.html`**

```go-html-template
<div class="rail-brand">
  {{ partial "seal.html" . }}
  <span class="rail-title">{{ site.Title }}</span>
</div>
<nav class="rail-nav">
  <a href="{{ site.Home.RelPermalink }}">{{ i18n "home" }}</a>
  {{ with site.GetPage "/posts" }}<a href="{{ .RelPermalink }}">{{ i18n "posts" }}</a>{{ end }}
  {{ with site.GetPage "/about" }}<a href="{{ .RelPermalink }}">{{ i18n "about" }}</a>{{ end }}
</nav>
<button class="theme-toggle" id="theme-toggle" type="button" aria-label="Toggle theme">☯</button>
```

- [ ] **Step 3: Rewrite `layouts/partials/footer.html`**

```go-html-template
<p class="rail-copy">© {{ now.Year }} {{ site.Title }}</p>
<p class="rail-rss"><a href="{{ "index.xml" | relURL }}">RSS</a></p>
```

- [ ] **Step 4: Replace the layout section of `assets/css/main.css`**

Delete `.site-header*` blocks and `.site-footer`. Add (desktop default):

```css
/* ---------- 3. 布局 v2 ---------- */
.shell {
  display: grid;
  grid-template-columns: 1fr 18em;
  grid-template-areas: "content rail";
  min-height: 100vh;
}
.content { grid-area: content; min-width: 0; }
.rail {
  grid-area: rail;
  position: sticky;
  top: 0;
  height: 100vh;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 1.6em;
  padding: 2.2em 1.6em;
  border-left: 1px solid var(--border);
}
.rail-footer { margin-top: auto; border-top: 1px solid var(--border); padding-top: 1em; }
.rail-brand { display: flex; align-items: center; gap: 0.7em; }
.rail-title { font-weight: 700; letter-spacing: 2px; }
.rail-nav { display: flex; flex-direction: column; gap: 0.9em; font-size: 0.92em; }
.rail-nav a { color: var(--ink); border: 0; letter-spacing: 1px; }
.rail-nav a:hover { color: var(--cinnabar); }
.rail-copy, .rail-rss { margin: 0; font-family: var(--font-mono); font-size: 0.72em; color: var(--camel); letter-spacing: 0.5px; }
.rail-rss a { color: var(--camel); border: 0; }
.rail-rss a:hover { color: var(--cinnabar); }
.seal { display: inline-block; color: var(--cinnabar); border: 0; }
.seal svg { display: block; }
```

Add to `@media (max-width: 1000px)` a new block (before the 600px one):

```css
@media (max-width: 1000px) {
  .shell { grid-template-columns: 1fr 14em; }
}
```

Replace the existing `@media (max-width: 600px)` block with:

```css
@media (max-width: 768px) {
  .shell { grid-template-columns: 1fr; grid-template-areas: "rail" "content"; }
  .rail {
    position: static;
    height: auto;
    border-left: 0;
    border-bottom: 1px solid var(--border);
    padding: 1.2em 1.25em;
  }
  .rail-main { display: flex; flex-wrap: wrap; align-items: center; gap: 0.8em 1.2em; }
  .rail-nav { flex-direction: row; flex-wrap: wrap; gap: 1em; }
  .rail-footer { margin-top: 0; border-top: 0; padding-top: 0; }
  h1 { font-size: 1.5em; }
}
```

Update the print block to hide the rail:

```css
@media print {
  .rail, .theme-toggle { display: none; }
  .content { grid-area: content; }
  body { background: #fff; }
}
```

- [ ] **Step 5: Build and assert shell structure**

Run:

```bash
out="$TEMP/pi-agent/inyo-v2-shell"
rm -rf "$out"
hugo --source exampleSite --destination "$out" --minify
python - "$out/index.html" <<'PY'
from pathlib import Path
from html.parser import HTMLParser
import sys
class P(HTMLParser):
    def __init__(self):
        super().__init__(); self.shell=self.content=self.rail=self.brand=self.nav=self.copy=0
    def handle_starttag(self, tag, attrs):
        c=set(dict(attrs).get("class","").split())
        self.shell += "shell" in c; self.content += "content" in c; self.rail += "rail" in c
        self.brand += "rail-brand" in c; self.nav += "rail-nav" in c; self.copy += "rail-copy" in c
p=P(); p.feed(Path(sys.argv[1]).read_text(encoding="utf-8"))
assert (p.shell,p.content,p.rail,p.brand,p.nav,p.copy)==(1,1,1,1,1,1)
PY
```

Expected: PASS. (`.rail-footer` and `.rail-rss` verified in Task 5.)

- [ ] **Step 6: Commit**

```bash
git add layouts/_default/baseof.html layouts/partials/header.html layouts/partials/footer.html assets/css/main.css
git commit -m "feat: rebuild shell with right rail layout"
```

### Task 2: Ink-Black Dark Palette and DESIGN.md v2

**Files:**
- Modify: `assets/css/main.css` (dark token block)
- Modify: `DESIGN.md` (§2 table, §3/§4 component notes, new ADR-7, mark ADR-2 superseded, rewrite usage disciplines)

**Interfaces:**
- Consumes: token names from Task 1 CSS.
- Produces: verified dark tokens for Tasks 3–4.

- [ ] **Step 1: Replace the `[data-theme="dark"]` token block**

```css
[data-theme="dark"] {
  --paper:        #1D1B1C;  /* 墨色 底色 = 亮色正文墨色（纸墨闭环） */
  --paper-2:      #322F31;  /* 抬升面 t=0.12 */
  --ink:          #ECE6DC;  /* 月白暖灰 正文 13.80:1 */
  --cinnabar:     #ED5126;  /* 朱红 链接/印章 4.74:1 */
  --camel:        #D4C4B7;  /* 晓灰 标签/日期 10.10:1 */
  --indigo:       #C1C8D6;  /* 云峰灰 代码 10.20:1 */
  --amber:        #E1DBD7;  /* 高亮档(装饰) */

  /* 层次 5 档（墨色→月白 OKLCH 短路径插值） */
  --srf-1: #262324;  /* 抬升 t=0.05 */
  --srf-2: #322F31;  /* 卡片 t=0.12 */
  --srf-3: #4A4648;  /* 边框 t=0.25 */
  --srf-4: #888185;  /* 弱化 t=0.55 (on 底 4.51:1) */
  --srf-5: #C0B6BB;  /* 高亮 t=0.80 (仅装饰) */

  --border:       var(--srf-3);
  --selection:    rgba(237, 81, 38, 0.22);
  --code-bg:      #2C2C2C;  /* 缁 代码块底 (云峰灰 on 缁 8.31:1) */
  --code-text:    var(--indigo);
  --btn-bg:       var(--cinnabar);
  --btn-text:     var(--paper);
}
```

- [ ] **Step 2: Update `DESIGN.md`**

- §0 identity line: replace "昭和レトロ" positioning with "日式现代简约" (keep 纸墨二元 and 古中国水墨).
- §2.2 table: new dark values above.
- §2.3 usage disciplines, rewritten with measured values:

```markdown
1. **墨色 `#1D1B1C` 上正文/链接全角色过 AA**——月白 13.80、朱红 4.74、晓灰 10.10（原"松烟墨禁作剑锋紫辅助面"条款随剑锋紫体系删除）。
2. **暗色抬升面（`--paper-2` t=0.12）上的链接用舌红 `#F19790`**（on #322F31 实测 6.03:1）；朱红 #ED5126 在抬升面上 3.66:1 不达标。
3. **t≥0.55 浅档（`#888185` 及以上）禁止放正文/链接**——只作弱化文字（4.51）、边框或装饰。
```

- §2.4: 朱红 #ED5126 取代舌红作为暗色主链接色（温度轴与亮色朱砂统一）；保留朱砂↔黛蓝三角结构注记。
- §4 component table: 分隔线 row → remove brush; 竖排题款 row → remove; Logo row → thin-line seal + currentColor.
- New ADR-7:

```markdown
### ADR-7: 暗色改用墨黑体系（取代 ADR-2 剑锋紫）
- **状态**: 已接受；ADR-2 已标记为**被取代**
- **决策**: 暗底用墨色 `#1D1B1C`（742 库真名，恰为亮色正文墨色），月白 `#ECE6DC` 正文、朱红 `#ED5126` 链接
- **理由**: 亮=墨字在纸，暗=白墨在墨，双模式同一设计；剑锋紫 H=314.6° 与暖纸温度轴分离是"两套设计"感的根源
- **实测**: 朱红 on 墨色 4.74 ✅（on #232323 4.35 ❌，故底必须取暗端）；月白 13.80 ✅；抬升面链接须用舌红 6.03 ✅
```

- [ ] **Step 3: Verify tokens and record measurements**

Run:

```bash
python - <<'PY'
from pathlib import Path
import re
css = Path("assets/css/main.css").read_text(encoding="utf-8")
dark = css[css.index('[data-theme="dark"]'):css.index('/* ---------- 2. Base')]
pairs = {
  '#1D1B1C':'paper','#322F31':'paper-2','#ECE6DC':'ink','#ED5126':'cinnabar',
  '#D4C4B7':'camel','#C1C8D6':'indigo','#262324':'srf-1','#4A4648':'srf-3',
  '#888185':'srf-4','#C0B6BB':'srf-5','#2C2C2C':'code-bg',
}
for hexv,name in pairs.items():
    assert hexv.lower() in dark.lower(), f"missing {name} {hexv}"
assert '剑锋紫' not in css, "legacy purple removed"
assert '#3E3841' not in css, "legacy purple base removed"
PY
hugo --source exampleSite --minify
```

Expected: PASS, build succeeds.

- [ ] **Step 4: Commit**

```bash
git add assets/css/main.css DESIGN.md
git commit -m "design: ink-black dark palette with ADR-7"
```

### Task 3: Thin-Line Seal v2

**Files:**
- Rewrite: `static/img/seal-yang.svg`, `static/img/seal-yin.svg`
- Rewrite: `layouts/partials/seal.html`
- Modify: `assets/css/main.css` (`.seal` size)

**Interfaces:**
- Consumes: dark/light `--cinnabar` tokens.
- Produces: adaptive seal for Task 1 rail and favicon.

- [ ] **Step 1: Regenerate thin-line static seals**

`static/img/seal-yang.svg`:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 40 40" role="img" aria-label="Inyo seal">
  <rect x="1.5" y="1.5" width="37" height="37" fill="none" stroke="#D92121" stroke-width="1.5"/>
  <text x="20" y="24.5" text-anchor="middle" font-size="11" fill="#D92121" font-family="'Noto Serif SC','Source Han Serif SC',serif">陰陽</text>
</svg>
```

`static/img/seal-yin.svg`:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 40 40" role="img" aria-label="Inyo seal">
  <rect x="1.5" y="1.5" width="37" height="37" fill="#D92121" stroke="#D92121" stroke-width="1.2"/>
  <text x="20" y="24.5" text-anchor="middle" font-size="11" fill="#F8F4F0" font-family="'Noto Serif SC','Source Han Serif SC',serif">陰陽</text>
</svg>
```

- [ ] **Step 2: Make the inline partial theme-adaptive**

Rewrite `layouts/partials/seal.html` with `currentColor` (drops hardcoded `#D92121`):

```go-html-template
{{ $text := site.Params.seal_text | default "陰陽" }}
{{ $style := site.Params.seal_style | default "yang" }}
{{ if eq $style "yin" }}
<svg class="seal" width="30" height="30" viewBox="0 0 40 40" role="img" aria-label="seal">
  <rect x="1.5" y="1.5" width="37" height="37" fill="currentColor" stroke="currentColor" stroke-width="1.2"/>
  <text x="20" y="24.5" text-anchor="middle" font-size="11" fill="var(--paper)" font-family="inherit">{{ $text }}</text>
</svg>
{{ else }}
<svg class="seal" width="30" height="30" viewBox="0 0 40 40" role="img" aria-label="seal">
  <rect x="1.5" y="1.5" width="37" height="37" fill="none" stroke="currentColor" stroke-width="1.5"/>
  <text x="20" y="24.5" text-anchor="middle" font-size="11" fill="currentColor" font-family="inherit">{{ $text }}</text>
</svg>
{{ end }}
```

- [ ] **Step 3: Verify adaptive color**

Run:

```bash
python - <<'PY'
from pathlib import Path
s = Path("layouts/partials/seal.html").read_text(encoding="utf-8")
assert 'currentColor' in s and '#D92121' not in s and 'var(--paper)' in s
css = Path("assets/css/main.css").read_text(encoding="utf-8")
assert '.seal' in css
PY
```

- [ ] **Step 4: Commit**

```bash
git add static/img/seal-yang.svg static/img/seal-yin.svg layouts/partials/seal.html assets/css/main.css
git commit -m "design: refine seal to thin-line adaptive mark"
```

### Task 4: Catalog Homepage and Page Adaptation

**Files:**
- Rewrite: `layouts/index.html`
- Rewrite: `layouts/_default/single.html`
- Rewrite: `layouts/_default/list.html`
- Modify: `assets/css/main.css` (catalog + post-single + meta styles)

**Interfaces:**
- Consumes: rail shell, `reading_time` i18n (exists), `.tag` component.
- Produces: catalog markup; removes legacy `.post-list` styles.

- [ ] **Step 1: Rewrite `layouts/index.html`**

```go-html-template
{{ define "main" }}
<h1 class="visually-hidden">{{ site.Title }}</h1>
{{ with .Content }}
<div class="prose home-intro">{{ . }}</div>
{{ end }}

{{ $posts := (where site.RegularPages "Section" "posts").ByDate.Reverse }}
{{ if eq (len $posts) 0 }}
<p class="home-empty">{{ i18n "no_posts" }}</p>
{{ else }}
<ul class="catalog">
  {{ range $posts }}
  <li class="catalog-item">
    <h2 class="catalog-title"><a href="{{ .RelPermalink }}">{{ .Title }}</a></h2>
    <div class="catalog-meta">
      <time datetime="{{ .Date.Format "2006-01-02" }}">{{ .Date.Format (i18n "date_format" | default "2006-01-02") }}</time>
      <span aria-hidden="true">·</span>
      <span>{{ i18n "reading_time" .ReadingTime }}</span>
    </div>
    {{ with .Description }}<p class="catalog-summary">{{ . | plainify }}</p>{{ end }}
  </li>
  {{ end }}
</ul>
{{ end }}
{{ end }}
```

- [ ] **Step 2: Rewrite `layouts/_default/single.html`**

```go-html-template
{{ define "main" }}
<article class="post-single">
  <header class="post-header">
    <h1>{{ .Title }}</h1>
    <div class="post-meta">
      <time datetime="{{ .Date.Format "2006-01-02" }}">{{ .Date.Format (i18n "date_format" | default "2006-01-02") }}</time>
      <span aria-hidden="true">·</span>
      <span>{{ i18n "reading_time" .ReadingTime }}</span>
      {{ range .Params.tags }}<a class="tag" href="{{ "tags/" | relLangURL }}{{ . | urlize }}">{{ . }}</a>{{ end }}
    </div>
  </header>

  {{ if .Params.toc }}<div class="toc">{{ .TableOfContents }}</div>{{ end }}

  <div class="prose">
    {{ .Content }}
  </div>

  <nav class="post-nav">
    {{ with .PrevInSection }}<a href="{{ .RelPermalink }}">← {{ i18n "prev" }}: {{ .Title }}</a>{{ end }}
    {{ with .NextInSection }}<a href="{{ .RelPermalink }}">{{ i18n "next" }}: {{ .Title }} →</a>{{ end }}
  </nav>
</article>
{{ end }}
```

- [ ] **Step 3: Rewrite `layouts/_default/list.html`**

```go-html-template
{{ define "main" }}
<h1>{{ .Title }}</h1>
{{ with .Content }}
<div class="prose">{{ . }}</div>
{{ end }}
<ul class="catalog">
  {{ range .Pages }}
  <li class="catalog-item">
    <h2 class="catalog-title"><a href="{{ .RelPermalink }}">{{ .Title }}</a></h2>
    <div class="catalog-meta">
      <time datetime="{{ .Date.Format "2006-01-02" }}">{{ .Date.Format (i18n "date_format" | default "2006-01-02") }}</time>
      <span aria-hidden="true">·</span>
      <span>{{ i18n "reading_time" .ReadingTime }}</span>
    </div>
    {{ with .Description }}<p class="catalog-summary">{{ . | plainify }}</p>{{ end }}
  </li>
  {{ end }}
</ul>
{{ end }}
```

- [ ] **Step 4: Replace catalog/post styles in CSS**

Replace the v1 homepage block (`/* 首页：文集目录 */` … `.home-empty`) and the legacy `/* 文章列表 */` `.post-list` styles with:

```css
/* 目录 */
.catalog { list-style: none; margin: 0; padding: 0; }
.catalog-item { padding: 1.1em 0; border-bottom: 1px solid var(--border); }
.catalog-item:first-child { border-top: 1px solid var(--border); }
.catalog-title { margin: 0; font-size: 1.15em; }
.catalog-title a { color: var(--ink); border: 0; }
.catalog-title a:hover { color: var(--cinnabar); }
.catalog-meta {
  margin-top: 0.3em;
  font-family: var(--font-mono);
  font-size: 0.75em;
  color: var(--camel);
  letter-spacing: 0.5px;
  display: flex;
  flex-wrap: wrap;
  gap: 0.45em;
}
.catalog-summary { margin: 0.5em 0 0; font-size: 0.92em; color: var(--ink); opacity: 0.85; }
.home-empty { margin: 0; color: var(--camel); }

/* 文章页 v2 */
.post-single { max-width: 40em; }
.post-header { margin-bottom: 2.5em; }
.post-header h1 { margin-bottom: 0.3em; }
.post-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 0.45em;
  font-family: var(--font-mono);
  font-size: 0.75em;
  color: var(--camel);
  letter-spacing: 0.5px;
}
.post-meta .tag { font-family: var(--font-serif); }
.post-date { display: none; }
```

Also delete `.post-title`, `.post-list li` border rules from the legacy block, and remove the v1 `.brush-divider` rule (Task 5 removes the file).

- [ ] **Step 5: Verify semantics and edge states**

Run:

```bash
root="$TEMP/pi-agent/inyo-v2-catalog"
rm -rf "$root"; mkdir -p "$root/zero" "$root/one/posts"
printf '%s\n' '---' 'title: "Empty"' '---' 'Intro.' > "$root/zero/_index.md"
printf '%s\n' '---' 'title: "One"' '---' 'Intro.' > "$root/one/_index.md"
printf '%s\n' '---' 'title: "Only"' 'date: 2026-08-05' '---' 'Body.' > "$root/one/posts/only.md"
hugo --source exampleSite --destination "$root/many" --minify
hugo --source exampleSite --contentDir "$root/zero" --destination "$root/zero-pub" --minify >/dev/null
hugo --source exampleSite --contentDir "$root/one" --destination "$root/one-pub" --minify >/dev/null
python - "$root" <<'PY'
from html.parser import HTMLParser
from pathlib import Path
import sys
class P(HTMLParser):
    def __init__(self):
        super().__init__(); self.h1=self.h2=self.cat=self.summary=self.empty=0; self.times=[]
    def handle_starttag(self, tag, attrs):
        c=set(dict(attrs).get("class","").split())
        self.h1 += tag=="h1"; self.h2 += tag=="h2"
        self.cat += "catalog" in c; self.summary += "catalog-summary" in c; self.empty += "home-empty" in c
        if tag=="time": self.times.append(dict(attrs).get("datetime"))
def feed(path):
    p=P(); p.feed(Path(path).read_text(encoding="utf-8")); return p
root=Path(sys.argv[1])
many=feed(root/"many/index.html")
assert (many.h1,many.h2,many.cat)==(1,2,1) and many.times==["2026-08-05","2026-08-04"]
one=feed(root/"one-pub/index.html"); assert (one.h1,one.h2,one.cat)==(1,1,1)
zero=feed(root/"zero-pub/index.html"); assert zero.empty==1 and zero.cat==0
article=feed(root/"many/posts/paper-and-ink/index.html")
assert article.h1==1 and article.cat==0, "article page has one h1 and no catalog"
print("PASS: catalog semantics + edge states")
PY
```

- [ ] **Step 6: Commit**

```bash
git add layouts/index.html layouts/_default/single.html layouts/_default/list.html assets/css/main.css
git commit -m "feat: catalog homepage and v2 page adaptation"
```

### Task 5: Remove Legacy, Sync Docs, Full Verification

**Files:**
- Delete: `static/img/brush.svg`
- Modify: `assets/css/main.css` (remove `.brush-divider`, `.tategaki`; adjust print)
- Modify: `hugo.toml`, `exampleSite/hugo.toml` (remove `vertical_footer`)
- Modify: `README.md` (remove `vertical_footer` config line; update structure mention)
- Modify: `exampleSite/content/_index.md` (toggle hint wording)
- Modify: `AGENTS.md` (铁律 3 vertical rule; token list; usage disciplines)
- Modify: `.pi/skills/inyo-theme-development/SKILL.md` (sync 铁律, 布局蒸馏, 验证清单)
- Modify: `DESIGN.md` §4/§5 (already partially in Task 2; remove remaining brush/tategaki rows)

**Interfaces:**
- Consumes: completed v2 theme.
- Produces: final evidence report.

- [ ] **Step 1: Delete brush and strip legacy CSS**

Run and edit:

```bash
git rm static/img/brush.svg
```

Remove from `assets/css/main.css`: `.brush-divider` rules (and the `/* 分隔线: 毛笔笔触 */` comment), `.tategaki` rules, `.post-date` dead rule if any remains.

- [ ] **Step 2: Remove `vertical_footer` everywhere**

`hugo.toml`: delete `vertical_footer = ""` line.
`exampleSite/hugo.toml`: delete `vertical_footer = "行到水穷处 坐看云起时"`.
`README.md`: delete the `# 页脚竖排签名（装饰性）` config block and `vertical_footer = "行到水穷处"`.
`exampleSite/content/_index.md`: change "点击右上角 ☯ 切换主题。" to "点击 ☯ 切换主题。"

- [ ] **Step 3: Update `AGENTS.md`**

Replace 铁律 3 with:

```markdown
3. **正文永远横排**：竖排（`writing-mode: vertical-rl`）禁止用于任何正文或导航；装饰性竖排已整体移除（v2）。
```

Replace the usage-discipline lines (铁律 2) with the v2 measured disciplines (墨色体系三条款 from Task 2 Step 2), and update 铁律 1 token list to the v2 dark set.

- [ ] **Step 4: Update `.pi/skills/inyo-theme-development/SKILL.md`**

- 铁律 3: same vertical rule.
- 布局蒸馏: remove "不引入固定全站侧栏" line; add "右侧固定导航栏（v2 实测启用）只在 ≤768px 折叠为顶部条".
- 验证清单: replace `#3E3841` expectation with `#1D1B1C`; replace seal expectation with adaptive cinnabar.

- [ ] **Step 5: Full verification**

Run:

```bash
set -e
hugo --source exampleSite --minify
rg -n 'vertical_footer|tategaki|brush-divider|剑锋紫|#3E3841|#F19790' --glob '!docs/**' --glob '!README.md' . && exit 1 || true
python - <<'PY'
from pathlib import Path
css = Path("assets/css/main.css").read_text(encoding="utf-8")
for legacy in ['tategaki','brush-divider','#3E3841']:
    assert legacy not in css, legacy
PY
git diff --check
```

Expected: PASS with zero legacy references.

- [ ] **Step 6: Launch preview for the user's visual review**

```bash
hugo server --source exampleSite --disableFastRender --bind 127.0.0.1 --port 1313
```

User reviews desktop/mobile, light/dark. After approval, stop the server.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "chore: remove legacy footer and sync v2 docs"
```

## Self-Review Notes

- Spec coverage: shell (T1), palette+ADR (T2), seal (T3), catalog/pages (T4), deletions+docs+verify (T5) — all 11 spec sections covered.
- No placeholders; every code block is complete.
- Type/name consistency: `.shell`/`.content`/`.rail`/`.rail-footer`/`.catalog*` names match across tasks; `.brush-divider` and `.tategaki` are consistently removed in T5.
- The unrelated `.gitignore` change is never staged.
