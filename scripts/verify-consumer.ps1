$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$consumerSite = Join-Path $repoRoot "scripts\fixtures\consumer-site"
$consumerConfig = Join-Path $consumerSite "hugo.yaml"
$legacyConsumerConfig = Join-Path $consumerSite "hugo.toml"
$out = Join-Path ([System.IO.Path]::GetTempPath()) "inyo-consumer-verify-$PID"
$subpathOut = Join-Path ([System.IO.Path]::GetTempPath()) "inyo-consumer-subpath-verify-$PID"
$archetypeSmoke = Join-Path $consumerSite "content\notes\archetype-smoke.md"
$seriesArchetypeDir = Join-Path $consumerSite "content\notes\archetype-series"
$seriesArchetypeSmoke = Join-Path $seriesArchetypeDir "_index.md"
$archetypeClock = "2026-08-12T12:00:00Z"
$createdArchetypeSmoke = $false
$createdSeriesArchetypeSmoke = $false
$resolvedSeriesArchetypeDir = $null

function Assert-Contains($Path, $Pattern, $Message) {
  $text = Get-Content -Raw $Path
  if ($text -notmatch $Pattern) { throw $Message }
}

function Assert-NotContains($Path, $Pattern, $Message) {
  $text = Get-Content -Raw $Path
  if ($text -match $Pattern) { throw $Message }
}

function Assert-MatchCount($Path, $Pattern, $Expected, $Message) {
  $text = Get-Content -Raw $Path
  $actual = [regex]::Matches($text, $Pattern).Count
  if ($actual -ne $Expected) { throw "$Message Expected $Expected, got $actual." }
}

function Assert-InOrder($Path, $Patterns, $Message) {
  $text = Get-Content -Raw $Path
  $position = 0
  foreach ($pattern in $Patterns) {
    $match = [regex]::Match($text, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline, [TimeSpan]::FromSeconds(1))
    if (-not $match.Success -or $match.Index -lt $position) { throw $Message }
    $position = $match.Index + $match.Length
    $text = $text.Substring($position)
    $position = 0
  }
}

function Assert-FileExists($Path, $Message) {
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw $Message }
}

function Assert-FileMissing($Path, $Message) {
  if (Test-Path -LiteralPath $Path) { throw $Message }
}

Assert-FileExists $consumerConfig "Consumer failure: fixture hugo.yaml is missing."
Assert-FileMissing $legacyConsumerConfig "Consumer failure: fixture hugo.toml must be removed after the YAML migration."
Assert-Contains $consumerConfig '(?ms)^module:\s*\r?\n\s{2}imports:\s*\r?\n\s{4}-\s*path:\s*"github\.com/FeiNiaoBF/hugo-theme-inyo"\s*$' "Consumer failure: YAML fixture is missing the module import."
Assert-Contains $consumerConfig '(?m)^mainSections:\s*\r?\n\s{2}-\s*"notes"\s*$' "Consumer failure: YAML fixture must use notes as its main section."
Assert-Contains $consumerConfig '(?ms)^taxonomies:\s*\r?\n\s{2}tag:\s*"labels"\s*$' "Consumer failure: YAML fixture must use labels as its tag taxonomy."
Assert-Contains $consumerConfig '(?ms)^params:\s*.*?^\s{2}taxonomy:\s*\r?\n\s{4}tag:\s*"labels"\s*$' "Consumer failure: params.taxonomy.tag must identify the labels taxonomy."
Assert-Contains $consumerConfig '(?ms)^markup:\s*.*?^\s{2}_merge:\s*"deep"\s*$' "Consumer failure: markup must deep-merge theme Chroma defaults."

