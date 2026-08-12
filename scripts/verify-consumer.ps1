$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$consumerSite = Join-Path $repoRoot "scripts\fixtures\consumer-site"
$out = Join-Path ([System.IO.Path]::GetTempPath()) "inyo-consumer-verify-$PID"
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

try {
  & hugo --source $consumerSite --destination $out --minify --printPathWarnings
  if ($LASTEXITCODE -ne 0) { throw "Consumer failure: Hugo build exited with code $LASTEXITCODE." }

  $homePage = Join-Path $out "index.html"
  $notes = Join-Path $out "notes\index.html"
  $article = Join-Path $out "notes\smoke\index.html"
  $labels = Join-Path $out "labels\index.html"
  $about = Join-Path $out "about\index.html"

  foreach ($output in @(
    @{ Path = $homePage; Name = "homepage" },
    @{ Path = $notes; Name = "notes section" },
    @{ Path = $article; Name = "article" },
    @{ Path = $labels; Name = "labels taxonomy" },
    @{ Path = $about; Name = "About page" }
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

  if (Test-Path -LiteralPath $archetypeSmoke) {
    throw "Archetype failure: fixture already contains notes/archetype-smoke.md."
  }

  & hugo new content notes/archetype-smoke.md --source $consumerSite --clock "2026-08-12T00:00:00+08:00"
  if ($LASTEXITCODE -ne 0) { throw "Archetype failure: hugo new content exited with code $LASTEXITCODE." }
  $createdArchetypeSmoke = $true
  Assert-FileExists $archetypeSmoke "Archetype failure: Hugo did not create the smoke article."
  foreach ($field in @("title", "date", "description", "summary", "draft", "math", "categories", "tags")) {
    Assert-Contains $archetypeSmoke ("(?m)^" + [regex]::Escape($field) + "\s*=") "Archetype failure: generated content is missing $field."
  }
  Assert-Contains $archetypeSmoke '(?m)^date\s*=\s*("|'')?2026-08-12T00:00:00\+08:00' "Archetype failure: generated content did not use Hugo's dynamic date."

  Write-Output "Consumer and archetype checks passed."
} finally {
  if ($createdArchetypeSmoke -and (Test-Path -LiteralPath $archetypeSmoke)) {
    Remove-Item -LiteralPath $archetypeSmoke -Force
  }
  if (Test-Path -LiteralPath $out) {
    Remove-Item -LiteralPath $out -Recurse -Force
  }
}
