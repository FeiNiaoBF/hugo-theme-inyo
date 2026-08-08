$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$exampleSite = Join-Path $repoRoot "exampleSite"
$out = Join-Path ([System.IO.Path]::GetTempPath()) "inyo-theme-verify-$PID"

function Assert-Contains($Path, $Pattern, $Message) {
  $text = Get-Content -Raw $Path
  if ($text -notmatch $Pattern) { throw $Message }
}

function Assert-NotContains($Path, $Pattern, $Message) {
  $text = Get-Content -Raw $Path
  if ($text -match $Pattern) { throw $Message }
}

function Assert-FileExists($Path, $Message) {
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw $Message }
}

function Assert-FileMissing($Path, $Message) {
  if (Test-Path -LiteralPath $Path) { throw $Message }
}

function Assert-ExternalTargetsSafe($Path, $Message) {
  $text = Get-Content -Raw $Path
  $links = [regex]::Matches($text, '<a\b[^>]*target=("|''|)?_blank("|''|)?[^>]*>')
  foreach ($link in $links) {
    if ($link.Value -notmatch 'rel=("|''|)?[^>]*noopener' -or $link.Value -notmatch 'rel=("|''|)?[^>]*noreferrer') {
      throw "$Message $($link.Value)"
    }
  }
}

function Assert-ImagesHaveAlt($Path, $Message) {
  $text = Get-Content -Raw $Path
  $images = [regex]::Matches($text, '<img\b[^>]*>')
  foreach ($image in $images) {
    if ($image.Value -notmatch '\balt=("|''|)?[^"''>\s][^"''>]*') {
      throw "$Message $($image.Value)"
    }
  }
}

function Assert-HasLongCatalogSummary($Path, $MinimumChars, $Message) {
  $text = Get-Content -Raw $Path
  $summaries = [regex]::Matches($text, '<p\b[^>]*class=("|''|)?catalog-summary\1[^>]*>(.*?)</p>', 'Singleline')
  foreach ($summary in $summaries) {
    $plain = [System.Net.WebUtility]::HtmlDecode(([regex]::Replace($summary.Groups[2].Value, '<[^>]+>', ''))).Trim()
    if ($plain.Length -ge $MinimumChars) { return }
  }
  throw $Message
}