$fixtureContent = @(
  (Join-Path $consumerSite "content\_index.md"),
  (Join-Path $consumerSite "content\about.md"),
  (Join-Path $consumerSite "content\labels\_index.md"),
  (Join-Path $consumerSite "content\notes\_index.md"),
  (Join-Path $consumerSite "content\notes\smoke.md"),
  (Join-Path $consumerSite "content\notes\series-smoke\_index.md"),
  (Join-Path $consumerSite "content\notes\series-smoke\weighted-first.md"),
  (Join-Path $consumerSite "content\notes\series-smoke\weighted-second.md"),
  (Join-Path $consumerSite "content\notes\series-smoke\unweighted-new.md"),
  (Join-Path $consumerSite "content\notes\series-smoke\unweighted-old.md"),
  (Join-Path $consumerSite "content\notes\solo-series\_index.md"),
  (Join-Path $consumerSite "content\notes\solo-series\only.md")
)
foreach ($contentPath in $fixtureContent) {
  Assert-FileExists $contentPath "Consumer failure: fixture content file is missing."
  Assert-Contains $contentPath '(?s)^---\r?\n.*?\r?\n---\r?\n' "Consumer failure: $contentPath must use YAML front matter."
  Assert-NotContains $contentPath '(?m)^\+\+\+$' "Consumer failure: $contentPath must not use TOML front matter."
}

