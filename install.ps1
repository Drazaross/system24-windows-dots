$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$yasbRoot = Join-Path $env:USERPROFILE ".config\yasb"
$fastfetchRoot = Join-Path $env:USERPROFILE ".config\fastfetch"
$matugenRoot = Join-Path $env:APPDATA "matugen"
$vencordThemesRoot = Join-Path $env:APPDATA "Vencord\themes"
$wallpapersPath = Join-Path $env:USERPROFILE "Pictures\Wallpapers"
$backupStamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Test-Dependency {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Purpose,
        [switch]$Optional
    )

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        Write-Host "Found $Name at $($command.Source)"
        return $true
    }

    if ($Optional) {
        Write-Warning "$Name was not found. $Purpose"
    } else {
        Write-Warning "$Name was not found. $Purpose"
    }
    return $false
}

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

$missingDependencies = [System.Collections.Generic.List[string]]::new()
$dependencies = @(
    @{ Name = "komorebic"; Purpose = "Install Komorebi before starting the window manager." },
    @{ Name = "whkd"; Purpose = "Install WHKD before using the supplied hotkey configuration." },
    @{ Name = "yasbc"; Purpose = "Install YASB Reborn before reloading or enabling the bar." },
    @{ Name = "matugen"; Purpose = "Install Matugen before generating wallpaper-derived colors." },
    @{ Name = "fastfetch"; Purpose = "Install Fastfetch before running the supplied system summary." },
    @{ Name = "pwsh"; Purpose = "PowerShell 7 is recommended for the update scripts."; Optional = $true },
    @{ Name = "git"; Purpose = "Git is optional, but recommended for updating the dotfiles."; Optional = $true }
)

foreach ($dependency in $dependencies) {
    $found = Test-Dependency -Name $dependency.Name -Purpose $dependency.Purpose `
        -Optional:$dependency.Optional
    if (-not $found -and -not $dependency.Optional) {
        $missingDependencies.Add($dependency.Name)
    }
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

Write-Host ""
Write-Host "Remaining setup steps:"
Write-Host "1. Copy komorebi\komorebi.json to $env:USERPROFILE\komorebi.json."
Write-Host "2. Copy whkd\whkdrc to $env:USERPROFILE\.config\whkdrc."
Write-Host "3. Copy komorebi\applications.json if you want the application rules."
Write-Host "4. Place a wallpaper in $wallpapersPath."
Write-Host "5. Generate colors with:"
Write-Host "   & '$yasbRoot\update-matugen.ps1' -WallpaperPath '$wallpapersPath\your-wallpaper.jpg'"
Write-Host "6. Validate and start Komorebi with komorebic check and komorebic start --whkd."
Write-Host "7. Reload YASB with yasbc reload, then enable startup with:"
Write-Host "   komorebic enable-autostart"
Write-Host "   yasbc enable-autostart"

if ($missingDependencies.Count -gt 0) {
    Write-Warning "Missing required commands: $($missingDependencies -join ', ')"
    Write-Warning "Install them before starting the related parts of this setup."
}