$themeParamsConfig = Join-Path $repoRoot "config\_default\params.toml"
$themeMarkupConfig = Join-Path $repoRoot "config\_default\markup.toml"
$exampleConfig = Join-Path $exampleSite "hugo.toml"
$demoPosts = Join-Path $exampleSite "content\posts"
$heroPoemsData = Join-Path $repoRoot "data\inyo\hero_poems.toml"
$apiFixture = Join-Path $repoRoot "scripts\fixtures\chinese-poetry-api-random.json"
$oldHeroPartial = Join-Path $repoRoot "layouts\partials\inky-overlay.html"
$oldHeroAsset = Join-Path $repoRoot "assets\img\hero-beauty.jpg"
$designDoc = Join-Path $repoRoot "DESIGN.md"
$readme = Join-Path $repoRoot "README.md"
$agentsDoc = Join-Path $repoRoot "AGENTS.md"
$inyoSkill = Join-Path $repoRoot ".pi\skills\inyo-theme-development\SKILL.md"
$skillFiles = Get-ChildItem (Join-Path $repoRoot ".pi\skills") -Recurse -Filter "SKILL.md" -File
Assert-Contains $themeParamsConfig '(?m)^font\s*=\s*"wenkai"' "Config failure: theme default params must define the wenkai font."
Assert-Contains $themeParamsConfig '(?m)^math\s*=\s*false' "Config failure: theme default params must disable math globally."
Assert-Contains $themeParamsConfig '(?m)^webfonts\s*=\s*true' "Config failure: theme default params must enable webfonts."
Assert-Contains $themeParamsConfig '(?m)^mainSections\s*=\s*\["posts"\]' "Config failure: theme default params must use posts as the main section."
Assert-Contains $themeParamsConfig '(?ms)^\[heroPoetry\.api\].*?^enabled\s*=\s*false' "Config failure: the theme must disable the remote poetry API by default."
Assert-Contains $themeParamsConfig '(?m)^endpoint\s*=\s*"https://poetry\.palemoky\.com/api/poems/random"' "Config failure: the theme must provide the current poetry API endpoint."
Assert-Contains $themeParamsConfig '(?m)^lang\s*=\s*"zh-Hans"' "Config failure: the theme must default the poetry API to simplified Chinese."
Assert-NotContains $themeParamsConfig '(?m)^heroImage(?:Quality)?\s*=' "Config failure: obsolete Hero image parameters remain in theme defaults."
Assert-Contains $exampleConfig '(?ms)^\[params\.heroPoetry\.api\].*?^enabled\s*=\s*true' "Config failure: exampleSite must enable the optional poetry API."
Assert-FileExists $heroPoemsData "Hero poetry failure: the local fallback data file is missing."
Assert-FileExists $apiFixture "Hero poetry failure: the verified API response fixture is missing."
Assert-FileMissing $oldHeroPartial "Hero poetry failure: obsolete inky-overlay.html still exists."
Assert-FileMissing $oldHeroAsset "Hero poetry failure: obsolete hero-beauty.jpg still exists."
$heroPoemsText = Get-Content -Raw $heroPoemsData
$heroPoemBlocks = [regex]::Matches($heroPoemsText, '(?ms)^\[\[poems\]\]\s*(.*?)(?=^\[\[poems\]\]|\z)')
if ($heroPoemBlocks.Count -lt 2) { throw "Hero poetry failure: local fallback data must contain at least two poems." }
foreach ($poemBlock in $heroPoemBlocks) {
  if ($poemBlock.Groups[1].Value -notmatch '(?m)^text\s*=\s*"[^"\r\n]+"' -or $poemBlock.Groups[1].Value -notmatch '(?m)^source\s*=\s*"[^"\r\n]+"') {
    throw "Hero poetry failure: each local fallback must contain text and source."
  }
}
$apiSample = Get-Content -Raw $apiFixture | ConvertFrom-Json
if (-not $apiSample.data.title -or -not $apiSample.data.content[0] -or -not $apiSample.data.author.name) {
  throw "Hero poetry failure: the API fixture does not preserve the verified title/content/author contract."
}
Assert-Contains $themeMarkupConfig '(?m)^_merge\s*=\s*"deep"' "Config failure: theme markup defaults must deep-merge with project markup settings."
Assert-Contains $themeMarkupConfig '(?m)^\[highlight\]\s*\r?\nnoClasses\s*=\s*false' "Config failure: theme defaults must preserve class-based Chroma output."
Assert-Contains $exampleConfig '(?m)^_merge\s*=\s*"deep"' "Config failure: exampleSite must deep-merge its Goldmark settings with theme markup defaults."
Assert-Contains $inyoSkill 'config/_default/params\.toml' "Skill failure: Inyo development skill is missing the theme default config contract."
Assert-Contains $inyoSkill 'scripts/verify-theme\.ps1' "Skill failure: Inyo development skill is missing the smoke verification command."
Assert-Contains $inyoSkill '0\.164\.0' "Skill failure: Inyo development skill is out of sync with the Hugo baseline."
Assert-Contains $inyoSkill '双翼墨线' "Skill failure: Inyo development skill is missing the current Hero motion contract."
Assert-Contains $inyoSkill '顶部中央' "Skill failure: Inyo development skill is missing the closed Hero border geometry."
Assert-Contains $inyoSkill '\.Summary' "Skill failure: Inyo development skill is missing the Hugo summary contract."
Assert-NotContains $inyoSkill 'seal-yin\.svg' "Skill failure: Inyo development skill references a nonexistent seal-yin.svg asset."
Assert-Contains $designDoc '朱红双翼墨线' "Design failure: DESIGN.md is missing the accepted Hero motion direction."
Assert-Contains $designDoc '底部中央.*顶部中央' "Design failure: DESIGN.md does not describe the closed double-wing line geometry."
Assert-Contains $readme '两阶段' "Documentation failure: README.md does not describe the immediate-feedback Hero flow."
Assert-Contains $readme '顶部中央' "Documentation failure: README.md does not describe the closed Hero border geometry."
Assert-Contains $readme '\.Summary' "Documentation failure: README.md does not describe catalog summary semantics."
Assert-Contains $agentsDoc '双翼墨线' "Agent rules failure: AGENTS.md is missing the current Hero motion contract."
Assert-Contains $agentsDoc '顶部中央' "Agent rules failure: AGENTS.md is missing the closed Hero border geometry."
Assert-Contains $agentsDoc '\.Summary' "Agent rules failure: AGENTS.md is missing the Hugo summary contract."
foreach ($skillFile in $skillFiles) {
  Assert-NotContains $skillFile.FullName 'xxd-(?:ui-token|brand-system|palette-applier|print-packaging)' "Skill failure: $($skillFile.FullName) references a project skill that does not exist."
}

