# TODO

## Installer and setup

- [ ] Expand `install.ps1` into the complete one-run setup script.
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
- [ ] Add optional startup integration for Komorebi, WHKD, and YASB.
- [ ] Print clear post-install instructions and missing dependency warnings.

## Theming integrations

- [ ] Integrate Matugen-generated colors into Komorebi borders, workspace styling, and related colors.
- [ ] Decide whether Komorebi should consume the generated palette directly or use a generated Komorebi config.
- [ ] Fix and polish the YASB CSS.
- [ ] Search the stylesheet for inconsistent, unused, or overridden rules.
- [ ] Add a YASB search widget.
- [ ] Add a YASB todo/notes widget or determine the preferred notes integration.
- [ ] Verify that all generated Matugen colors have readable contrast in YASB and Komorebi.
- [ ] Decide whether `yasb_colors.css` should remain enabled, be documented as optional, or be removed from the active import chain.

## Desktop polish

- [ ] Find or create a better wallpaper collection suited to the System24 theme.
- [ ] Add wallpaper recommendations and licensing/source notes to the documentation.
- [ ] Add Zen Browser theming.
- [ ] Add Discord theming.
- [ ] Set up Fastfetch.
- [ ] Ensure Fastfetch colors can use the Matugen palette where practical.

## Documentation

- [ ] Document the complete file layout and install destinations.
- [ ] Document the active wallpaper -> Matugen -> `palette.css` -> YASB pipeline.
- [ ] Document the optional Komorebi `applications.json`.
- [ ] Document `yasb_colors.css` and its relationship to Matugen.
- [ ] Document dependency installation and Windows-specific requirements.
- [ ] Add troubleshooting for common YASB wallpaper path and Matugen errors.
- [ ] Add update and rollback instructions.
- [ ] Add screenshots or examples after the theme stabilizes.