try {
  & hugo --source $consumerSite --destination $out --minify --printPathWarnings --noBuildLock
  if ($LASTEXITCODE -ne 0) { throw "Consumer failure: Hugo build exited with code $LASTEXITCODE." }

  $homePage = Join-Path $out "index.html"
  $notes = Join-Path $out "notes\index.html"
  $article = Join-Path $out "notes\smoke\index.html"
  $seriesOverview = Join-Path $out "notes\series-smoke\index.html"
  $seriesArticle = Join-Path $out "notes\series-smoke\weighted-second\index.html"
  $soloSeriesOverview = Join-Path $out "notes\solo-series\index.html"
  $labels = Join-Path $out "labels\index.html"
  $labelTerm = Join-Path $out "labels\portability\index.html"
  $about = Join-Path $out "about\index.html"
  $notFound = Join-Path $out "404.html"

  foreach ($output in @(
    @{ Path = $homePage; Name = "homepage" },
    @{ Path = $notes; Name = "notes section" },
    @{ Path = $article; Name = "article" },
    @{ Path = $seriesOverview; Name = "series overview" },
    @{ Path = $seriesArticle; Name = "series article" },
    @{ Path = $soloSeriesOverview; Name = "solo series overview" },
    @{ Path = $labels; Name = "labels taxonomy" },
    @{ Path = $labelTerm; Name = "portability label term" },
    @{ Path = $about; Name = "About page" },
    @{ Path = $notFound; Name = "404 page" }
  )) {
    Assert-FileExists $output.Path "Consumer failure: generated $($output.Name) is missing."
  }

  Assert-Contains $homePage 'href=("|'')?/notes/' "Consumer failure: homepage navigation does not link to /notes/."
  Assert-Contains $homePage 'href=("|'')?/labels/' "Consumer failure: homepage navigation does not link to /labels/."
  Assert-Contains $homePage 'href=("|'')?/about/' "Consumer failure: homepage navigation does not link to /about/."
  Assert-NotContains $homePage 'href=("|'')?/posts/' "Consumer failure: homepage still contains a hard-coded /posts/ link."
  Assert-Contains $homePage '<meta\s+name=("|'')?description[^>]*content=("|'')?A clean consumer site used to verify Inyo portability\.' "Consumer failure: homepage description fallback is missing."
  Assert-Contains $homePage 'property=("|'')?og:image[^>]*seal-yang-og\.png' "Consumer failure: homepage does not use the PNG social image."
  Assert-Contains $notes '<a\b[^>]*href=("|'')?/notes/[^>]*aria-current=("|'')?page' "Consumer failure: current section navigation is missing aria-current."
  Assert-Contains $article 'content=("|'')?An independent article description used by the consumer fixture\.' "Consumer failure: article description does not override the site fallback."
  Assert-Contains $article 'class=("|'')?tag("|'')?[^>]*href=("|'')?/labels/portability/' "Consumer failure: article tag links do not use the configured labels taxonomy."
  Assert-Contains $article 'class=("|'')?chroma("|'')?' "Consumer failure: fenced code did not use class-based Chroma markup."
  Assert-NotContains $article '#272822|#f8f8f2|#f92672' "Consumer failure: fenced code contains inline Monokai colors."
  Assert-Contains $article 'class=("|'')?post-single\b' "Post layout failure: an article without layout must use the default post rendering."
  Assert-NotContains $article 'class=("|'')?series-context\b' "Post layout failure: an ordinary article must not render series context."
  Assert-NotContains $article 'class=("|'')?[^>]*\bpost-nav--series\b' "Post layout failure: an ordinary article must not use the series navigation modifier."
  Assert-Contains $labels 'href=("|'')?/labels/portability/' "Consumer failure: labels taxonomy does not link to the generated portability term."
  Assert-Contains $labels 'class=("|'')?tag-cloud' "Consumer failure: configured labels taxonomy must use the editorial tag cloud layout."
  Assert-NotContains $article 'href=("|'')?/tags/portability/' "Consumer failure: article tag links still use the hard-coded tags taxonomy."
  Assert-Contains $notFound 'href=("|'')?/notes/' "Consumer failure: 404 article entry does not use the configured notes section."
  Assert-NotContains $notFound 'href=("|'')?/posts/' "Consumer failure: 404 article entry still uses the hard-coded posts section."
  Assert-MatchCount $homePage 'href=("|'')?/notes/series-smoke/' 1 "Series failure: homepage must contain one series entry."
  Assert-MatchCount $notes 'href=("|'')?/notes/series-smoke/' 1 "Series failure: notes list must contain one series entry."
  $seriesAnchor = '(?s)<a\b(?=[^>]*class=("|'''')?catalog-series-link\b)(?=[^>]*href=("|'''')?/notes/series-smoke/)[^>]*>\s*<svg\b[^>]*class=("|'''')?series-icon\b[^>]*>.*?</svg>\s*<span\b[^>]*class=("|'''')?catalog-series-name\b[^>]*>Portable Systems Notes</span>\s*</a>'
  $seriesMeta = '(?s)<div\s+class=("|'''')?catalog-meta("|'''')?>\s*<span>4 articles</span>\s*<time\b[^>]*>Updated 2026-08-18</time>\s*</div>'
  Assert-Contains $homePage $seriesAnchor "Series failure: homepage series icon and name must share one overview link."
  Assert-Contains $notes $seriesAnchor "Series failure: notes series icon and name must share one overview link."
  Assert-Contains $homePage $seriesMeta "Series failure: homepage series metadata is missing or out of order."
  Assert-Contains $notes $seriesMeta "Series failure: notes series metadata is missing or out of order."
  Assert-NotContains $homePage 'href=("|'')?/notes/series-smoke/(?:weighted|unweighted)-' "Series failure: child articles leaked into the homepage catalog."
  Assert-NotContains $notes 'href=("|'')?/notes/series-smoke/(?:weighted|unweighted)-' "Series failure: child articles leaked into the main-section catalog."
  Assert-Contains $homePage '(?s)<section\b[^>]*class=("|'''')?catalog-group catalog-group--pinned\b[^>]*>.*?<a\b[^>]*href=("|'''')?/notes/series-smoke/' "Series failure: pinned series is not in the pinned group."
  Assert-Contains $homePage 'catalog-series-name("|'''')?>Solo Series' "Series failure: a one-article series is not cataloged as a series."
  Assert-Contains $notes 'catalog-series-name("|'''')?>Solo Series' "Series failure: the main-section catalog lost the one-article series."
  Assert-Contains $notes 'Updated 2026-08-09' "Series failure: a series without child lastmod must fall back to the child date."
  Assert-Contains $seriesOverview 'class=("|'')?series-overview\b' "Series overview failure: series-overview is missing."
  Assert-Contains $seriesOverview '(?s)<h1\b[^>]*class=("|'')?series-title\b[^>]*>\s*<svg\b[^>]*class=("|'')?series-icon\b[^>]*>.*?</svg>\s*<span>Portable Systems Notes</span>\s*</h1>' "Series overview failure: icon and title must share the H1."
  Assert-NotContains $seriesOverview 'class=("|'')?series-kicker\b' "Series overview failure: removed series kicker is still rendered."
  Assert-NotContains $seriesOverview 'class=("|'')?series-stats\b' "Series overview failure: removed count or update metadata is still rendered."
  Assert-NotContains $seriesOverview 'class=("|'')?catalog-meta\b' "Series overview failure: article date or reading time is still rendered."
  Assert-NotContains $seriesOverview 'class=("|'')?catalog-summary\b' "Series overview failure: article summary is still rendered."
  Assert-NotContains $seriesOverview 'class=("|'')?back-link\b' "Series overview failure: removed main-section return link is still rendered."
  Assert-MatchCount $seriesOverview 'class=("|'')?series-list-link\b' 4 "Series overview failure: each article must have one full-row link."
  Assert-Contains $seriesOverview '(?s)<a\b(?=[^>]*class=("|'')?series-list-link\b)(?=[^>]*href=("|'')?/notes/series-smoke/weighted-first/)[^>]*>\s*<span\b[^>]*class=("|'')?series-list-index\b[^>]*>01</span>\s*<span\b[^>]*class=("|'')?series-list-title\b[^>]*>Weighted First</span>\s*</a>' "Series overview failure: first row must link its number and title as one target."
  Assert-InOrder $seriesOverview @(
    '>Weighted First<',
    '>Weighted Second<',
    '>Unweighted Old<',
    '>Unweighted New<'
  ) "Series overview failure: articles are not in the required reading order."
  Assert-Contains $soloSeriesOverview 'class=("|'')?series-overview\b' "Series overview failure: solo series-overview is missing."
  Assert-MatchCount $soloSeriesOverview 'class=("|'')?series-list-link\b' 1 "Series overview failure: a one-article series must retain one full-row link."
  Assert-NotContains $soloSeriesOverview 'class=("|'')?[^>]*\bseries-introduction\b' "Series overview failure: an empty overview must not render an introduction wrapper."
  Assert-Contains $seriesArticle 'class=("|'')?post-single\b' "Post layout failure: a series article must use the shared post rendering."
  Assert-Contains $seriesArticle 'class=("|'')?series-context\b' "Series article failure: series context is missing."
  Assert-Contains $seriesArticle '<nav\b[^>]*class=("|'')?post-nav\s+post-nav--series\b' "Series article failure: series navigation must include the post-nav and post-nav--series classes."
  Assert-Contains $seriesArticle '(?s)<a\b[^>]*href=("|'')?/notes/series-smoke/[^>]*>\s*Portable Systems Notes\s*</a>' "Series article failure: series title does not link to its overview."
  Assert-Contains $seriesArticle '>2 of 4<' "Series article failure: localized reading progress is missing."
  Assert-Contains $seriesArticle '(?s)<a\b(?=[^>]*class=("|'')?back-link\b)(?=[^>]*href=("|'')?/notes/series-smoke/)[^>]*>\s*Back to “Portable Systems Notes”\s*</a>' "Series article failure: return link must include the series title."
  Assert-Contains $seriesArticle '(?s)<a\b[^>]*href=("|'')?/notes/series-smoke/weighted-first/[^>]*>[^<]*Weighted First[^<]*</a>' "Series article failure: previous navigation does not use the series reading order."
  Assert-Contains $seriesArticle '(?s)<a\b[^>]*href=("|'')?/notes/series-smoke/unweighted-old/[^>]*>[^<]*Unweighted Old[^<]*</a>' "Series article failure: next navigation does not use the series reading order."

  & hugo --source $consumerSite --destination $subpathOut --baseURL "https://consumer.example/blog/" --minify --printPathWarnings --noBuildLock
  if ($LASTEXITCODE -ne 0) { throw "Consumer subpath failure: Hugo build exited with code $LASTEXITCODE." }
  $subpathHome = Join-Path $subpathOut "index.html"
  $subpathArticle = Join-Path $subpathOut "notes\smoke\index.html"
  $subpathLabelTerm = Join-Path $subpathOut "labels\portability\index.html"
  Assert-FileExists $subpathHome "Consumer subpath failure: generated homepage is missing."
  Assert-FileExists $subpathArticle "Consumer subpath failure: generated article is missing."
  Assert-FileExists $subpathLabelTerm "Consumer subpath failure: generated portability label term is missing."
  Assert-Contains $subpathHome 'href=("|'')?/blog/css/[^>]*wenkai[^>]*\.css' "Consumer subpath failure: the prefixed Wenkai stylesheet is not referenced."
  Assert-MatchCount $subpathHome 'href=("|'')?/blog/notes/series-smoke/' 1 "Series subpath failure: homepage must contain one prefixed series entry."
  Assert-Contains $subpathHome '(?s)<a\b(?=[^>]*class=("|'''')?catalog-series-link\b)(?=[^>]*href=("|'''')?/blog/notes/series-smoke/)[^>]*>\s*<svg\b[^>]*class=("|'''')?series-icon\b[^>]*>.*?</svg>\s*<span\b[^>]*class=("|'''')?catalog-series-name\b[^>]*>Portable Systems Notes</span>\s*</a>' "Series subpath failure: icon and name must share one prefixed overview link."
  Assert-Contains $subpathHome $seriesMeta "Series subpath failure: series metadata is missing or out of order."
  Assert-NotContains $subpathHome 'href=("|'')?/blog/notes/series-smoke/(?:weighted|unweighted)-' "Series subpath failure: child articles leaked into the homepage catalog."
  Assert-Contains $subpathHome '(?s)<section\b[^>]*class=("|'''')?catalog-group catalog-group--pinned\b[^>]*>.*?<a\b[^>]*href=("|'''')?/blog/notes/series-smoke/' "Series subpath failure: pinned series is not in the pinned group."
  Assert-Contains $subpathHome 'catalog-series-name("|'''')?>Solo Series' "Series subpath failure: a one-article series is not cataloged as a series."
  Assert-NotContains $subpathHome 'href=("|'')?/notes/series-smoke/' "Series subpath failure: series link lost the /blog/ prefix."
  Assert-Contains $subpathArticle 'class=("|'')?tag("|'')?[^>]*href=("|'')?/blog/labels/portability/' "Consumer subpath failure: article label link lost the /blog/ prefix."
  $subpathWenkai = Get-ChildItem -LiteralPath (Join-Path $subpathOut "css") -Filter "*wenkai*.css" -File | Select-Object -First 1
  if (-not $subpathWenkai) { throw "Consumer subpath failure: generated Wenkai stylesheet is missing." }
  Assert-Contains $subpathWenkai.FullName 'url\(\.\./fonts/' "Consumer subpath failure: Wenkai font URLs are not relative."
  Assert-NotContains $subpathWenkai.FullName 'url\(/fonts/' "Consumer subpath failure: Wenkai font CSS still uses root-relative URLs."

  if (Test-Path -LiteralPath $archetypeSmoke) {
    throw "Archetype failure: fixture already contains notes/archetype-smoke.md."
  }

  & hugo new content notes/archetype-smoke.md --source $consumerSite --clock $archetypeClock --noBuildLock
  if ($LASTEXITCODE -ne 0) { throw "Archetype failure: hugo new content exited with code $LASTEXITCODE." }
  $createdArchetypeSmoke = $true
  Assert-FileExists $archetypeSmoke "Archetype failure: Hugo did not create the smoke article."
  Assert-Contains $archetypeSmoke '(?s)^---\r?\n.*?\r?\n---\r?\n' "Archetype failure: generated content must use YAML front matter."
  Assert-NotContains $archetypeSmoke '(?m)^\+\+\+$' "Archetype failure: generated content must not use TOML front matter."
  Assert-Contains $archetypeSmoke '(?m)^layout:\s*post\s*$' "Archetype failure: generated ordinary content must use post layout."
  foreach ($field in @("title", "date", "description", "summary", "draft", "math", "categories", "labels")) {
    Assert-Contains $archetypeSmoke ("(?m)^" + [regex]::Escape($field) + "\s*:") "Archetype failure: generated content is missing YAML field $field."
  }
  Assert-NotContains $archetypeSmoke '(?m)^tags\s*:' "Archetype failure: custom-taxonomy content still uses the default tags field."
  $generatedArchetypeText = Get-Content -Raw $archetypeSmoke
  $generatedDateMatch = [regex]::Match($generatedArchetypeText, '(?m)^date\s*:\s*(?<value>\S+)')
  if (-not $generatedDateMatch.Success) { throw "Archetype failure: generated content is missing a parseable date." }
  try {
    $generatedArchetypeDate = [DateTimeOffset]::Parse($generatedDateMatch.Groups["value"].Value, [Globalization.CultureInfo]::InvariantCulture)
    $expectedArchetypeDate = [DateTimeOffset]::Parse($archetypeClock, [Globalization.CultureInfo]::InvariantCulture)
  } catch {
    throw "Archetype failure: generated content did not use a valid ISO date."
  }
  if ($generatedArchetypeDate.ToUniversalTime().Ticks -ne $expectedArchetypeDate.ToUniversalTime().Ticks) {
    throw "Archetype failure: generated content did not preserve Hugo's dynamic date."
  }

  if (Test-Path -LiteralPath $seriesArchetypeDir) {
    throw "Archetype failure: fixture already contains notes/archetype-series."
  }
  & hugo new content --kind series notes/archetype-series/_index.md --source $consumerSite --clock $archetypeClock --noBuildLock
  $seriesArchetypeExitCode = $LASTEXITCODE
  if (Test-Path -LiteralPath $seriesArchetypeDir) {
    $resolvedSeriesArchetypeDir = (Resolve-Path -LiteralPath $seriesArchetypeDir).Path
    $expectedSeriesArchetypeDir = [System.IO.Path]::GetFullPath($seriesArchetypeDir)
    if (-not [System.StringComparer]::OrdinalIgnoreCase.Equals($resolvedSeriesArchetypeDir, $expectedSeriesArchetypeDir)) {
      throw "Archetype failure: generated series path escaped the exact fixture directory."
    }
    $createdSeriesArchetypeSmoke = $true
  }
  if ($seriesArchetypeExitCode -ne 0) { throw "Archetype failure: hugo new content --kind series exited with code $seriesArchetypeExitCode." }
  Assert-FileExists $seriesArchetypeSmoke "Archetype failure: Hugo did not create the series _index.md."
  Assert-Contains $seriesArchetypeSmoke '(?s)^---\r?\n.*?\r?\n---\r?\n' "Archetype failure: generated series must use YAML front matter."
  Assert-NotContains $seriesArchetypeSmoke '(?m)^\+\+\+$' "Archetype failure: generated series must not use TOML front matter."
  Assert-Contains $seriesArchetypeSmoke '(?m)^layout:\s*series\s*$' "Archetype failure: generated series must use series layout."
  Assert-Contains $seriesArchetypeSmoke '(?ms)^cascade:\s*\r?\n\s+layout:\s*post\s*$' "Archetype failure: generated series children must inherit post layout."

  Write-Output "Consumer and archetype checks passed."
} finally {
  if ($createdSeriesArchetypeSmoke -and $resolvedSeriesArchetypeDir -and (Test-Path -LiteralPath $resolvedSeriesArchetypeDir)) {
    $expectedSeriesArchetypeDir = [System.IO.Path]::GetFullPath($seriesArchetypeDir)
    if (-not [System.StringComparer]::OrdinalIgnoreCase.Equals($resolvedSeriesArchetypeDir, $expectedSeriesArchetypeDir)) {
      throw "Archetype cleanup failure: refusing to remove an unexpected path."
    }
    Remove-Item -LiteralPath $resolvedSeriesArchetypeDir -Recurse -Force
  }
  if ($createdArchetypeSmoke -and (Test-Path -LiteralPath $archetypeSmoke)) {
    Remove-Item -LiteralPath $archetypeSmoke -Force
  }
  if (Test-Path -LiteralPath $out) {
    Remove-Item -LiteralPath $out -Recurse -Force
  }
  if (Test-Path -LiteralPath $subpathOut) {
    Remove-Item -LiteralPath $subpathOut -Recurse -Force
  }
}