# Demo documentation contracts: keep the example site task-oriented and in sync with the current theme.
$demoDocs = @(
  @{ Name = "getting-started"; Patterns = @('主题入门', 'Hugo Extended `0\.164\.0`', 'replace github\.com/FeiNiaoBF/hugo-theme-inyo', 'aliases:') },
  @{ Name = "configuration-reference"; Patterns = @('配置参考', '参数 \| 默认值 \| 可选值 \| 作用 \| 作用范围', 'heroPoetry\.api') },
  @{ Name = "front-matter"; Patterns = @('Front Matter 指南', 'math: true', '图片与可访问性') },
  @{ Name = "markdown-style-guide"; Patterns = @('功能展厅', '功能索引', 'data-kind="hook"') },
  @{ Name = "customization"; Patterns = @('定制主题', '--seal-disc', '双翼墨线', '\.Summary') },
  @{ Name = "release-checklist"; Patterns = @('发布清单', 'scripts/verify-theme\.ps1', 'git diff --check', '100ms', '2–3 行') }
)
foreach ($demoDoc in $demoDocs) {
  $docPath = Join-Path $demoPosts ($demoDoc.Name + ".md")
  if (-not (Test-Path $docPath)) { throw "Demo docs failure: missing exampleSite/content/posts/$($demoDoc.Name).md." }
  foreach ($pattern in $demoDoc.Patterns) {
    Assert-Contains $docPath $pattern "Demo docs failure: $($demoDoc.Name).md is missing $pattern."
  }
  Assert-NotContains $docPath '<!--more-->' "Demo docs failure: $($demoDoc.Name).md contains a raw summary divider that shadows its front matter summary."
  Assert-Contains $docPath '## 下一步' "Demo docs failure: $($demoDoc.Name).md is missing its next-step navigation."
}
$oldGuidePath = Join-Path $demoPosts "theme-guide.md"
if (Test-Path $oldGuidePath) { throw "Demo docs failure: obsolete theme-guide.md source file still exists." }
foreach ($stalePattern in @('0\.140\.0', 'hugo\.yaml', 'languageName', 'replacements\s*[:=]')) {
  foreach ($doc in $demoDocs) {
    $docPath = Join-Path $demoPosts ($doc.Name + ".md")
    Assert-NotContains $docPath $stalePattern "Demo docs failure: $($doc.Name).md contains stale configuration syntax $stalePattern."
  }
}
foreach ($staleHeroPattern in @('heroImage', 'hero-beauty', 'inky-overlay', '墨滴涟漪')) {
  foreach ($doc in $demoDocs) {
    $docPath = Join-Path $demoPosts ($doc.Name + ".md")
    Assert-NotContains $docPath $staleHeroPattern "Demo docs failure: $($doc.Name).md contains obsolete Hero material $staleHeroPattern."
  }
}

& hugo --source $exampleSite --minify --destination $out
Write-Output "Verification output: $out"

