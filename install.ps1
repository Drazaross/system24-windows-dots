$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$yasbRoot = Join-Path $env:USERPROFILE ".config\yasb"
$fastfetchRoot = Join-Path $env:USERPROFILE ".config\fastfetch"
$matugenRoot = Join-Path $env:APPDATA "matugen"
$wallpapersPath = Join-Path $env:USERPROFILE "Pictures\Wallpapers"

New-Item -ItemType Directory -Force -Path $yasbRoot, $fastfetchRoot, $matugenRoot | Out-Null

Copy-Item -Path (Join-Path $repoRoot "yasb\*") -Destination $yasbRoot -Force
Copy-Item -Path (Join-Path $repoRoot "fastfetch\*") -Destination $fastfetchRoot -Force
Copy-Item -LiteralPath (Join-Path $repoRoot "matugen\config.toml") -Destination $matugenRoot -Force
Copy-Item -LiteralPath (Join-Path $repoRoot "komorebi\komorebi-matugen.json") -Destination $matugenRoot -Force

$yasbConfigPath = Join-Path $yasbRoot "config.yaml"
$yasbConfig = Get-Content -Raw -LiteralPath $yasbConfigPath
$yasbConfig = $yasbConfig.Replace("__WALLPAPERS_PATH__", $wallpapersPath)
Set-Content -LiteralPath $yasbConfigPath -Value $yasbConfig -NoNewline

$fastfetchConfigPath = Join-Path $fastfetchRoot "config.jsonc"
$fastfetchConfig = Get-Content -Raw -LiteralPath $fastfetchConfigPath
$fastfetchConfig = $fastfetchConfig.Replace("__FASTFETCH_DIR__", $fastfetchRoot)
Set-Content -LiteralPath $fastfetchConfigPath -Value $fastfetchConfig -NoNewline

Write-Host "Installed YASB configuration to $yasbRoot"
Write-Host "Installed Fastfetch configuration to $fastfetchRoot"
Write-Host "Installed Matugen configuration to $matugenRoot"
Write-Host "Wallpaper directory: $wallpapersPath"
