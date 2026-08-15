$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$repoParent = Split-Path -Parent $repoRoot
$themeName = Split-Path -Leaf $repoRoot
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("inyo-hugo-basic-" + [guid]::NewGuid().ToString("N"))
$basicSite = Join-Path $tempRoot "HugoBasicExample"
$output = Join-Path $tempRoot "public"
$cloneLog = Join-Path $tempRoot "clone.log"
$buildLog = Join-Path $tempRoot "build.log"

function Assert-FileExists($Path, $Message) {
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw $Message }
}

function Assert-FileNotEmpty($Path, $Message) {
  Assert-FileExists $Path $Message
  if ((Get-Item -LiteralPath $Path).Length -le 0) { throw $Message }
}

function Assert-Contains($Path, $Pattern, $Message) {
  $text = Get-Content -Raw $Path
  if ($text -notmatch $Pattern) { throw $Message }
}

try {
  New-Item -ItemType Directory -Path $tempRoot | Out-Null

  & git clone --depth 1 "https://github.com/gohugoio/HugoBasicExample.git" $basicSite *> $cloneLog
  $gitExit = $LASTEXITCODE
  if ($gitExit -ne 0) {
    throw "HugoBasicExample compatibility failure: git clone exited with $gitExit. See $cloneLog."
  }

  & hugo --source $basicSite --themesDir $repoParent --theme $themeName --destination $output --baseURL "https://example.com/" --minify --printPathWarnings *> $buildLog
  $hugoExit = $LASTEXITCODE
  if ($hugoExit -ne 0) {
    throw "HugoBasicExample compatibility failure: Hugo exited with $hugoExit. See $buildLog."
  }

  $index = Join-Path $output "index.html"
  Assert-FileNotEmpty $index "HugoBasicExample compatibility failure: homepage was not generated or is empty."
  $css = Get-ChildItem -LiteralPath (Join-Path $output "css") -Filter "main*.css" -File -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $css) {
    throw "HugoBasicExample compatibility failure: generated main CSS was not found."
  }
  Assert-FileNotEmpty $css.FullName "HugoBasicExample compatibility failure: generated main CSS is empty."
  Assert-Contains $index ([regex]::Escape($css.Name)) "HugoBasicExample compatibility failure: homepage does not reference the generated local-theme CSS."

  Write-Output "HugoBasicExample compatibility checks passed."
} finally {
  if (Test-Path -LiteralPath $tempRoot) {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force
  }
}
