# System24 Windows dots

Configuration files for a Windows desktop built around Komorebi, WHKD, YASB, and Matugen.

## Layout

- `komorebi/` - Komorebi configuration and the application rules file referenced by it.
- `whkd/` - WHKD keybindings.
- `yasb/` - YASB bar configuration, styling, generated palette, and the Matugen bridge script.
- `matugen/` - Matugen configuration.

## Active color pipeline

1. The YASB wallpaper widget selects an image.
2. `yasb/update-matugen.ps1` runs Matugen with that image.
3. Matugen reads `yasb/matugen-yasb.css`.
4. Matugen writes `yasb/palette.css`.
5. `yasb/styles.css` imports `palette.css`.

## Files intentionally not tracked

Runtime logs such as `yasb.log` and `matugen.log` are ignored. The removed Windhawk configuration is not part of this repository. Wallust files are also excluded because Matugen is the active color generator.

## Installation notes

- Copy `komorebi/komorebi.json` and `komorebi/applications.json` to `%USERPROFILE%`.
- Copy `whkd/whkdrc` to `%USERPROFILE%\.config\whkdrc`.
- Copy the contents of `yasb/` to `%USERPROFILE%\.config\yasb`.
- Copy `matugen/config.toml` to `%APPDATA%\matugen\config.toml`.
- Review user-specific paths in the YAML, PowerShell, and TOML files before using the setup on another machine.