$homePage = Join-Path $out "index.html"
$article = Join-Path $out "posts\markdown-style-guide\index.html"
$gettingStarted = Join-Path $out "posts\getting-started\index.html"
$configuration = Join-Path $out "posts\configuration-reference\index.html"
$frontMatter = Join-Path $out "posts\front-matter\index.html"
$customization = Join-Path $out "posts\customization\index.html"
$releaseChecklist = Join-Path $out "posts\release-checklist\index.html"
$legacyGuide = Join-Path $out "posts\theme-guide\index.html"
$about = Join-Path $out "about\index.html"
$posts = Join-Path $out "posts\index.html"
$tags = Join-Path $out "tags\index.html"
$term = Join-Path $out "tags\inyo\index.html"
$notFound = Join-Path $out "404.html"
$css = Join-Path $repoRoot "assets\css\main.css"
$sealTemplate = Join-Path $repoRoot "layouts\partials\seal.html"
$favicon = Join-Path $repoRoot "static\img\seal-yang.svg"
$socialPartial = Join-Path $repoRoot "layouts\partials\social.html"
$baseof = Join-Path $repoRoot "layouts\_default\baseof.html"
$indexTemplate = Join-Path $repoRoot "layouts\index.html"
$heroScript = Join-Path $repoRoot "layouts\partials\hero-poetry-script.html"
$summarySource = Join-Path $repoRoot "layouts\partials\summary-source.html"
$langPartial = Join-Path $repoRoot "layouts\partials\lang.html"
$headingHook = Join-Path $repoRoot "layouts\_default\_markup\render-heading.html"

foreach ($demoPage in @(
  @{ Path = $gettingStarted; Name = "getting-started" },
  @{ Path = $configuration; Name = "configuration-reference" },
  @{ Path = $frontMatter; Name = "front-matter" },
  @{ Path = $article; Name = "markdown-style-guide" },
  @{ Path = $customization; Name = "customization" },
  @{ Path = $releaseChecklist; Name = "release-checklist" },
  @{ Path = $legacyGuide; Name = "legacy theme-guide alias" }
)) {
  if (-not (Test-Path $demoPage.Path)) { throw "Demo docs failure: generated page is missing $($demoPage.Name)." }
}
Assert-Contains $legacyGuide 'getting-started|主题入门' "Demo docs failure: legacy theme-guide alias does not point to the renamed guide."

# P2 Task 1: runtime color token discipline and the documented favicon exception.
$componentCss = ([regex]::Match((Get-Content -Raw $css), '(?s)/\* ---------- 5\. 组件 ---------- \*/.*')).Value
if ([string]::IsNullOrWhiteSpace($componentCss)) { throw "P2 failure: could not locate the runtime component CSS section for color checks." }
if ($componentCss -match 'rgba\(') { throw "P2 failure: runtime component CSS contains a raw rgba() color." }
Assert-NotContains $css '@media print[\s\S]*?background:\s*#fff' "P2 failure: print styles use a hard-coded white background."
Assert-NotContains $sealTemplate '(?:fill|stroke)\s*=\s*("|''|)?#[0-9A-Fa-f]{3,8}' "P2 failure: inline Logo SVG contains a hard-coded hex fill or stroke."
Assert-Contains $css '\.seal\s*\{[^}]*--seal-disc:\s*var\(--paper-2\)' "P2 failure: inline Logo is missing the themed disc token."
Assert-Contains $sealTemplate 'fill="var\(--seal-disc\)"' "P2 failure: Logo disc does not use its theme token."
Assert-Contains $favicon 'fill="#F2EDE6"' "P2 failure: favicon lost its fixed brand color exception."
Assert-Contains $favicon 'fill="#1D1B1C"' "P2 failure: favicon lost its fixed ink color."
Assert-Contains $favicon 'stroke="#D92121"' "P2 failure: favicon lost its fixed cinnabar ring."
Assert-NotContains $favicon 'var\(--' "P2 failure: favicon unexpectedly depends on CSS variables."
Assert-NotContains $socialPartial 'aria-label="RSS"' "P2 failure: all internal social links are incorrectly labeled as RSS."

