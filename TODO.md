# TODO

## Installer and setup

- [x] Expand `install.ps1` into the complete one-run setup script. -> Some parts are kept manual intentionally.
- [ ] Add dependency checks for Komorebi, WHKD, YASB, Matugen, PowerShell, and Git.
- [ ] Create required directories before copying files.
- [ ] Back up existing configuration files before replacing them.
- [ ] Install `komorebi/komorebi.json` to `%USERPROFILE%`.
- [ ] Make `komorebi/applications.json` optional during installation.
- [ ] Document that users can copy only the application rules they use into their own `applications.json`.
- [ ] Install `whkd/whkdrc` to `%USERPROFILE%\.config\whkdrc`.
- [ ] Install YASB files to `%USERPROFILE%\.config\yasb`.
- [ ] Install Matugen configuration to `%APPDATA%\matugen`.
- [ ] Resolve the wallpaper path placeholder for each user.
- [ ] Ask for or detect the user's wallpaper directory.
- [x] Add startup integration instructions for Komorebi and YASB.
- [x] Add WHKD startup through the Komorebi `start --whkd` launch mode.
- [ ] Print clear post-install instructions and missing dependency warnings.

## Theming integrations

- [x] Integrate Matugen-generated colors into Komorebi borders, workspace styling, and related colors.
- [x] Decide whether Komorebi should consume the generated palette directly or use a generated Komorebi config.
- [x] Fix and polish the YASB CSS.
- [x] Search the stylesheet for inconsistent, unused, or overridden rules.
- [x] Add a YASB search widget.
- [x] Add YASB todo and notes widgets with System24 styling.
- [x] Verify that all generated Matugen colors have readable contrast in YASB and Komorebi.
- [x] Decide whether `yasb_colors.css` should remain enabled, be documented as optional, or be removed from the active import chain.

## Desktop polish

- [ ] Find or create a better wallpaper collection suited to the System24 theme.
- [ ] Add wallpaper recommendations and licensing/source notes to the documentation.
- [x] Add Zen Browser theming. -> Not possible / too much effort
- [x] Add Matugen-generated colors for the Vencord System24 theme.
- [x] Assign Discord and Steam to dedicated initial workspaces.
- [x] Set up Fastfetch with a compact System24-style configuration.
- [ ] Ensure Fastfetch colors can use the Matugen palette where practical.

## Documentation

- [x] Document the complete file layout and install destinations.
- [x] Document the active wallpaper -> Matugen -> `palette.css` -> YASB pipeline.
- [x] Document the optional Komorebi `applications.json`.
- [x] Document `yasb_colors.css` and its relationship to Matugen.
- [x] Document dependency installation and Windows-specific requirements.
- [x] Add troubleshooting for common YASB wallpaper path and Matugen errors.
- [x] Add update and rollback instructions.
- [ ] Add screenshots or examples after the theme stabilizes.