$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$yasbRoot = Join-Path $env:USERPROFILE ".config\yasb"
$fastfetchRoot = Join-Path $env:USERPROFILE ".config\fastfetch"
$matugenRoot = Join-Path $env:APPDATA "matugen"
$vencordThemesRoot = Join-Path $env:APPDATA "Vencord\themes"
$wallpapersPath = Join-Path $env:USERPROFILE "Pictures\Wallpapers"
$backupStamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Backup-IfPresent {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        $backupPath = "$Path.bak-$backupStamp"
        if (Test-Path -LiteralPath $backupPath) {
            $backupPath = "$Path.bak-$backupStamp-$([guid]::NewGuid().ToString('N'))"
        }
        Copy-Item -LiteralPath $Path -Destination $backupPath
        Write-Host "Backed up $Path to $backupPath"
    }
}

function Install-File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,
        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
        throw "Required source file was not found: $Source"
    }

    Backup-IfPresent -Path $Destination
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
}

New-Item -ItemType Directory -Force -Path $yasbRoot, $fastfetchRoot, $matugenRoot, $vencordThemesRoot | Out-Null

$yasbFiles = Get-ChildItem -LiteralPath (Join-Path $repoRoot "yasb") -File
foreach ($file in $yasbFiles) {
    Install-File -Source $file.FullName -Destination (Join-Path $yasbRoot $file.Name)
}

$fastfetchFiles = Get-ChildItem -LiteralPath (Join-Path $repoRoot "fastfetch") -File
foreach ($file in $fastfetchFiles) {
    Install-File -Source $file.FullName -Destination (Join-Path $fastfetchRoot $file.Name)
}

Install-File -Source (Join-Path $repoRoot "matugen\config.toml") `
    -Destination (Join-Path $matugenRoot "config.toml")
Install-File -Source (Join-Path $repoRoot "komorebi\komorebi-matugen.json") `
    -Destination (Join-Path $matugenRoot "komorebi-matugen.json")
Install-File -Source (Join-Path $repoRoot "matugen\system24-vencord.css") `
    -Destination (Join-Path $matugenRoot "system24-vencord.css")

$vencordThemePath = Join-Path $vencordThemesRoot "system24.theme.css"
if (Test-Path -LiteralPath $vencordThemePath -PathType Leaf) {
    $vencordTheme = Get-Content -Raw -LiteralPath $vencordThemePath
    $vencordImport = "@import url('./system24-matugen.css');"
    if (-not $vencordTheme.Contains($vencordImport)) {
        Backup-IfPresent -Path $vencordThemePath
        Set-Content -LiteralPath $vencordThemePath `
            -Value "$vencordImport`r`n$vencordTheme" -NoNewline
        Write-Host "Linked Matugen colors from $vencordThemePath"
    }
} else {
    Write-Warning "Vencord System24 theme was not found; install it before using the generated colors."
}

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