# Hero poetry: semantic, local-first, homepage-only, with the old image system fully removed.
Assert-Contains $homePage '<button\b[^>]*class=("|''|)?hero(?:\s|"|''|>)' "Hero poetry failure: homepage is missing the semantic Hero button."
Assert-Contains $homePage '<button\b[^>]*class=("|''|)?hero[^>]*\baria-label=("|''|)?[^"''>\s]+' "Hero poetry failure: Hero button is missing aria-label."
Assert-NotContains $homePage 'aria-label=("|''|)?[^>]*。，' "Hero poetry failure: Hero button accessible name contains doubled punctuation."
Assert-Contains $homePage '<button\b[^>]*class=("|''|)?hero[^>]*\baria-busy=("|''|)?false' "Hero poetry failure: Hero button is missing its initial aria-busy state."
Assert-Contains $homePage 'class=("|''|)?hero__quote' "Hero poetry failure: homepage is missing the visible poem line."
Assert-Contains $homePage 'class=("|''|)?hero__source' "Hero poetry failure: homepage is missing the visible poem source."
Assert-Contains $homePage '<svg\b[^>]*class=("|''|)?hero__stroke[^>]*\baria-hidden=("|''|)?true' "Hero poetry failure: homepage is missing the decorative double-wing SVG."
Assert-Contains $indexTemplate '(?s)<path\b[^>]*class="hero__stroke-line hero__stroke-line--left"[^>]*pathLength="1"' "Hero poetry failure: the left border path is missing."
Assert-Contains $indexTemplate '(?s)<path\b[^>]*class="hero__stroke-line hero__stroke-line--right"[^>]*pathLength="1"' "Hero poetry failure: the right border path is missing."
Assert-NotContains $indexTemplate 'hero__stroke-glow' "Hero poetry failure: the short glow path should be removed from the SVG."
Assert-NotContains $indexTemplate '<line\b' "Hero poetry failure: the obsolete straight-line SVG geometry remains."
Assert-Contains $homePage 'id=("|''|)?hero-poetry-data' "Hero poetry failure: homepage is missing serialized local fallback data."
Assert-Contains $homePage 'https://poetry\.palemoky\.com/api/poems/random' "Hero poetry failure: homepage does not contain the configured optional API endpoint."
Assert-NotContains $homePage 'inky-overlay|hero-beauty|heroImage' "Hero poetry failure: homepage still contains the obsolete image Hero system."
Assert-NotContains $homePage '(?:fill|stroke)=("|''|)?#[0-9A-Fa-f]{3,8}' "P2 failure: generated homepage HTML contains a fixed-color inline Logo value."
foreach ($nonHome in @(
  @{ Path = $article; Name = "article" },
  @{ Path = $about; Name = "About" },
  @{ Path = $posts; Name = "posts list" },
  @{ Path = $tags; Name = "tags index" },
  @{ Path = $term; Name = "tag term" },
  @{ Path = $notFound; Name = "404" }
)) {
  Assert-NotContains $nonHome.Path '<button\b[^>]*class=("|''|)?hero(?:\s|"|''|>)' "Hero poetry failure: $($nonHome.Name) rendered the homepage-only Hero."
  Assert-NotContains $nonHome.Path 'hero-poetry-data|poetry\.palemoky\.com' "Hero poetry failure: $($nonHome.Name) contains the homepage-only poetry data or API script."
}
Assert-NotContains $css '\.inky-' "Hero poetry failure: obsolete inky component CSS remains."
Assert-NotContains $baseof 'inky-overlay|hero-beauty|heroImage' "Hero poetry failure: base template still references the old image system."
Assert-Contains $baseof '(?s)if\s+\.IsHome.*partial\s+"hero-poetry-script\.html"' "Hero poetry failure: poetry interaction script is not scoped to the homepage."
Assert-Contains $heroScript 'addEventListener\(''click'',\s*requestPoem\)' "Hero poetry failure: Hero activation is not bound to the native button click seam."
Assert-Contains $heroScript 'prefers-reduced-motion:\s*reduce' "Hero poetry failure: runtime interaction does not honor reduced motion."
Assert-Contains $heroScript 'AbortController' "Hero poetry failure: remote poetry requests have no timeout controller."
Assert-Contains $heroScript 'normalizePoem' "Hero poetry failure: remote API responses are not isolated behind an adapter."
Assert-Contains $heroScript 'is-fetching' "Hero poetry failure: the interaction has no visible pending state."
Assert-Contains $heroScript 'is-ink-rising' "Hero poetry failure: the interaction has no immediate double-wing ink state."
Assert-Contains $heroScript 'getBoundingClientRect' "Hero poetry failure: border geometry is not based on the rendered Hero size."
Assert-Contains $heroScript 'ResizeObserver' "Hero poetry failure: border geometry has no responsive resize observer."
Assert-Contains $heroScript 'viewBox' "Hero poetry failure: the SVG viewBox is not synchronized with Hero dimensions."
Assert-Contains $heroScript 'setAttribute\(''d''' "Hero poetry failure: the SVG border paths are not generated from measured geometry."
Assert-NotContains $heroScript 'glowLeft|glowRight|hero__stroke-glow' "Hero poetry failure: the short glow path is still wired into the Hero script."
Assert-Contains $heroScript '(?s)var requestPoem\s*=.*?beginFeedback\(\).*?window\.fetch' "Hero poetry failure: visual feedback does not begin before the remote request."
Assert-Contains $heroScript '(?s)var finish\s*=.*?classList\.remove\(''is-fetching''\)' "Hero poetry failure: the pending state is not cleared after the poem reveal."
Assert-NotContains $heroScript 'mouse(?:enter|over|move)' "Hero poetry failure: hover unexpectedly triggers JavaScript or API behavior."
Assert-Contains $css '(?s)@media\s*\(hover:\s*hover\).*?\.hero:hover' "Hero poetry failure: pointer hover feedback is not capability-gated."
Assert-Contains $css '(?s)@media\s*\(prefers-reduced-motion:\s*reduce\).*?\.hero__stroke' "Hero poetry failure: Hero animation has no reduced-motion CSS fallback."
Assert-Contains $css '\.hero__stroke-line' "Hero poetry failure: double-wing core line styles are missing."
Assert-Contains $css '@keyframes\s+hero-ink-rise' "Hero poetry failure: the rising ink animation is missing."
Assert-Contains $css 'stroke-dashoffset' "Hero poetry failure: the border trace does not animate its stroke offset."
Assert-Contains $css '760ms' "Hero poetry failure: the closed border trace does not use the approved duration."
Assert-NotContains $css 'hero-ink-(?:rise|glow)[^}]*infinite' "Hero poetry failure: the border trace must not loop continuously."
Assert-NotContains $css 'hero__stroke-glow|hero-ink-glow|stroke-dasharray\s*:\s*\.08\s+\.92' "Hero poetry failure: the short glow animation still exists."
Assert-Contains $css '(?s)\.hero__stroke-line\s*\{[^}]*stroke:\s*var\(--cinnabar\)' "Hero poetry failure: the double-wing line does not use the cinnabar token."
Assert-NotContains $css '@keyframes\s+hero-ink-stroke' "Hero poetry failure: the obsolete horizontal ink-stroke animation remains."
Assert-NotContains $designDoc '短光头|光晕只播放一次' "Documentation failure: DESIGN.md still promises the removed short glow effect."
Assert-NotContains $releaseChecklist '短光头|光晕' "Documentation failure: release checklist still promises the removed short glow effect."

