# System24 Windows dots

Portable Windows configuration files inspired by System24, Vencord, and the
Text theme from Spicetify. The setup is built around Komorebi, WHKD, YASB,
Matugen, and Fastfetch.

## Installation

### Prerequisites

Install the applications below before applying the configuration:

- [Komorebi](https://github.com/LGUG2/komorebi) for tiling and window borders.
- [WHKD](https://github.com/LGUG2/whkd) for hotkeys.
- [YASB Reborn](https://github.com/amnweb/yasb) for the status bar.
- [Matugen](https://github.com/InioX/matugen) for wallpaper-derived colors.
- [Fastfetch](https://github.com/fastfetch-cli/fastfetch) for the system summary.

The active user should also have JetBrains Mono Nerd Font installed so the
icons in YASB and the custom Fastfetch logo render correctly. Place wallpapers
in `%USERPROFILE%\Pictures\Wallpapers`.

### Automated installation

From PowerShell in the repository root, run:

```powershell
.\install.ps1
```

The installer:

1. Creates `%USERPROFILE%\.config\yasb`,
   `%USERPROFILE%\.config\fastfetch`, and `%APPDATA%\matugen`.
2. Copies the YASB files to `%USERPROFILE%\.config\yasb`.
3. Copies the Fastfetch files to `%USERPROFILE%\.config\fastfetch`.
4. Copies the Matugen configuration and Komorebi Matugen template to
   `%APPDATA%\matugen`.
5. Links the existing Vencord System24 theme to the generated local override,
   when `%APPDATA%\Vencord\themes\system24.theme.css` exists.
6. Replaces `__WALLPAPERS_PATH__` and `__FASTFETCH_DIR__` with the current
   user's paths.
7. Creates a timestamped `.bak-YYYYMMDD-HHMMSS` backup before replacing any
   existing file.

The script does not install or overwrite the main Komorebi, WHKD, or optional
`applications.json` files. Copy those manually as described below, after
reviewing them for your machine.

### Manual installation

```powershell
Copy-Item .\komorebi\komorebi.json $env:USERPROFILE
Copy-Item .\whkd\whkdrc (Join-Path $env:USERPROFILE ".config\whkdrc")
Copy-Item .\matugen\config.toml (Join-Path $env:APPDATA "matugen\config.toml")
Copy-Item .\komorebi\komorebi-matugen.json (Join-Path $env:APPDATA "matugen")
```

Copy `komorebi/applications.json` to `%USERPROFILE%\applications.json` only if
you want the included application-specific rules. It is optional; you can
omit it, create your own, or copy only the rules for applications you use.

After installation, reload the relevant applications:

```powershell
yasbc reload
komorebic reload-configuration
fastfetch
```

### Startup

After installing the configuration, a new user can enable the complete
Komorebi, WHKD, and YASB startup flow with these commands. Run them from the
repository root in PowerShell:

```powershell
# Install the main Komorebi configuration and WHKD bindings.
Copy-Item .\komorebi\komorebi.json $env:USERPROFILE
Copy-Item .\whkd\whkdrc (Join-Path $env:USERPROFILE ".config\whkdrc")

# Validate the files before enabling startup.
komorebic check --komorebi-config (Join-Path $env:USERPROFILE "komorebi.json")

# Register Komorebi and YASB for the current Windows user.
komorebic enable-autostart
yasbc enable-autostart

# Make Komorebi start WHKD through the same Startup-folder shortcut.
$startup = [Environment]::GetFolderPath("Startup")
$shortcutPath = Join-Path $startup "komorebi.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.Arguments = "start --whkd"
$shortcut.Save()
```

The generated shortcut should target `komorebic-no-console.exe` and contain:

```text
start --whkd
```

The `--whkd` option uses the WHKD configuration at
`%USERPROFILE%\.config\whkdrc`. The commands above affect only the current
Windows user and do not require administrator access.

The rest of the repository can then be installed with:

```powershell
.\install.ps1
```

Run `install.ps1` before the startup commands if you want YASB, Fastfetch, and
Matugen installed first. The Komorebi and WHKD copy commands remain separate
because the installer intentionally does not overwrite those core
window-management and global-keybinding files.

The Komorebi command creates `komorebi.lnk` in the user's Startup folder.
YASB registers its own per-user startup entry. These commands do not create a
Windows service or change system-wide startup settings.

To remove the startup entries later:

```powershell
komorebic disable-autostart
yasbc disable-autostart
```

WHKD is started by Komorebi with `komorebic start --whkd`, rather than through
a separate WHKD startup shortcut.

## Repository layout

Every tracked file is listed below with its purpose.

### Root files

- `.gitignore` - Excludes runtime logs, Matugen cache data, and local-only files
  from version control.
- `install.ps1` - Installs YASB, Fastfetch, and Matugen files and resolves
  user-specific path placeholders.
- `README.md` - The source of truth for installation, configuration flow,
  portability, troubleshooting, and file ownership.
- `TODO.md` - Tracks remaining setup, theming, documentation, and installer
  work.

### `komorebi/`

- `komorebi.json` - Main Komorebi tiling, bar, layout, border, and workspace
  configuration.
- `applications.json` - Optional application-specific Komorebi rules,
  including the Claude rule moved out of the main configuration.
- `komorebi-matugen.json` - Matugen template that generates wallpaper-derived
  Komorebi border colors.

### `whkd/`

- `whkdrc` - WHKD keyboard shortcuts for controlling Komorebi and related
  desktop actions.

### `yasb/`

- `config.yaml` - YASB bar layout, widget definitions, callbacks, wallpaper
  selection, search, Todo, Notes, and Matugen trigger configuration.
- `styles.css` - System24-style YASB stylesheet for the bar, widgets, menus,
  Todo/Notes popups, and search interface.
- `matugen-yasb.css` - Matugen input template for generating YASB color
  variables from the selected wallpaper.
- `palette.css` - Generated or fallback palette imported by `styles.css`;
  Matugen replaces its colors during wallpaper updates.
- `yasb_colors.css` - YASB-generated Windows system color variables retained
  for compatibility and `--yasb-*` variables.
- `update-matugen.ps1` - Runs Matugen for YASB and Komorebi after a wallpaper
  change, logs failures, and reloads Komorebi.

### `matugen/`

- `config.toml` - Matugen template mappings for generating the YASB palette,
  Komorebi configuration, and Vencord System24 override.
- `system24-vencord.css` - Matugen template that maps Material color roles to
  the System24 Discord theme variables.

### `fastfetch/`

- `config.jsonc` - Compact Fastfetch module list and System24 color settings
  with a portable logo path placeholder.
- `logo.txt` - Custom Fastfetch ASCII artwork using the requested `3 5 1`
  color mapping through `$1`, `$2`, and `$3` placeholders.

## Active color pipeline

1. The YASB wallpaper widget selects an image.
2. `yasb/update-matugen.ps1` runs Matugen with that image.
3. Matugen reads `yasb/matugen-yasb.css`.
4. Matugen writes the generated colors to `yasb/palette.css`.
5. Matugen reads `komorebi/komorebi-matugen.json`.
6. Matugen writes the generated Komorebi configuration to
   `%USERPROFILE%\komorebi.json`.
7. `yasb/styles.css` imports `palette.css`.
8. The update script reloads Komorebi after generation; YASB watches its
   configuration directory and reloads stylesheet changes.
9. Matugen writes a Vencord System24 override to
   `%APPDATA%\Vencord\themes\system24-matugen.css`.
10. If Discord is already running, the wallpaper script restarts its running
    Discord processes so Vencord reloads the generated theme. Discord is not
    launched when it was already closed.

`yasb_colors.css` is separate from the Matugen pipeline. YASB generates it
when `system_colors: true` is enabled, and it supplies Windows system color
variables. Matugen remains the active source for the wallpaper-derived
`palette.css` colors.

The Vencord System24 theme remains the upstream theme file. The generated
`system24-matugen.css` file overrides its `:root` colors after the upstream
theme import, so Discord receives the same wallpaper-derived palette without
replacing the upstream theme.

Komorebi uses the documented British spellings `border_colours` and
`border_style`. The `theme` block is intentionally omitted because defining a
theme prevents generated `border_colours` from taking effect. This setup uses
`border_implementation: "Komorebi"` and a border width of `4`.

The main Komorebi configuration sends newly created `Discord.exe` windows to
workspace IX and `steam.exe` windows to workspace X. Komorebi workspace indexes
are zero-based, so IX is configured as `8` and X as `9`. These are initial
workspace rules: users can still move the windows afterward.

## Portability notes

- The repository uses `__WALLPAPERS_PATH__` because this installed YASB
  version does not expand `%USERPROFILE%` or `~` inside the wallpaper widget's
  `image_path`.
- The repository uses `__FASTFETCH_DIR__` so the Fastfetch logo path is resolved
  for each user during installation.
- Matugen's `./komorebi-matugen.json` path is relative to the runtime Matugen
  directory, so the installer copies the template into `%APPDATA%\matugen`.
- `komorebi/applications.json` is intentionally optional and should be adapted
  to the applications installed on the target machine.

## Files intentionally not tracked

Runtime files such as `yasb.log`, `matugen.log`, and Matugen cache data are
ignored. Wallust files are excluded because Matugen is the active color
generator. Windhawk configuration is also excluded because that experiment was
removed as unstable.

## Troubleshooting

### Installing Matugen with Cargo

Matugen is distributed as a Rust crate. Installing it with Cargo compiles the
Rust binary locally:

```powershell
cargo install matugen
```

On Windows, Rust crate compilation may require the Microsoft C++ build
toolchain. If `cargo install matugen` fails with linker errors or reports that
`link.exe` or a C++ build tool is missing, install **Visual Studio Build Tools**
from the official Microsoft installer.

Select these workloads and components:

- **Desktop development with C++**
- MSVC build tools for the installed architecture
- A Windows 10 or Windows 11 SDK

After installation, close and reopen PowerShell, verify Rust and Cargo, and
retry:

```powershell
rustc --version
cargo --version
cargo install matugen
```

If Matugen is installed but PowerShell cannot find it, add or verify this
directory on `PATH`:

```text
%USERPROFILE%\.cargo\bin
```

You can also run the binary directly:

```powershell
& "$env:USERPROFILE\.cargo\bin\matugen.exe" --version
```

Visual Studio Build Tools are only needed to compile Rust crates locally; they
are not required at runtime when using an already-built Matugen binary.
