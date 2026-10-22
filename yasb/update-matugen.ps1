param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$WallpaperPath
)

$ErrorActionPreference = "Stop"
$logPath = Join-Path $PSScriptRoot "matugen.log"
$configPath = Join-Path $env:APPDATA "matugen\config.toml"
$discordProcesses = @(Get-Process -Name Discord -ErrorAction SilentlyContinue)
$discordProcessIds = @($discordProcesses | Select-Object -ExpandProperty Id)
$discordExecutablePath = $null
if ($discordProcesses.Count -gt 0) {
    $discordWindowProcess = $discordProcesses |
        Where-Object { $_.MainWindowHandle -ne 0 } |
        Select-Object -First 1
    if ($null -eq $discordWindowProcess) {
        $discordWindowProcess = $discordProcesses | Select-Object -First 1
    }
    $discordExecutablePath = $discordWindowProcess.Path
}

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

    if ($discordProcessIds.Count -gt 0) {
        if ([string]::IsNullOrWhiteSpace($discordExecutablePath)) {
            throw "Discord was running, but its executable path could not be determined."
        }

        foreach ($processId in $discordProcessIds) {
            $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
            if ($null -ne $process) {
                Stop-Process -Id $processId -Force
            }
        }

        Start-Process -FilePath $discordExecutablePath
        Add-Content -LiteralPath $logPath `
            -Value "$(Get-Date -Format o) Discord was restarted after Matugen generation."
    }

} catch {
    $message = "$(Get-Date -Format o) Matugen update failed: $($_ | Out-String)"
    Add-Content -LiteralPath $logPath -Value $message
    exit 1
}