# Catalog summaries: respect Hugo summary semantics before falling back to metadata description.
Assert-Contains $summarySource '(?s)\.Summary.*?\.Description' "Summary failure: Hugo .Summary must take precedence over .Description."
Assert-NotContains $summarySource 'findRE\s+"<p' "Summary failure: the theme still limits previews to the first paragraph."
Assert-HasLongCatalogSummary $homePage 60 "Summary failure: homepage previews are still limited to short single-sentence descriptions."

# P2 Task 3: generated-output accessibility and localization contracts.
$pages = @(
  @{ Path = $homePage; Name = "homepage" },
  @{ Path = $article; Name = "article" },
  @{ Path = $posts; Name = "posts list" },
  @{ Path = $tags; Name = "tags index" },
  @{ Path = $term; Name = "tag term" },
  @{ Path = $about; Name = "About" },
  @{ Path = $notFound; Name = "404" }
)
foreach ($page in $pages) {
  Assert-Contains $page.Path '<html\b[^>]*\blang=("|''|)?[^"''>\s]+' "P2 failure: $($page.Name) is missing a non-empty html lang attribute."
  Assert-Contains $page.Path 'class=("|''|)?skip-link("|''|)?[^>]*href=("|''|)?#main-content' "P2 failure: $($page.Name) is missing the skip link to #main-content."
  Assert-Contains $page.Path '<main\b[^>]*\bid=("|''|)?main-content("|''|)?[^>]*\btabindex=("|''|)?-1' "P2 failure: $($page.Name) is missing the focusable main landmark."
  Assert-Contains $page.Path 'class=("|''|)?theme-toggle("|''|)?[^>]*\baria-label=("|''|)?[^"''>\s]+' "P2 failure: $($page.Name) theme button is missing aria-label."
  Assert-Contains $page.Path 'class=("|''|)?theme-toggle("|''|)?[^>]*\baria-pressed=("|''|)?(true|false)' "P2 failure: $($page.Name) theme button is missing aria-pressed."
  Assert-ExternalTargetsSafe $page.Path "P2 failure: $($page.Name) has an unsafe target=_blank link."
  Assert-ImagesHaveAlt $page.Path "P2 failure: $($page.Name) has an image without alt text."
}
Assert-NotContains $css 'writing-mode\s*:\s*vertical-rl' "P2 failure: vertical writing mode remains in the runtime stylesheet."
Assert-Contains $baseof 'i18n\s+"site_navigation"' "P2 failure: navigation label is not sourced from i18n."
Assert-Contains $langPartial 'i18n\s+"language"' "P2 failure: language switcher label is not sourced from i18n."
Assert-Contains $headingHook 'i18n\s+"heading_anchor"' "P2 failure: heading anchor label is not sourced from i18n."

