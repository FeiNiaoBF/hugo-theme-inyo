$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$exampleSite = Join-Path $repoRoot "exampleSite"
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("inyo-theme-verify-" + [guid]::NewGuid().ToString("N"))
$out = Join-Path $tempRoot "demo"
$pagesOut = Join-Path $tempRoot "pages"
$multilingualOut = Join-Path $tempRoot "multilingual"

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

function Assert-FileNotEmpty($Path, $Message) {
  Assert-FileExists $Path $Message
  if ((Get-Item -LiteralPath $Path).Length -le 0) { throw $Message }
}

function Assert-PngDimensions($Path, $MinimumWidth, $MinimumHeight, $ExactWidth, $ExactHeight, $Message) {
  Assert-FileNotEmpty $Path $Message
  $bytes = [System.IO.File]::ReadAllBytes($Path)
  if ($bytes.Length -lt 24 -or $bytes[0] -ne 137 -or $bytes[1] -ne 80 -or $bytes[2] -ne 78 -or $bytes[3] -ne 71) {
    throw ($Message + " The file is not a valid PNG.")
  }
  $width = ([int]$bytes[16] -shl 24) -bor ([int]$bytes[17] -shl 16) -bor ([int]$bytes[18] -shl 8) -bor [int]$bytes[19]
  $height = ([int]$bytes[20] -shl 24) -bor ([int]$bytes[21] -shl 16) -bor ([int]$bytes[22] -shl 8) -bor [int]$bytes[23]
  if ($width -lt $MinimumWidth -or $height -lt $MinimumHeight) {
    throw ($Message + " Actual dimensions are " + $width + "x" + $height + ".")
  }
  if ($ExactWidth -gt 0 -and ($width -ne $ExactWidth -or $height -ne $ExactHeight)) {
    throw ($Message + " Expected " + $ExactWidth + "x" + $ExactHeight + ", got " + $width + "x" + $height + ".")
  }
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

function Get-CssTokenHex($CssText, $Selector, $Token) {
  $selectorPattern = [regex]::Escape($Selector)
  $block = [regex]::Match($CssText, "(?s)$selectorPattern\s*\{(?<body>.*?)\}")
  if (-not $block.Success) { throw "Color failure: CSS selector $Selector is missing." }
  $tokenPattern = "(?m)^\s*--" + [regex]::Escape($Token) + ":\s*(?<value>#[0-9A-Fa-f]{6})\s*;"
  $match = [regex]::Match($block.Groups["body"].Value, $tokenPattern)
  if (-not $match.Success) { throw "Color failure: $Selector does not define --$Token as a six-digit hex color." }
  return $match.Groups["value"].Value
}

function Get-RelativeLuminance($Hex) {
  $value = $Hex.TrimStart("#")
  $linear = foreach ($offset in @(0, 2, 4)) {
    $channel = [Convert]::ToInt32($value.Substring($offset, 2), 16) / 255
    if ($channel -le 0.04045) { $channel / 12.92 } else { [Math]::Pow(($channel + 0.055) / 1.055, 2.4) }
  }
  return 0.2126 * $linear[0] + 0.7152 * $linear[1] + 0.0722 * $linear[2]
}

function Assert-ContrastRatio($Foreground, $Background, $Minimum, $Expected, $Message) {
  $foregroundLuminance = Get-RelativeLuminance $Foreground
  $backgroundLuminance = Get-RelativeLuminance $Background
  $lighter = [Math]::Max($foregroundLuminance, $backgroundLuminance)
  $darker = [Math]::Min($foregroundLuminance, $backgroundLuminance)
  $ratio = ($lighter + 0.05) / ($darker + 0.05)
  if ($ratio -lt $Minimum -or [Math]::Round($ratio, 3) -ne $Expected) {
    throw "$Message Actual ratio: $([Math]::Round($ratio, 3)):1."
  }
}

$themeParamsConfig = Join-Path $repoRoot "config\_default\params.toml"
$themeMarkupConfig = Join-Path $repoRoot "config\_default\markup.toml"
$rootHugoConfig = Join-Path $repoRoot "hugo.toml"
$exampleConfig = Join-Path $exampleSite "hugo.yaml"
$legacyExampleConfig = Join-Path $exampleSite "hugo.toml"
$themeMetadata = Join-Path $repoRoot "theme.toml"
$themeScreenshot = Join-Path $repoRoot "images\screenshot.png"
$themeThumbnail = Join-Path $repoRoot "images\tn.png"
$socialImage = Join-Path $repoRoot "static\img\seal-yang-og.png"
$defaultArchetype = Join-Path $repoRoot "archetypes\default.md"
$consumerSite = Join-Path $repoRoot "scripts\fixtures\consumer-site"
$consumerConfig = Join-Path $consumerSite "hugo.yaml"
$legacyConsumerConfig = Join-Path $consumerSite "hugo.toml"
$consumerGoMod = Join-Path $consumerSite "go.mod"
$consumerVerifier = Join-Path $repoRoot "scripts\verify-consumer.ps1"
$workflow = Join-Path $repoRoot ".github\workflows\verify-theme.yml"
$officialBasicVerifier = Join-Path $repoRoot "scripts\verify-hugo-basic-example.ps1"
$headPartial = Join-Path $repoRoot "layouts\partials\head.html"
$baseof = Join-Path $repoRoot "layouts\_default\baseof.html"
$indexTemplate = Join-Path $repoRoot "layouts\index.html"
$singleTemplate = Join-Path $repoRoot "layouts\_default\single.html"
$notFoundTemplate = Join-Path $repoRoot "layouts\404.html"
$listTemplate = Join-Path $repoRoot "layouts\_default\list.html"
$archiveTemplate = Join-Path $repoRoot "layouts\archives\list.html"
$archiveContent = Join-Path $exampleSite "content\archives\_index.md"
$wenkaiCss = Join-Path $repoRoot "assets\css\wenkai.css"
$demoPosts = Join-Path $exampleSite "content\posts"
$aboutDoc = Join-Path $exampleSite "content\about.md"
$themeUsageDoc = Join-Path $demoPosts "theme-usage.md"
$heroPoemsData = Join-Path $repoRoot "data\inyo\hero_poems.toml"
$apiFixture = Join-Path $repoRoot "scripts\fixtures\chinese-poetry-api-random.json"
$multilingualOverlay = Join-Path $repoRoot "scripts\fixtures\multilingual-project.yaml"
$oldHeroPartial = Join-Path $repoRoot "layouts\partials\inky-overlay.html"
$oldHeroAsset = Join-Path $repoRoot "assets\img\hero-beauty.jpg"
$designDoc = Join-Path $repoRoot "DESIGN.md"
$readme = Join-Path $repoRoot "README.md"
$readmeEn = Join-Path $repoRoot "README.en.md"
$contributing = Join-Path $repoRoot "CONTRIBUTING.md"
$changelog = Join-Path $repoRoot "CHANGELOG.md"
$pagesWorkflow = Join-Path $repoRoot ".github\workflows\deploy-demo.yml"
$agentsDoc = Join-Path $repoRoot "AGENTS.md"
$piReadme = Join-Path $repoRoot ".pi\README.md"
$inyoSkill = Join-Path $repoRoot ".pi\skills\inyo-theme-development\SKILL.md"
$releaseSkill = Join-Path $repoRoot ".pi\skills\inyo-theme-release\SKILL.md"
$contentSkill = Join-Path $repoRoot ".pi\skills\inyo-content-authoring\SKILL.md"
$skillFiles = Get-ChildItem (Join-Path $repoRoot ".pi\skills") -Recurse -Filter "SKILL.md" -File

# P1 distribution contract: Hugo Themes metadata, preview assets, social image, and English onboarding.
Assert-FileExists $themeMetadata "Distribution failure: theme.toml is missing."
foreach ($field in @("name", "license", "licenselink", "description", "homepage", "tags", "features", "min_version")) {
  Assert-Contains $themeMetadata ("(?m)^" + [regex]::Escape($field) + "\s*=") "Distribution failure: theme.toml is missing $field."
}
Assert-Contains $themeMetadata '(?m)^min_version\s*=\s*"0\.164\.0"' "Distribution failure: theme.toml must require Hugo 0.164.0."
Assert-Contains $themeMetadata '(?m)^demosite\s*=\s*"https://FeiNiaoBF\.github\.io/hugo-theme-inyo/"' "Distribution failure: theme.toml must advertise the GitHub Pages demo."
Assert-Contains $rootHugoConfig '(?ms)^\[module\.hugoVersion\].*?^\s*extended\s*=\s*true' "Compatibility failure: root hugo.toml must declare Hugo Extended."
Assert-Contains $rootHugoConfig '(?ms)^\[module\.hugoVersion\].*?^\s*min\s*=\s*"0\.164\.0"' "Compatibility failure: root hugo.toml must require Hugo 0.164.0."
Assert-FileNotEmpty $themeScreenshot "Distribution failure: images/screenshot.png is missing or empty."
Assert-FileNotEmpty $themeThumbnail "Distribution failure: images/tn.png is missing or empty."
Assert-FileNotEmpty $socialImage "Distribution failure: static/img/seal-yang-og.png is missing or empty."
Assert-PngDimensions $themeScreenshot 900 600 0 0 "Distribution failure: theme screenshot must be at least 900x600."
Assert-PngDimensions $themeThumbnail 900 600 900 600 "Distribution failure: theme thumbnail must be exactly 900x600."
Assert-PngDimensions $socialImage 1200 630 1200 630 "Distribution failure: social image must be exactly 1200x630."
Assert-FileExists $readmeEn "Documentation failure: README.en.md is missing."
Assert-FileExists $contributing "Documentation failure: CONTRIBUTING.md is missing."
Assert-FileExists $changelog "Documentation failure: CHANGELOG.md is missing."
Assert-FileExists $pagesWorkflow "Pages failure: deploy-demo.yml is missing."
Assert-FileExists $officialBasicVerifier "Compatibility failure: HugoBasicExample verifier is missing."
Assert-FileExists $multilingualOverlay "Compatibility failure: multilingual project-site overlay is missing."
Assert-Contains $officialBasicVerifier 'github\.com/gohugoio/HugoBasicExample' "Compatibility failure: verifier must use the official HugoBasicExample repository."
Assert-Contains $readme 'hugo mod get github\.com/FeiNiaoBF/hugo-theme-inyo@latest' "Documentation failure: README.md must install the latest release."
Assert-Contains $readme 'README\.en\.md' "Documentation failure: README.md is missing the English README link."
Assert-Contains $readme '(?s)<h3\s+align="center">\s*<a\s+href="README\.en\.md">English</a>\s*</h3>' "Documentation failure: README.md must expose a centered, prominent English entry near the top."
Assert-Contains $readme 'CONTRIBUTING\.md' "Documentation failure: README.md is missing the contribution guide link."
Assert-Contains $readme 'CHANGELOG\.md' "Documentation failure: README.md is missing the changelog link."
Assert-Contains $readme 'FeiNiaoBF\.github\.io/hugo-theme-inyo' "Documentation failure: README.md is missing the GitHub Pages demo URL."
Assert-NotContains $readme '\]\(/posts/' "Documentation failure: README.md contains a deployment-only root-relative posts link."
Assert-Contains $readmeEn '(?m)^## Quick Start\s*$' "Documentation failure: README.en.md is missing the English Quick Start heading."
Assert-Contains $readmeEn 'hugo mod get github\.com/FeiNiaoBF/hugo-theme-inyo@latest' "Documentation failure: README.en.md must install the latest release."
Assert-Contains $readmeEn 'README\.md' "Documentation failure: README.en.md is missing the Chinese README link."
Assert-Contains $readmeEn '(?s)<h3\s+align="center">\s*<a\s+href="README\.md">中文</a>\s*</h3>' "Documentation failure: README.en.md must expose a centered Chinese entry near the top."
foreach ($publicReadme in @($readme, $readmeEn)) {
  Assert-Contains $publicReadme 'taxonomy:\s*\r?\n\s+tag:\s*"tags"' "Documentation failure: README configuration must document params.taxonomy.tag."
  Assert-Contains $publicReadme 'markup:\s*\r?\n\s+_merge:\s*"deep"' "Documentation failure: README configuration must preserve markup deep merge."
}
Assert-Contains $contributing 'scripts/verify-theme\.ps1' "Documentation failure: CONTRIBUTING.md is missing the theme verification command."
Assert-Contains $contributing 'zhongguo-traditional-colors' "Documentation failure: CONTRIBUTING.md is missing the acknowledgements section."
Assert-Contains $changelog '(?m)^## Unreleased\s*$' "Documentation failure: CHANGELOG.md is missing the Unreleased section."
Assert-Contains $changelog '(?m)^## v0\.1\.1' "Documentation failure: CHANGELOG.md is missing the v0.1.1 entry."
Assert-Contains $changelog '(?m)^## v0\.1\.0' "Documentation failure: CHANGELOG.md is missing the v0.1.0 entry."
Assert-Contains $pagesWorkflow 'actions/configure-pages@' "Pages failure: deploy-demo.yml must configure GitHub Pages."
Assert-Contains $pagesWorkflow 'actions/upload-pages-artifact@' "Pages failure: deploy-demo.yml must upload the Pages artifact."
Assert-Contains $pagesWorkflow 'actions/deploy-pages@' "Pages failure: deploy-demo.yml must deploy the Pages artifact."
Assert-Contains $pagesWorkflow 'pages:\s*write' "Pages failure: deploy-demo.yml is missing pages write permission."
Assert-Contains $pagesWorkflow 'id-token:\s*write' "Pages failure: deploy-demo.yml is missing OIDC permission."
Assert-Contains $pagesWorkflow 'steps\.pages\.outputs\.base_url' "Pages failure: deploy-demo.yml must use the GitHub Pages base URL."
Assert-Contains $pagesWorkflow '--baseURL' "Pages failure: deploy-demo.yml must pass a base URL to Hugo."
Assert-Contains $pagesWorkflow 'exampleSite/public' "Pages failure: deploy-demo.yml must publish exampleSite/public."
Assert-Contains $readme 'pwsh -File scripts/verify-consumer\.ps1' "Documentation failure: README.md is missing the consumer verification command."
Assert-Contains $workflow 'verify-hugo-basic-example\.ps1' "Compatibility failure: CI must run the official HugoBasicExample verifier."

# P1 runtime configuration contracts.
Assert-FileExists $exampleConfig "Example config failure: exampleSite/hugo.yaml is missing."
Assert-FileMissing $legacyExampleConfig "Example config failure: exampleSite/hugo.toml must be removed after the YAML migration."
Assert-Contains $themeParamsConfig '(?m)^description\s*=\s*""' "Config failure: theme defaults must expose an empty site description."
Assert-Contains $themeParamsConfig '(?m)^ogImage\s*=\s*"img/seal-yang-og\.png"' "SEO failure: the default social image must be the PNG asset."
Assert-Contains $themeParamsConfig '(?ms)^\[navigation\].*?^tags\s*=\s*"tags".*?^about\s*=\s*"about"' "Navigation failure: default configurable tags/about paths are missing."
Assert-Contains $themeParamsConfig '(?ms)^\[navigation\].*?^archives\s*=\s*"archives"' "Navigation failure: default configurable archive path is missing."
Assert-Contains $themeParamsConfig '(?ms)^\[taxonomy\]\s*^tag\s*=\s*"tags"' "Taxonomy failure: default taxonomy key is missing."
Assert-Contains $exampleConfig '(?m)^\s{2}description:\s*"[^"\r\n]+"\s*$' "SEO failure: exampleSite must provide a site description."
Assert-Contains $headPartial 'partial\s+"summary-source\.html"' "SEO failure: head.html must reuse summary-source.html."
Assert-Contains $headPartial 'site\.Params\.description' "SEO failure: head.html is missing the site description fallback."
Assert-Contains $headPartial 'site\.Params\.subtitle' "SEO failure: head.html is missing the subtitle fallback."
Assert-Contains $headPartial 'site\.Title' "SEO failure: head.html is missing the title fallback."
Assert-NotContains $baseof 'site\.GetPage\s+"/(?:posts|tags|about)"' "Navigation failure: baseof.html still hard-codes a navigation path."
Assert-Contains $baseof 'site\.Params\.mainSections' "Navigation failure: article navigation does not use mainSections."
Assert-Contains $baseof 'site\.Params\.navigation\.tags' "Navigation failure: tags navigation is not configurable."
Assert-Contains $baseof 'site\.Params\.navigation\.about' "Navigation failure: About navigation is not configurable."
Assert-Contains $baseof 'aria-current="page"' "Navigation failure: active navigation does not expose aria-current."
Assert-Contains $baseof '(?s)<nav class="identity-nav".*?i18n "about"' "Navigation failure: About must share the primary navigation style."
Assert-NotContains $baseof 'identity-aux' "Navigation failure: About must not use the smaller auxiliary navigation container."
Assert-Contains $baseof '<div class="identity-lockup">' "Responsive identity failure: brand and subtitle must share an identity lockup."
Assert-Contains $baseof '(?s)<div class="identity-toolbar">.*?<nav class="identity-nav".*?<div class="identity-meta">' "Responsive identity failure: navigation and controls must share one toolbar."
Assert-Contains $baseof '(?s)</aside>\s*<main class="content".*?</main>\s*<footer class="shell-footer">' "Responsive footer failure: the semantic footer must follow the main content."
Assert-NotContains $baseof 'identity-foot' "Responsive footer failure: footer content must not remain inside the identity rail."
Assert-Contains $singleTemplate 'site\.Params\.taxonomy\.tag' "Taxonomy failure: article terms must use the configured taxonomy key."
Assert-Contains $singleTemplate '\.GetTerms\s+\$tagTaxonomy' "Taxonomy failure: article terms must resolve through Hugo term pages."
Assert-Contains $singleTemplate '\.RelPermalink' "Taxonomy failure: article term links must use the term page permalink."
Assert-NotContains $singleTemplate '\|\s*urlize' "Taxonomy failure: article term links must not synthesize slugs with urlize."
Assert-NotContains $singleTemplate '"tags/"\s*\|\s*relLangURL' "Taxonomy failure: article term links still hard-code the tags path."
Assert-Contains $notFoundTemplate 'site\.Params\.mainSections' "Navigation failure: 404 article entry must use mainSections."
Assert-NotContains $notFoundTemplate '"posts/"\s*\|\s*relLangURL' "Navigation failure: 404 article entry still hard-codes the posts path."
Assert-Contains $listTemplate 'site\.Params\.mainSections' "Navigation failure: section heading detection must use mainSections."
Assert-FileExists $archiveTemplate "Archive failure: layouts/archives/list.html is missing."
Assert-Contains $archiveTemplate 'GroupByDate' "Archive failure: archive template must group articles by date."
Assert-FileExists $archiveContent "Archive failure: exampleSite/content/archives/_index.md is missing."
Assert-Contains $indexTemplate '(?s)pinned.*?latest|latest.*?pinned' "Homepage failure: pinned and latest collections are not both present."
Assert-Contains $indexTemplate 'Params\.pinned' "Homepage failure: homepage does not read the pinned front matter field."
Assert-Contains $wenkaiCss 'url\(''\.\./fonts/' "Asset failure: self-hosted font URLs must be relative to the generated CSS directory."
Assert-NotContains $wenkaiCss 'url\(''/fonts/' "Asset failure: self-hosted font CSS still assumes a root deployment path."

# P1 authoring and clean-consumer contracts.
Assert-FileExists $defaultArchetype "Archetype failure: archetypes/default.md is missing."
foreach ($field in @("title", "date", "description", "summary", "draft", "math", "categories")) {
  Assert-Contains $defaultArchetype ("(?m)^" + [regex]::Escape($field) + "\s*:") "Archetype failure: default.md is missing YAML field $field."
}
Assert-Contains $defaultArchetype 'site\.Params\.taxonomy\.tag\s*\|\s*default\s+"tags"' "Archetype failure: the tag field must follow the configured taxonomy key."
Assert-Contains $defaultArchetype '(?s)^---\r?\n.*?\r?\n---\r?\n' "Archetype failure: default.md must use YAML front matter."
Assert-NotContains $defaultArchetype '(?m)^\+\+\+$' "Archetype failure: default.md must not use TOML front matter."
Assert-NotContains $defaultArchetype 'hugo\.yaml|replacements\s*[:=]' "Archetype failure: default.md contains obsolete configuration syntax."
Assert-FileExists $consumerConfig "Consumer failure: fixture hugo.yaml is missing."
Assert-FileMissing $legacyConsumerConfig "Consumer failure: fixture hugo.toml must be removed after the YAML migration."
Assert-FileExists $consumerGoMod "Consumer failure: fixture go.mod is missing."
Assert-FileExists $consumerVerifier "Consumer failure: scripts/verify-consumer.ps1 is missing."
Assert-Contains $consumerConfig '(?ms)^params:\s*.*?^\s{2}mainSections:\s*\r?\n\s{4}-\s*"notes"\s*$' "Consumer failure: fixture must use notes as its main section."
Assert-Contains $consumerConfig '(?ms)^taxonomies:\s*\r?\n\s{2}tag:\s*"labels"\s*$' "Consumer failure: fixture must use labels as its tag taxonomy path."
Assert-Contains $consumerGoMod 'replace github\.com/FeiNiaoBF/hugo-theme-inyo => \../\../\..' "Consumer failure: fixture must use the committed ../../.. module replacement."
Assert-Contains $workflow 'scripts/verify-consumer\.ps1' "CI failure: consumer verification is not part of GitHub Actions."
Assert-Contains $themeParamsConfig '(?m)^font\s*=\s*"wenkai"' "Config failure: theme default params must define the wenkai font."
Assert-Contains $themeParamsConfig '(?m)^math\s*=\s*false' "Config failure: theme default params must disable math globally."
Assert-Contains $themeParamsConfig '(?m)^webfonts\s*=\s*true' "Config failure: theme default params must enable webfonts."
Assert-Contains $themeParamsConfig '(?m)^mainSections\s*=\s*\["posts"\]' "Config failure: theme default params must use posts as the main section."
Assert-Contains $themeParamsConfig '(?ms)^\[heroPoetry\.api\].*?^enabled\s*=\s*false' "Config failure: the theme must disable the remote poetry API by default."
Assert-Contains $themeParamsConfig '(?m)^endpoint\s*=\s*"https://poetry\.palemoky\.com/api/poems/random"' "Config failure: the theme must provide the current poetry API endpoint."
Assert-Contains $themeParamsConfig '(?m)^lang\s*=\s*"zh-Hans"' "Config failure: the theme must default the poetry API to simplified Chinese."
Assert-NotContains $themeParamsConfig '(?m)^heroImage(?:Quality)?\s*=' "Config failure: obsolete Hero image parameters remain in theme defaults."
Assert-Contains $exampleConfig '(?ms)^params:\s*.*?^\s{2}heroPoetry:\s*\r?\n\s{4}api:\s*\r?\n\s{6}enabled:\s*true\s*$' "Config failure: exampleSite must enable the optional poetry API."
Assert-Contains $exampleConfig '(?m)^baseURL:\s*"https://example\.com/"\s*$' "Example config failure: exampleSite must use the safe official demo base URL."
Assert-Contains $exampleConfig '(?m)^title:\s*"Inyo 陰陽"\s*$' "Example config failure: the site title is missing."
Assert-Contains $exampleConfig '(?m)^defaultContentLanguage:\s*"zh-cn"\s*$' "Example config failure: the default content language is missing."
Assert-Contains $exampleConfig '(?ms)^languages:\s*\r?\n\s{2}zh-cn:\s*.*?^\s{4}label:\s*"中文"\s*$' "Example config failure: the zh-cn language configuration is missing."
Assert-Contains $exampleConfig '(?ms)^module:\s*\r?\n\s{2}imports:\s*\r?\n\s{4}-\s*path:\s*"github\.com/FeiNiaoBF/hugo-theme-inyo"\s*$' "Example config failure: the Hugo Module import is missing."
foreach ($param in @('subtitle', 'author', 'font', 'webfonts', 'math', 'mainSections', 'ogImage', 'taxonomy', 'navigation', 'heroPoetry', 'social')) {
  Assert-Contains $exampleConfig ("(?m)^\s{2}" + [regex]::Escape($param) + ":") "Example config failure: Inyo parameter $param is missing."
}
Assert-Contains $exampleConfig '(?ms)^markup:\s*.*?^\s{2}_merge:\s*"deep"\s*$' "Example config failure: markup deep merge is missing."
Assert-Contains $exampleConfig '(?ms)^taxonomies:\s*\r?\n\s{2}category:\s*"categories"\s*\r?\n\s{2}tag:\s*"tags"\s*$' "Example config failure: the default blog taxonomies are not explicit."
Assert-NotContains $exampleConfig '(?m)^(?:outputs|sitemap|pagination|menus|services|privacy|timeZone|enableRobotsTXT|defaultContentLanguageInSubdir):' "Example config failure: unused Hugo configuration must not be active in the canonical YAML."
Assert-NotContains $exampleConfig '(?m)^\s*replace:' "Example config failure: local module replacements belong in go.mod, not hugo.yaml."
Assert-Contains $readme '创建或编辑 `hugo\.yaml`' "Documentation failure: README.md must use hugo.yaml as the canonical site configuration."
Assert-Contains $readmeEn 'Create or edit `hugo\.yaml`' "Documentation failure: README.en.md must use hugo.yaml as the canonical site configuration."
Assert-Contains $themeUsageDoc '站点的 `hugo\.yaml`' "Documentation failure: theme-usage.md must use hugo.yaml as the site configuration."
Assert-Contains $readme 'hugo new site my-inyo-site --format yaml' "Documentation failure: README.md must scaffold the site in the documented YAML format."
Assert-Contains $readmeEn 'hugo new site my-inyo-site --format yaml' "Documentation failure: README.en.md must scaffold the site in the documented YAML format."
Assert-Contains $themeUsageDoc 'hugo new site my-blog --format yaml' "Documentation failure: theme-usage.md must scaffold the site in the documented YAML format."
Assert-NotContains $readme '(?i)(?:创建或编辑|站点根目录创建或编辑).*hugo\.toml' "Documentation failure: README.md still presents hugo.toml as the user site configuration."
Assert-NotContains $readmeEn '(?i)create or edit `?hugo\.toml' "Documentation failure: README.en.md still presents hugo.toml as the user site configuration."
Assert-NotContains $themeUsageDoc '(?i)站点的 `?hugo\.toml|`hugo\.toml` 可以先保持简单' "Documentation failure: theme-usage.md still presents hugo.toml as the user site configuration."
$themeParamConsumers = @(
  @{ Name = "font"; Path = $headPartial; Pattern = 'site\.Params\.font' },
  @{ Name = "math"; Path = $headPartial; Pattern = 'site\.Params\.math' },
  @{ Name = "webfonts"; Path = $headPartial; Pattern = 'site\.Params\.webfonts' },
  @{ Name = "description"; Path = $headPartial; Pattern = 'site\.Params\.description' },
  @{ Name = "subtitle"; Path = $headPartial; Pattern = 'site\.Params\.subtitle' },
  @{ Name = "mainSections"; Path = $baseof; Pattern = 'site\.Params\.mainSections' },
  @{ Name = "ogImage"; Path = $headPartial; Pattern = 'site\.Params\.ogImage' },
  @{ Name = "taxonomy.tag"; Path = $singleTemplate; Pattern = 'site\.Params\.taxonomy\.tag' },
  @{ Name = "navigation.tags"; Path = $baseof; Pattern = 'site\.Params\.navigation\.tags' },
  @{ Name = "navigation.about"; Path = $baseof; Pattern = 'site\.Params\.navigation\.about' },
  @{ Name = "navigation.archives"; Path = $baseof; Pattern = 'site\.Params\.navigation\.archives' },
  @{ Name = "heroPoetry.api"; Path = $indexTemplate; Pattern = 'site\.Params\.heroPoetry\.api' }
)
foreach ($consumer in $themeParamConsumers) {
  Assert-Contains $consumer.Path $consumer.Pattern "Config failure: public parameter $($consumer.Name) has no template consumer."
}
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
Assert-Contains $exampleConfig '(?m)^\s{2}_merge:\s*"deep"\s*$' "Config failure: exampleSite must deep-merge its Goldmark settings with theme markup defaults."
Assert-Contains $consumerConfig '(?ms)^markup:\s*.*?^\s{2}_merge:\s*"deep"\s*$' "Consumer failure: fixture must preserve theme Chroma defaults with markup deep merge."
Assert-Contains $inyoSkill 'config/_default/params\.toml' "Skill failure: Inyo development skill is missing the theme default config contract."
Assert-Contains $inyoSkill 'scripts/verify-theme\.ps1' "Skill failure: Inyo development skill is missing the smoke verification command."
Assert-Contains $inyoSkill 'scripts/verify-consumer\.ps1' "Skill failure: Inyo development skill is missing the consumer verification command."
Assert-Contains $inyoSkill 'seal-yang-og\.png' "Skill failure: Inyo development skill is missing the PNG social image contract."
Assert-Contains $inyoSkill '0\.164\.0' "Skill failure: Inyo development skill is out of sync with the Hugo baseline."
Assert-Contains $inyoSkill '双翼墨线' "Skill failure: Inyo development skill is missing the current Hero motion contract."
Assert-Contains $inyoSkill '顶部中央' "Skill failure: Inyo development skill is missing the closed Hero border geometry."
Assert-Contains $inyoSkill '\.Summary' "Skill failure: Inyo development skill is missing the Hugo summary contract."
Assert-NotContains $inyoSkill 'seal-yin\.svg' "Skill failure: Inyo development skill references a nonexistent seal-yin.svg asset."
Assert-NotContains $inyoSkill 'verify-consumer\.yml' "Skill failure: Inyo development skill references a nonexistent consumer workflow."
Assert-FileExists $releaseSkill "Skill failure: Inyo release skill is missing."
Assert-Contains $releaseSkill 'scripts/verify-hugo-basic-example\.ps1' "Skill failure: Inyo release skill omits the official compatibility gate."
Assert-Contains $releaseSkill 'exampleSite/hugo\.yaml' "Skill failure: Inyo release skill omits the canonical Demo config."
Assert-NotContains $releaseSkill 'configuration-reference\.md' "Skill failure: Inyo release skill references a removed Demo document."
Assert-FileExists $contentSkill "Skill failure: Inyo content authoring skill is missing."
foreach ($demoName in @('theme-usage', 'markdown-basics', 'markdown-efficient', 'katex', 'faq', 'brand-design')) {
  Assert-Contains $contentSkill ([regex]::Escape($demoName + '.md')) "Skill failure: Inyo content authoring skill is missing $demoName.md."
}
Assert-Contains $contentSkill 'YAML.*---|---.*YAML' "Skill failure: Inyo content authoring skill omits the YAML front matter rule."
Assert-Contains $contentSkill '```shell' "Skill failure: Inyo content authoring skill omits the generic shell fence rule."
Assert-Contains $piReadme 'inyo-content-authoring' "Skill failure: .pi/README.md does not list the content authoring skill."
Assert-Contains $piReadme 'scripts/verify-hugo-basic-example\.ps1' "Skill failure: .pi/README.md omits the official compatibility gate."
Assert-Contains $designDoc '朱红双翼墨线' "Design failure: DESIGN.md is missing the accepted Hero motion direction."
Assert-Contains $designDoc '底部中央.*顶部中央' "Design failure: DESIGN.md does not describe the closed double-wing line geometry."
Assert-NotContains $designDoc '博客.*继续使用现有 `/posts/`' "Design failure: DESIGN.md still describes the configurable article section as fixed /posts/."
Assert-Contains $readme '贡献|CONTRIBUTING' "Documentation failure: README.md does not expose the contribution entry point."
Assert-Contains $readme '致谢与参考|Acknowledgements' "Documentation failure: README.md does not expose the acknowledgements section."
Assert-Contains $readme '圆角边框' "Documentation failure: README.md does not describe the Hero border interaction."
Assert-Contains $readme '(?m)^## 路线图\s*$' "Documentation failure: README.md is missing the maintained roadmap heading."
Assert-Contains $readmeEn '(?m)^## Roadmap\s*$' "Documentation failure: README.en.md is missing the matching roadmap section."
Assert-Contains $agentsDoc '双翼墨线' "Agent rules failure: AGENTS.md is missing the current Hero motion contract."
Assert-Contains $agentsDoc '顶部中央' "Agent rules failure: AGENTS.md is missing the closed Hero border geometry."
Assert-Contains $agentsDoc '\.Summary' "Agent rules failure: AGENTS.md is missing the Hugo summary contract."
Assert-Contains $agentsDoc '(?m)^## 文档同步矩阵\s*$' "Agent rules failure: AGENTS.md is missing the documentation synchronization matrix."
Assert-NotContains $agentsDoc 'git tag -a v0\.1\.2' "Agent rules failure: AGENTS.md hard-codes a stale next release tag."
Assert-Contains $changelog 'exampleSite/hugo\.yaml' "Documentation failure: CHANGELOG.md does not record the canonical Demo config migration."
Assert-Contains $changelog 'verify-hugo-basic-example\.ps1' "Documentation failure: CHANGELOG.md does not record the official compatibility gate."
foreach ($skillFile in $skillFiles) {
  Assert-NotContains $skillFile.FullName 'xxd-(?:ui-token|brand-system|palette-applier|print-packaging)' "Skill failure: $($skillFile.FullName) references a project skill that does not exist."
}

# Demo documentation contracts: keep the example site task-oriented and in sync with the current theme.
$demoDocs = @(
  @{ Name = "theme-usage"; Patterns = @('用 Inyo 写一篇文章', 'hugo mod get github\.com/FeiNiaoBF/hugo-theme-inyo@latest', 'pinned:\s*true') },
  @{ Name = "markdown-basics"; Patterns = @('Markdown 基础', 'data-kind="hook"', '双鱼印章图形') },
  @{ Name = "markdown-efficient"; Patterns = @('Markdown 高效写作', '<kbd>', 'javascript:alert') },
  @{ Name = "katex"; Patterns = @('把公式写进文章', 'math:\s*true', '\\begin\{aligned\}', '\\begin\{bmatrix\}') },
  @{ Name = "faq"; Patterns = @('常见问题', '这页暂时不急着填满') },
  @{ Name = "brand-design"; Patterns = @('纸、墨与朱红', '阅读先于功能', 'Hero 要有诗句') }
)
$expectedDemoNames = @($demoDocs | ForEach-Object { $_.Name } | Sort-Object)
$actualDemoNames = @(Get-ChildItem -LiteralPath $demoPosts -Filter "*.md" -File | ForEach-Object { $_.BaseName } | Sort-Object)
$demoNameDiff = @(Compare-Object -ReferenceObject $expectedDemoNames -DifferenceObject $actualDemoNames)
if ($demoNameDiff.Count -gt 0) {
  throw "Demo docs failure: exampleSite/content/posts must contain exactly: $($expectedDemoNames -join ', '). Actual: $($actualDemoNames -join ', ')."
}
$oldDemoNames = @(
  "configuration-reference", "customization", "front-matter", "getting-started",
  "markdown-style-guide", "paper-and-ink", "release-checklist", "showa-warmth", "theme-guide"
)
foreach ($oldDemoName in $oldDemoNames) {
  Assert-FileMissing (Join-Path $demoPosts ($oldDemoName + ".md")) "Demo docs failure: obsolete $oldDemoName.md still exists."
}
foreach ($demoDoc in $demoDocs) {
  $docPath = Join-Path $demoPosts ($demoDoc.Name + ".md")
  if (-not (Test-Path $docPath)) { throw "Demo docs failure: missing exampleSite/content/posts/$($demoDoc.Name).md." }
  Assert-Contains $docPath '(?s)^---\r?\n.*?\r?\n---\r?\n' "Demo docs failure: $($demoDoc.Name).md must use YAML front matter."
  Assert-NotContains $docPath '(?m)^\+\+\+$' "Demo docs failure: $($demoDoc.Name).md must not use TOML front matter."
  foreach ($field in @("title", "date", "description", "summary", "categories", "tags")) {
    Assert-Contains $docPath ("(?m)^" + [regex]::Escape($field) + "\s*:") "Demo docs failure: $($demoDoc.Name).md is missing YAML field $field."
  }
  foreach ($pattern in $demoDoc.Patterns) {
    Assert-Contains $docPath $pattern "Demo docs failure: $($demoDoc.Name).md is missing $pattern."
  }
  Assert-NotContains $docPath '<!--more-->' "Demo docs failure: $($demoDoc.Name).md contains a raw summary divider that shadows its front matter summary."
  Assert-Contains $docPath '## 下一步' "Demo docs failure: $($demoDoc.Name).md is missing its next-step navigation."
}
$userDocs = @($readme, $readmeEn, $contributing, $aboutDoc) + ($demoDocs | ForEach-Object { Join-Path $demoPosts ($_.Name + ".md") })
$maintainerDocs = @($changelog, $designDoc, $agentsDoc, $piReadme) + ($skillFiles | Select-Object -ExpandProperty FullName)
foreach ($docPath in ($userDocs + $maintainerDocs)) {
  Assert-NotContains $docPath '(?m)^~~~' "Documentation failure: $docPath uses tildes instead of fenced backticks."
  Assert-NotContains $docPath '(?m)^```(?:bash|powershell|pwsh)\s*$' "Documentation failure: $docPath must label generic command blocks as shell."
  Assert-NotContains $docPath 'exampleSite/hugo\.toml|consumer-site/hugo\.toml|configuration-reference\.md|verify-consumer\.yml' "Documentation failure: $docPath contains a retired active-project path."
}
$oldGuidePath = Join-Path $demoPosts "theme-guide.md"
if (Test-Path $oldGuidePath) { throw "Demo docs failure: obsolete theme-guide.md source file still exists." }
foreach ($stalePattern in @('0\.140\.0', 'languageName', 'replacements\s*[:=]')) {
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

try {
New-Item -ItemType Directory -Path $tempRoot | Out-Null
& hugo --source $exampleSite --minify --noBuildLock --destination $out
if ($LASTEXITCODE -ne 0) { throw "Demo build failure: Hugo exited with code $LASTEXITCODE." }

& hugo --source $exampleSite --baseURL "https://FeiNiaoBF.github.io/hugo-theme-inyo/" --minify --printPathWarnings --noBuildLock --destination $pagesOut
if ($LASTEXITCODE -ne 0) { throw "Pages build failure: Hugo exited with code $LASTEXITCODE." }

$multilingualConfig = "$exampleConfig,$multilingualOverlay"
& hugo --source $exampleSite --config $multilingualConfig --minify --printPathWarnings --noBuildLock --destination $multilingualOut
if ($LASTEXITCODE -ne 0) { throw "Multilingual project-site build failure: Hugo exited with code $LASTEXITCODE." }

$homePage = Join-Path $out "index.html"
$article = Join-Path $out "posts\katex\index.html"
$basicsArticle = Join-Path $out "posts\markdown-basics\index.html"
$efficientArticle = Join-Path $out "posts\markdown-efficient\index.html"
$themeUsage = Join-Path $out "posts\theme-usage\index.html"
$faqArticle = Join-Path $out "posts\faq\index.html"
$brandDesign = Join-Path $out "posts\brand-design\index.html"
$legacyGuide = Join-Path $out "posts\theme-guide\index.html"
$about = Join-Path $out "about\index.html"
$posts = Join-Path $out "posts\index.html"
$archives = Join-Path $out "archives\index.html"
$tags = Join-Path $out "tags\index.html"
$term = Join-Path $out "tags\inyo\index.html"
$notFound = Join-Path $out "404.html"
$pagesHomePage = Join-Path $pagesOut "index.html"
$pagesArticle = Join-Path $pagesOut "posts\theme-usage\index.html"
$pagesFeatureArticle = Join-Path $pagesOut "posts\markdown-basics\index.html"
$multilingualArticle = Join-Path $multilingualOut "zh-cn\posts\markdown-efficient\index.html"
$multilingualTarget = Join-Path $multilingualOut "zh-cn\posts\katex\index.html"
$multilingualFeatureArticle = Join-Path $multilingualOut "zh-cn\posts\markdown-basics\index.html"
$pagesCss = Get-ChildItem (Join-Path $pagesOut "css") -Filter "main*.css" -File | Select-Object -First 1
$pagesFontCss = Get-ChildItem (Join-Path $pagesOut "css") -Filter "wenkai*.css" -File | Select-Object -First 1
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
$linkHook = Join-Path $repoRoot "layouts\_default\_markup\render-link.html"

Assert-Contains $css '(?s)\.shell-footer\s*\{[^}]*grid-area:\s*footer;[^}]*border-top:\s*1px solid var\(--border\);' "Responsive footer failure: footer must be a full-width in-flow page footer with a top border."
Assert-Contains $css '(?s)\.identity-toolbar\s*\{[^}]*overflow-y:\s*auto;' "Responsive identity failure: the desktop toolbar must scroll within the identity rail."
Assert-Contains $css '(?s)@media\s*\(max-width:\s*1000px\).*?\.identity-nav a::after\s*\{[^}]*height:\s*2px;' "Responsive tablet failure: the 14em rail must use the reduced active underline."
Assert-Contains $css '(?s)@media\s*\(max-width:\s*768px\).*?grid-template-areas:\s*"identity"\s*"content"\s*"footer";' "Responsive mobile failure: footer must follow content in the document flow."
Assert-Contains $css '(?s)@media\s*\(min-width:\s*481px\)\s*and\s*\(max-width:\s*768px\).*?--responsive-gutter:\s*max\(1\.25em,\s*calc\(\(100% - var\(--container\)\) / 2 \+ 1\.25em\)\);' "Responsive tablet failure: the top identity area must share the 42em content axis."
Assert-Contains $css '(?s)\.theme-toggle\s*\{[^}]*width:\s*1\.75rem;[^}]*height:\s*1\.75rem;' "Responsive controls failure: the theme toggle target must remain 28 by 28 pixels."
Assert-Contains $css '(?s)@media\s*\(hover:\s*hover\).*?\.identity-nav a:hover::after' "Interaction failure: navigation underline hover must be gated by pointer capability."
Assert-Contains $css '(?s)@media\s*\(hover:\s*hover\).*?\.theme-toggle:hover' "Interaction failure: theme-toggle hover must be gated by pointer capability."
Assert-NotContains $css '(?s)\[data-theme="dark"\]\s+\.identity-nav a(?:::\w+|\.is-active)[^{]*\{[^}]*(?:display:\s*none|font-weight:\s*700)' "Navigation failure: dark mode must not change the active-state visual channel."
$cssText = Get-Content -Raw $css
$lightPaperRaised = Get-CssTokenHex $cssText ":root" "paper-2"
$lightLinkRaised = Get-CssTokenHex $cssText ":root" "link-raised"
$lightSyntaxKeyword = Get-CssTokenHex $cssText ":root" "syntax-keyword"
$darkPaperRaised = Get-CssTokenHex $cssText '[data-theme="dark"]' "paper-2"
$darkCodeBackground = Get-CssTokenHex $cssText '[data-theme="dark"]' "code-bg"
$darkLinkRaised = Get-CssTokenHex $cssText '[data-theme="dark"]' "link-raised"
$darkSyntaxKeyword = Get-CssTokenHex $cssText '[data-theme="dark"]' "syntax-keyword"
Assert-ContrastRatio $lightLinkRaised $lightPaperRaised 4.5 4.571 "Color failure: light raised-surface links must meet WCAG AA."
Assert-ContrastRatio $darkLinkRaised $darkPaperRaised 4.5 6.032 "Color failure: dark raised-surface links must meet WCAG AA."
Assert-ContrastRatio $darkSyntaxKeyword $darkCodeBackground 4.5 6.364 "Color failure: dark syntax keywords must meet WCAG AA."
if ($lightSyntaxKeyword -ne $lightLinkRaised -or $darkSyntaxKeyword -ne $darkLinkRaised) { throw "Color failure: syntax and raised-link roles must share the approved per-theme values." }
Assert-Contains $css '(?s)\.prose\s+a:not\(\.heading-anchor\)\s*\{[^}]*border-bottom:\s*1px\s+solid\s+currentColor;' "Accessibility failure: prose links need a persistent solid currentColor underline."
Assert-Contains $css '(?s)\.prose\s+blockquote\s+a\s*\{[^}]*color:\s*var\(--link-raised\);' "Color failure: raised-surface links must use --link-raised."
Assert-Contains $css '(?s)\.chroma\s+\.k,.*?\.chroma\s+\.kt\s*\{[^}]*color:\s*var\(--syntax-keyword\);' "Color failure: Chroma keywords must use --syntax-keyword."

foreach ($demoPage in @(
  @{ Path = $themeUsage; Name = "theme-usage" },
  @{ Path = $basicsArticle; Name = "markdown-basics" },
  @{ Path = $efficientArticle; Name = "markdown-efficient" },
  @{ Path = $article; Name = "katex" },
  @{ Path = $faqArticle; Name = "faq" },
  @{ Path = $brandDesign; Name = "brand-design" }
)) {
  if (-not (Test-Path $demoPage.Path)) { throw "Demo docs failure: generated page is missing $($demoPage.Name)." }
}
Assert-FileMissing $legacyGuide "Demo docs failure: obsolete theme-guide alias page was generated."
if (-not (Test-Path $archives)) { throw "Archive failure: generated /archives/ page is missing." }
Assert-Contains $archives '<h1>归档</h1>' "Archive failure: archive page heading is not localized."
Assert-Contains $archives '<h2[^>]*>20[0-9]{2}</h2>' "Archive failure: archive page does not contain a year group."

# P1 generated SEO and navigation contracts.
Assert-Contains $homePage '<meta\s+name=("|'')?description[^>]*content=("|'')?[^"''>\s]+' "SEO failure: homepage is missing a non-empty meta description."
Assert-Contains $homePage '<meta\s+property=("|'')?og:description[^>]*content=("|'')?[^"''>\s]+' "SEO failure: homepage is missing a non-empty Open Graph description."
Assert-Contains $homePage '<meta\s+name=("|'')?twitter:description[^>]*content=("|'')?[^"''>\s]+' "SEO failure: homepage is missing a non-empty Twitter description."
Assert-Contains $article '<meta\s+name=("|'')?description[^>]*content=("|'')?展示 Inyo 页面级 KaTeX 开关' "SEO failure: article metadata no longer prefers the page description."
Assert-Contains $homePage 'property=("|'')?og:image[^>]*seal-yang-og\.png' "SEO failure: homepage does not use the PNG social image."
Assert-Contains $posts '<a\b[^>]*href=("|'')?/posts/[^>]*aria-current=("|'')?page' "Navigation failure: the posts page does not expose aria-current."
Assert-Contains $posts '<h1>博客</h1>' "Navigation failure: the blog section heading is not localized to 博客."
Assert-Contains $archives '<a\b[^>]*href=("|'')?/archives/[^>]*aria-current=("|'')?page' "Navigation failure: the archive page does not expose aria-current."
Assert-Contains $homePage '(?s)<h2[^>]*>置顶文章</h2>.*?<h2[^>]*>最新文章</h2>' "Homepage failure: pinned articles do not appear before the latest article section."
Assert-Contains $homePage '(?s)<aside class=("|'')?identity("|'')?.*?</aside>\s*<main class=("|'')?content("|'')?.*?</main>\s*<footer class=("|'')?shell-footer("|'')?' "Responsive footer failure: rendered landmark order must be aside, main, then footer."
Assert-Contains $article 'class=("|'')?tag("|'')?[^>]*href=("|'')?/tags/[^>]+/' "Navigation failure: default article tag links do not use /tags/."
Assert-Contains $notFound 'href=("|'')?/posts/' "Navigation failure: default 404 does not link to /posts/."

# GitHub Pages project-site contract: generated URLs must retain the repository subpath.
if (-not $pagesCss) { throw "Pages failure: generated main CSS is missing from the project-site build." }
if (-not $pagesFontCss) { throw "Pages failure: generated WenKai CSS is missing from the project-site build." }
Assert-Contains $pagesHomePage 'https://FeiNiaoBF\.github\.io/hugo-theme-inyo/' "Pages failure: homepage canonical or metadata lost the project base URL."
Assert-Contains $pagesHomePage 'href=("|'')?/hugo-theme-inyo/css/' "Pages failure: homepage CSS link lost the project subpath."
Assert-Contains $pagesHomePage 'href=("|'')?/hugo-theme-inyo/posts/' "Pages failure: homepage article link lost the project subpath."
Assert-Contains $pagesHomePage 'href=("|'')?/hugo-theme-inyo/archives/' "Pages failure: homepage archive link lost the project subpath."
Assert-Contains $pagesArticle 'href=("|'')?/hugo-theme-inyo/(?:tags|about|posts)/' "Pages failure: article navigation lost the project subpath."
Assert-Contains $pagesArticle 'href=("|'')?/hugo-theme-inyo/index\.xml' "Pages failure: internal RSS link lost the project subpath."
Assert-Contains $pagesFeatureArticle 'src=("|'')?/hugo-theme-inyo/img/seal-yang\.svg' "Pages failure: Markdown image lost the project subpath."
Assert-NotContains $pagesHomePage 'href=("|'')?/(?:css|fonts|img|posts|tags|archives|about)/' "Pages failure: homepage contains a root-relative URL that bypasses the project subpath."
Assert-NotContains $pagesArticle 'href=("|'')?/(?:css|fonts|img|posts|tags|archives|about|index\.xml)/' "Pages failure: article page contains a root-relative URL that bypasses the project subpath."
Assert-NotContains $pagesFeatureArticle 'src=("|'')?/(?:img|fonts)/' "Pages failure: Markdown image contains a root-relative asset URL."
Assert-Contains $pagesFontCss.FullName 'url\(\s*(?:"|'')?\.\./fonts/' "Pages failure: WenKai CSS must resolve fonts relative to the generated CSS path."
Assert-NotContains $pagesFontCss.FullName 'url\(\s*(?:"|'')?/fonts/' "Pages failure: WenKai CSS contains an absolute root font URL."

# Multilingual project-site contract: authored page links retain both project and language prefixes.
Assert-Contains $linkHook 'strings\.TrimPrefix\s+"/"\s+\$destination\s*\|\s*relLangURL' "Multilingual failure: root-relative Markdown links must use relLangURL after removing the leading slash."
Assert-Contains $linkHook '\(not\s+\(hasPrefix\s+\$lowerDestination\s+"#"\)\)' "Multilingual failure: fragment-only links must bypass URL rewriting."
Assert-Contains $socialPartial 'strings\.TrimPrefix\s+"/"\s+\.url\s*\|\s*relLangURL' "Multilingual failure: ordinary internal social links must use relLangURL after removing the leading slash."
Assert-FileExists $multilingualArticle "Multilingual failure: source article was not generated under zh-cn."
Assert-FileExists $multilingualTarget "Multilingual failure: root-relative Markdown target was not generated under zh-cn."
Assert-FileExists $multilingualFeatureArticle "Multilingual failure: feature article was not generated under zh-cn."
Assert-Contains $multilingualArticle 'href=("|'')?/project/zh-cn/posts/katex/' "Multilingual failure: root-relative Markdown link lost the project or language prefix."
Assert-Contains $multilingualArticle '(?s)<p class=("|'')?rail-social[^>]*>.*?<a href=("|'')?/project/zh-cn/about/[^>]*>Social About</a>' "Multilingual failure: internal social link lost the project or language prefix."
Assert-Contains $multilingualArticle 'href=("|'')?//example\.org[^>]*target=("|'')?_blank' "Multilingual failure: protocol-relative external link behavior changed."
Assert-Contains $multilingualArticle 'href=("|'')?#%e5%85%88%e5%86%99%e9%a6%96%e9%a1%b5%e6%91%98%e8%a6%81' "Multilingual failure: fragment-only heading links changed unexpectedly."
Assert-Contains $multilingualFeatureArticle 'src=("|'')?/project/img/seal-yang\.svg' "Multilingual failure: static Markdown image incorrectly gained a language prefix."

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
  "home", "posts", "archives", "pinned", "latest", "about", "prev", "back", "next", "read_more", "tag", "tags",
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
Assert-Contains $basicsArticle 'href=("|''|)?https://gohugo\.io[^>]*target=("|''|)?_blank' "P1 failure: external links are not marked to open safely in a new tab."
Assert-Contains $basicsArticle 'data-kind=("|''|)?hook' "P1 failure: heading attributes were dropped by the render hook."
Assert-Contains $efficientArticle 'href=("|''|)?//example\.org[^>]*target=("|''|)?_blank[^>]*>协议相对链接' "P1 failure: protocol-relative external links are not marked safely."
Assert-Contains $efficientArticle 'href=#>不安全链接' "P1 failure: unsafe link schemes were not neutralized."
Assert-NotContains $efficientArticle 'href=("|''|)?/posts/katex/[^>]*target=' "P1 failure: internal links were incorrectly marked as external."

foreach ($page in @($homePage, $article)) {
  Assert-Contains $page 'property="og:image"' "P1 failure: missing default og:image in $page."
  Assert-Contains $page 'name=("|''|)?twitter:image' "P1 failure: missing default twitter:image in $page."
}

Assert-NotContains $about 'property="article:published_time"' "P1 failure: undated About page emitted article:published_time."
Assert-Contains $posts '<h1>博客</h1>' "P1 failure: posts list heading is not localized to 博客."
Assert-Contains $tags '<h1>标签</h1>' "P1 failure: tags list heading is not localized to 标签."
Assert-NotContains $article 'background-color:#272822' "P1 failure: generated code still contains the fixed Monokai background inline style."
Assert-NotContains $article 'color:#f8f8f2' "P1 failure: generated code still contains the fixed Monokai foreground inline style."
Assert-NotContains $article 'color:#f92672' "P1 failure: generated code still contains the fixed Monokai keyword color inline style."

Write-Output "P1/P2 smoke checks passed."
} finally {
  if (Test-Path -LiteralPath $tempRoot) {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force
  }
}
