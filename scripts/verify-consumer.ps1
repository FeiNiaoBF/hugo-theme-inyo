$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$consumerSite = Join-Path $repoRoot "scripts\fixtures\consumer-site"
$consumerConfig = Join-Path $consumerSite "hugo.yaml"
$legacyConsumerConfig = Join-Path $consumerSite "hugo.toml"
$out = Join-Path ([System.IO.Path]::GetTempPath()) "inyo-consumer-verify-$PID"
$subpathOut = Join-Path ([System.IO.Path]::GetTempPath()) "inyo-consumer-subpath-verify-$PID"
$archetypeSmoke = Join-Path $consumerSite "content\notes\archetype-smoke.md"
$createdArchetypeSmoke = $false

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

Assert-FileExists $consumerConfig "Consumer failure: fixture hugo.yaml is missing."
Assert-FileMissing $legacyConsumerConfig "Consumer failure: fixture hugo.toml must be removed after the YAML migration."
Assert-Contains $consumerConfig '(?ms)^module:\s*\r?\n\s{2}imports:\s*\r?\n\s{4}-\s*path:\s*"github\.com/FeiNiaoBF/hugo-theme-inyo"\s*$' "Consumer failure: YAML fixture is missing the module import."
Assert-Contains $consumerConfig '(?ms)^params:\s*.*?^\s{2}mainSections:\s*\r?\n\s{4}-\s*"notes"\s*$' "Consumer failure: YAML fixture must use notes as its main section."
Assert-Contains $consumerConfig '(?ms)^taxonomies:\s*\r?\n\s{2}tag:\s*"labels"\s*$' "Consumer failure: YAML fixture must use labels as its tag taxonomy."
Assert-Contains $consumerConfig '(?ms)^params:\s*.*?^\s{2}taxonomy:\s*\r?\n\s{4}tag:\s*"labels"\s*$' "Consumer failure: params.taxonomy.tag must identify the labels taxonomy."
Assert-Contains $consumerConfig '(?ms)^markup:\s*.*?^\s{2}_merge:\s*"deep"\s*$' "Consumer failure: markup must deep-merge theme Chroma defaults."

$fixtureContent = @(
  (Join-Path $consumerSite "content\_index.md"),
  (Join-Path $consumerSite "content\about.md"),
  (Join-Path $consumerSite "content\labels\_index.md"),
  (Join-Path $consumerSite "content\notes\_index.md"),
  (Join-Path $consumerSite "content\notes\smoke.md")
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
  $labels = Join-Path $out "labels\index.html"
  $labelTerm = Join-Path $out "labels\portability\index.html"
  $about = Join-Path $out "about\index.html"
  $notFound = Join-Path $out "404.html"

  foreach ($output in @(
    @{ Path = $homePage; Name = "homepage" },
    @{ Path = $notes; Name = "notes section" },
    @{ Path = $article; Name = "article" },
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
  Assert-Contains $labels 'href=("|'')?/labels/portability/' "Consumer failure: labels taxonomy does not link to the generated portability term."
  Assert-Contains $labels 'class=("|'')?tag-scroll' "Consumer failure: configured labels taxonomy must use the tag stamp layout."
  Assert-NotContains $article 'href=("|'')?/tags/portability/' "Consumer failure: article tag links still use the hard-coded tags taxonomy."
  Assert-Contains $notFound 'href=("|'')?/notes/' "Consumer failure: 404 article entry does not use the configured notes section."
  Assert-NotContains $notFound 'href=("|'')?/posts/' "Consumer failure: 404 article entry still uses the hard-coded posts section."

  & hugo --source $consumerSite --destination $subpathOut --baseURL "https://consumer.example/blog/" --minify --printPathWarnings --noBuildLock
  if ($LASTEXITCODE -ne 0) { throw "Consumer subpath failure: Hugo build exited with code $LASTEXITCODE." }
  $subpathHome = Join-Path $subpathOut "index.html"
  $subpathArticle = Join-Path $subpathOut "notes\smoke\index.html"
  $subpathLabelTerm = Join-Path $subpathOut "labels\portability\index.html"
  Assert-FileExists $subpathHome "Consumer subpath failure: generated homepage is missing."
  Assert-FileExists $subpathArticle "Consumer subpath failure: generated article is missing."
  Assert-FileExists $subpathLabelTerm "Consumer subpath failure: generated portability label term is missing."
  Assert-Contains $subpathHome 'href=("|'')?/blog/css/[^>]*wenkai[^>]*\.css' "Consumer subpath failure: the prefixed Wenkai stylesheet is not referenced."
  Assert-Contains $subpathArticle 'class=("|'')?tag("|'')?[^>]*href=("|'')?/blog/labels/portability/' "Consumer subpath failure: article label link lost the /blog/ prefix."
  $subpathWenkai = Get-ChildItem -LiteralPath (Join-Path $subpathOut "css") -Filter "*wenkai*.css" -File | Select-Object -First 1
  if (-not $subpathWenkai) { throw "Consumer subpath failure: generated Wenkai stylesheet is missing." }
  Assert-Contains $subpathWenkai.FullName 'url\(\.\./fonts/' "Consumer subpath failure: Wenkai font URLs are not relative."
  Assert-NotContains $subpathWenkai.FullName 'url\(/fonts/' "Consumer subpath failure: Wenkai font CSS still uses root-relative URLs."

  if (Test-Path -LiteralPath $archetypeSmoke) {
    throw "Archetype failure: fixture already contains notes/archetype-smoke.md."
  }

  & hugo new content notes/archetype-smoke.md --source $consumerSite --clock "2026-08-12T00:00:00+08:00" --noBuildLock
  if ($LASTEXITCODE -ne 0) { throw "Archetype failure: hugo new content exited with code $LASTEXITCODE." }
  $createdArchetypeSmoke = $true
  Assert-FileExists $archetypeSmoke "Archetype failure: Hugo did not create the smoke article."
  Assert-Contains $archetypeSmoke '(?s)^---\r?\n.*?\r?\n---\r?\n' "Archetype failure: generated content must use YAML front matter."
  Assert-NotContains $archetypeSmoke '(?m)^\+\+\+$' "Archetype failure: generated content must not use TOML front matter."
  foreach ($field in @("title", "date", "description", "summary", "draft", "math", "categories", "labels")) {
    Assert-Contains $archetypeSmoke ("(?m)^" + [regex]::Escape($field) + "\s*:") "Archetype failure: generated content is missing YAML field $field."
  }
  Assert-NotContains $archetypeSmoke '(?m)^tags\s*:' "Archetype failure: custom-taxonomy content still uses the default tags field."
  Assert-Contains $archetypeSmoke '(?m)^date\s*:\s*("|'')?2026-08-12T00:00:00\+08:00' "Archetype failure: generated content did not use Hugo's dynamic date."

  Write-Output "Consumer and archetype checks passed."
} finally {
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
