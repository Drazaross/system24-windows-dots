# System24 Windows dots

Portable Windows configuration files inspired by System24, Vencord, and the
Text theme from Spicetify. The setup is built around Komorebi, WHKD, YASB,
Matugen, and Fastfetch.

## Installation

### Prerequisites

Install the applications below before applying the configuration:

- [Komorebi](https://github.com/lgug2z/komorebi) for tiling and window borders.
- [WHKD](https://github.com/LGUG2Z/whkd) for hotkeys.
- [YASB Reborn](https://github.com/amnweb/yasb) for the status bar.
- [Matugen](https://github.com/InioX/matugen) for wallpaper-derived colors.
- [Fastfetch](https://github.com/fastfetch-cli/fastfetch) for the system summary.

The active user should also have JetBrains Mono Nerd Font installed so the
icons in YASB and the custom Fastfetch logo render correctly. **Bibata Modern
Cursor** is also recommended to match the visual style of the setup, although
it is not required for the configurations to work. This setup intentionally
uses the fixed per-user wallpaper directory
`%USERPROFILE%\Pictures\Wallpapers`; create it if necessary and place wallpapers
there. The installer prints the resolved absolute path for the current user.

### Automated installation

Install the prerequisites in the previous section, then open PowerShell in the
repository root and run:

```powershell
.\install.ps1
```

The script checks for `komorebic`, `whkd`, `yasbc`, `matugen`, and `fastfetch`.
Missing commands are reported as warnings; the script does not install
software, modify `PATH`, change execution policy, or require administrator
access. PowerShell 7 (`pwsh`) and Git are recommended but optional.

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
   user's paths in both the active and Matugen-generated configurations.
7. Creates a timestamped `.bak-YYYYMMDD-HHMMSS` backup before replacing any
   existing file.

The script does not install or overwrite the main Komorebi, WHKD, or optional
`applications.json` files. Copy those manually as described below, after
reviewing them for your machine.

### Manual installation

Run these commands from the repository root after `install.ps1` completes:

```powershell
Copy-Item .\komorebi\komorebi.json $env:USERPROFILE -Force
New-Item -ItemType Directory -Force `
  -Path (Join-Path $env:USERPROFILE ".config") | Out-Null
Copy-Item .\whkd\whkdrc `
  (Join-Path $env:USERPROFILE ".config\whkdrc") -Force
Copy-Item .\komorebi\applications.json `
  (Join-Path $env:USERPROFILE "applications.json") -Force
```

The supplied `komorebi.json` references
`%USERPROFILE%\applications.json`. Copy the repository file if you want the
included application-specific rules. Otherwise, remove or change
`app_specific_configuration_path` in your own Komorebi configuration before
starting Komorebi. You can also create your own `applications.json` and copy
only the application rule blocks you use from the repository file.

The installer already copies `matugen/config.toml`,
`komorebi/komorebi-matugen.json`, and the Vencord template to their runtime
locations. Do not copy those files a second time unless you are repairing an
installation.

Create the default wallpaper directory and place at least one supported image
inside it:

```powershell
$wallpapers = Join-Path $env:USERPROFILE "Pictures\Wallpapers"
New-Item -ItemType Directory -Force -Path $wallpapers | Out-Null
```

Generate the initial palette, Komorebi colors, and Vencord override:

```powershell
$wallpaper = Join-Path $wallpapers "your-wallpaper.jpg"
& (Join-Path $env:USERPROFILE ".config\yasb\update-matugen.ps1") `
  -WallpaperPath $wallpaper
```

After installation, reload the relevant applications:

```powershell
yasbc reload
komorebic reload-configuration
fastfetch
```

### Startup

After validating the configuration, enable the complete Komorebi, WHKD, and
YASB startup flow with these commands. Run them from the repository root in
PowerShell:

```powershell
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

### Vencord System24 theme

Copy the repository's [vencord-system24.theme.css](./vencord-system24.theme.css)
to:

```text
%APPDATA%\Vencord\themes\system24.theme.css
```

If a theme with that name already exists, back it up before replacing it. In
Vencord, enable or reload the `system24` theme. The repository copy already
imports the generated local override:

```css
@import url('./system24-matugen.css');
```

The installer does not replace the upstream Vencord theme automatically because
theme files can be locally customized. If the theme file already exists, the
installer only adds this import once and creates a timestamped backup first.
Matugen generates `system24-matugen.css` alongside it whenever the wallpaper
pipeline runs.

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
- `vencord-system24.theme.css` - Repository copy of the System24 Vencord theme;
  copy it to Vencord's themes directory before enabling Discord theming.

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
- `config-matugen.jsonc` - Matugen template that generates Fastfetch logo,
  title, key, and output colors from the active wallpaper palette.
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
10. Matugen writes the wallpaper-derived Fastfetch colors to
    `%USERPROFILE%\.config\fastfetch\config.jsonc`.

`yasb_colors.css` is separate from the Matugen pipeline. YASB generates it
when `system_colors: true` is enabled, and it supplies Windows system color
variables. Matugen remains the active source for the wallpaper-derived
`palette.css` colors.

The Vencord System24 theme remains the upstream theme file. The generated
`system24-matugen.css` file overrides its `:root` colors after the upstream
theme import, so Discord receives the same wallpaper-derived palette without
replacing the upstream theme.

Fastfetch supports explicit color values, so it uses the same Matugen palette
when the wallpaper pipeline has generated its configuration. The static
`fastfetch/config.jsonc` remains a fallback until the first successful Matugen
update. Run `fastfetch` after changing the wallpaper to view the updated
colors.

Discord does not live-reload local theme CSS changes. The Matugen update script
automatically restarts Discord only when Discord was already running before the
wallpaper update. If Discord was closed, it remains closed. The generated
colors appear after the restarted Discord instance loads the local theme.

Komorebi uses the documented British spellings `border_colours` and
`border_style`. The `theme` block is intentionally omitted because defining a
theme prevents generated `border_colours` from taking effect. This setup uses
`border_implementation: "Komorebi"` and a border width of `4`.

### Discord and Steam workspace mapping

The main Komorebi configuration uses two monitor configurations. The laptop monitor (configuration index `0`) has ten workspaces named `L1`
through `L8`, `L9`, and `L0`, while the external monitor (configuration index
`1`) has ten workspaces named `S1` through `S8`, `S9`, and `S0`.
The application workspace rules remain inside the corresponding workspace
definitions:

- Discord is assigned to workspace `L9` using an executable rule that contains
  `Discord`.
- Steam is assigned to workspace `L0` using an exact executable match for
  `steamwebhelper.exe`.

Steam uses `steamwebhelper.exe` because the visible Steam client window is
created by that process; `steam.exe` is the launcher/background process and
usually has no visible main window. To inspect the executable associated with
currently visible windows, run:

```powershell
komorebic visible-windows
```

Keep the same workspace rules in
`komorebi/komorebi-matugen.json`. Matugen regenerates
`%USERPROFILE%\komorebi.json` whenever the wallpaper changes, so adding a rule
only to the live generated file causes it to disappear on the next palette
update.

### Multi-monitor workspace shortcuts

The WHKD bindings use fixed monitor indices:

- `Alt+1` through `Alt+8` focus workspaces `S1` through `S8` on the external
  monitor.
- `Alt+9` and `Alt+0` focus `S9` and `S0` on the external monitor.
- `Alt+Ctrl+1` through `Alt+Ctrl+8` focus workspaces `L1` through `L8`
  on the laptop.
- `Alt+Ctrl+9` and `Alt+Ctrl+0` focus `L9` and `L0` on the laptop.
- `Alt+Shift+Comma` moves the focused window to the laptop monitor without
  selecting a workspace.
- `Alt+Shift+Period` moves the focused window to the external monitor without
  selecting a workspace.

The `Alt+Shift+1` through `Alt+Shift+0` bindings move a window between
workspaces on the external monitor, while `Alt+Ctrl+Shift+1` through
`Alt+Ctrl+Shift+0` move it between workspaces on the laptop. Use
`Alt+Shift+Comma` first to move a window between monitors, then use the
workspace move shortcut for that monitor. Keeping monitor moves and workspace
moves as separate shortcuts avoids depending on Komorebi's focused-monitor
state during a chained command. The monitor indices are configuration indices, not
necessarily the order shown by Windows. If Komorebi assigns the monitors in
the opposite order, run:

```powershell
komorebic monitor-info
```

Then add `display_index_preferences` to both
`komorebi/komorebi.json` and `komorebi/komorebi-matugen.json`, using the
laptop's `serial_number_id` for configuration index `0` and the external
monitor's `serial_number_id` for configuration index `1`:

```json
"display_index_preferences": {
  "0": "LAPTOP_SERIAL_NUMBER_ID",
  "1": "EXTERNAL_SERIAL_NUMBER_ID"
}
```

After changing the configuration, reload it with:

```powershell
komorebic reload-configuration
```

If a window is not managed after connecting the display, use
`komorebic manage` or restart Komorebi. `komorebic state` can be used to
confirm the monitor index map.

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

### YASB reports that no wallpapers were found

This YASB version does not expand `%USERPROFILE%` or `~` inside the wallpaper
widget's `image_path`. The repository therefore uses the
`__WALLPAPERS_PATH__` placeholder, and `install.ps1` replaces it with an
absolute path such as:

```text
C:\Users\<user>\Pictures\Wallpapers
```

If the widget still reports no wallpapers:

1. Confirm the directory exists.
2. Confirm it contains supported image files such as `.png`, `.jpg`, `.jpeg`,
   or `.webp`.
3. Open `%USERPROFILE%\.config\yasb\config.yaml`.
4. Check that `image_path` contains the absolute wallpaper directory.
5. Reload YASB:

   ```powershell
   yasbc reload
   ```

### Matugen does not update the palette

Check the Matugen log:

```powershell
Get-Content "$env:USERPROFILE\.config\yasb\matugen.log" -Tail 80
```

Then verify the required files and commands:

```powershell
Test-Path "$env:APPDATA\matugen\config.toml"
Test-Path "$env:APPDATA\matugen\komorebi-matugen.json"
Get-Command matugen
matugen --version
```

The wallpaper path passed to the update script must point to an existing image.
If Matugen is installed with Cargo but is not found, verify that
`%USERPROFILE%\.cargo\bin` is on `PATH`, or run the binary directly from that
directory. The update script also falls back to that path.

### Discord colors do not change

Discord does not live-reload local theme CSS. After Matugen generates
`system24-matugen.css`, the update script restarts an already-running Discord
instance. If Discord was not running during the update, start it manually and
make sure the `system24` theme is enabled in Vencord.

## Updating and rolling back

### Updating the dotfiles

Pull or copy the latest repository changes, then run:

```powershell
.\install.ps1
```

The installer backs up every existing file it replaces using a timestamped
suffix:

```text
filename.ext.bak-YYYYMMDD-HHMMSS
```

After updating, reload the active applications:

```powershell
yasbc reload
komorebic reload-configuration
```

If Discord was closed during the update, start it manually after the generated
CSS is available.

### Rolling back an installation

1. Close or stop the affected application.
2. Find the corresponding `.bak-YYYYMMDD-HHMMSS` file beside the installed
   configuration.
3. Copy the backup over the current file after reviewing both files.
4. Reload the affected application.

For example:

```powershell
Copy-Item "$env:USERPROFILE\.config\yasb\styles.css.bak-YYYYMMDD-HHMMSS" `
  "$env:USERPROFILE\.config\yasb\styles.css" -Force
yasbc reload
```

To remove the startup entries created by this setup:

```powershell
komorebic disable-autostart
yasbc disable-autostart
```

The installer does not automatically delete backups, generated palettes,
custom themes, or user configuration files.

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