$requiredI18nKeys = @(
  "home", "posts", "about", "prev", "back", "next", "read_more", "tag", "tags",
  "date_format", "reading_time", "no_posts", "skip_to_content", "toggle_theme",
  "site_navigation", "language", "heading_anchor", "hero_poetry_label", "tag_count", "notfound_msg", "notfound_hint"
)
foreach ($locale in @("zh-cn", "en", "ja")) {
  $localePath = Join-Path $repoRoot "i18n\$locale.toml"
  foreach ($key in $requiredI18nKeys) {
    Assert-Contains $localePath ("(?m)^\[" + [regex]::Escape($key) + "\]") "P2 failure: i18n/$locale.toml is missing [$key]."
  }
}

Assert-Contains $article "katex\.min\.css" "P1 failure: page-level math did not load KaTeX on the math fixture."
Assert-Contains $article 'property="og:description"' "P1 failure: shared summary source did not produce an article description."
Assert-Contains $posts 'catalog-summary>[^<\s]' "P1 failure: catalog summaries are empty."
Assert-Contains $article 'href=("|''|)?https://gohugo\.io[^>]*target=("|''|)?_blank' "P1 failure: external links are not marked to open safely in a new tab."
Assert-Contains $article 'data-kind=("|''|)?hook' "P1 failure: heading attributes were dropped by the render hook."
Assert-Contains $article 'href=("|''|)?//example\.org[^>]*target=("|''|)?_blank[^>]*>协议相对链接' "P1 failure: protocol-relative external links are not marked safely."
Assert-Contains $article 'href=#>不安全链接' "P1 failure: unsafe link schemes were not neutralized."
Assert-NotContains $article 'href=("|''|)?/posts/paper-and-ink/[^>]*target=' "P1 failure: internal links were incorrectly marked as external."

foreach ($page in @($homePage, $article)) {
  Assert-Contains $page 'property="og:image"' "P1 failure: missing default og:image in $page."
  Assert-Contains $page 'name=("|''|)?twitter:image' "P1 failure: missing default twitter:image in $page."
}

Assert-NotContains $about 'property="article:published_time"' "P1 failure: undated About page emitted article:published_time."
Assert-Contains $posts '<h1>文章</h1>' "P1 failure: posts list heading is not localized to 文章."
Assert-Contains $tags '<h1>标签</h1>' "P1 failure: tags list heading is not localized to 标签."
Assert-NotContains $article 'background-color:#272822' "P1 failure: generated code still contains the fixed Monokai background inline style."
Assert-NotContains $article 'color:#f8f8f2' "P1 failure: generated code still contains the fixed Monokai foreground inline style."
Assert-NotContains $article 'color:#f92672' "P1 failure: generated code still contains the fixed Monokai keyword color inline style."

Write-Output "P1/P2 smoke checks passed."
