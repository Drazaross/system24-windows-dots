param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$WallpaperPath
)

$ErrorActionPreference = "Stop"
$logPath = Join-Path $PSScriptRoot "matugen.log"
$configPath = Join-Path $env:APPDATA "matugen\config.toml"

try {
    if (-not (Test-Path -LiteralPath $WallpaperPath -PathType Leaf)) {
        throw "Wallpaper file does not exist: $WallpaperPath"
    }
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        throw "Matugen config file does not exist: $configPath"
    }

    $matugenCommand = Get-Command matugen -ErrorAction SilentlyContinue
    if ($null -ne $matugenCommand) {
        $matugenPath = $matugenCommand.Source
    } else {
        $cargoMatugen = Join-Path $env:USERPROFILE ".cargo\bin\matugen.exe"
        if (Test-Path -LiteralPath $cargoMatugen -PathType Leaf) {
            $matugenPath = $cargoMatugen
        } else {
            throw "matugen.exe was not found on PATH or in $cargoMatugen"
        }
    }

    & $matugenPath image `
        --config $configPath `
        --mode dark `
        --type scheme-tonal-spot `
        --prefer darkness `
        --quiet `
        $WallpaperPath *>> $logPath

    if ($LASTEXITCODE -ne 0) {
        throw "Matugen exited with code $LASTEXITCODE"
    }

    $komorebic = Get-Command komorebic -ErrorAction SilentlyContinue
    if ($null -ne $komorebic) {
        & $komorebic.Source reload-configuration *>> $logPath
        if ($LASTEXITCODE -ne 0) {
            throw "komorebic reload-configuration exited with code $LASTEXITCODE"
        }
    } else {
        Add-Content -LiteralPath $logPath -Value "$(Get-Date -Format o) komorebic was not found; generated config was not reloaded."
    }
} catch {
    $message = "$(Get-Date -Format o) Matugen update failed: $($_ | Out-String)"
    Add-Content -LiteralPath $logPath -Value $message
    exit 1
}
