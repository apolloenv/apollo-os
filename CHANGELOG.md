# Apollo OS - Changelog

## v0.4.1 - 2026-01-12

### 🔴 Critical Bug Fixes

#### Hardcoded Path Removal (40 Fixes Total)
- **Niri Configs (36 fixes):** Alle `/home/apollo/` Pfade entfernt
  - spawn-at-startup Zeilen fuer waybar, swaybg, swayidle entfernt
  - Wrapper-Scripts starten diese Services bereits mit korrekten Variablen
  - Keybindings verwenden jetzt `sh -c` mit Shell-Variablen
  - Nicht-existierende Script-Referenzen entfernt

- **Sway Configs (4 fixes):** Hardcodierter Terminal-Pfad entfernt

#### Boot Service Fix
- Problem: `%h` wird in System-Services nicht expandiert
- Loesung: Verwendet jetzt `/usr/share/apollo-os/boot-logo.txt`
- Korrektes TTY-Handling hinzugefuegt

#### Session Selector Fix
- Problem: `$USER` ist "greeter" bei tuigreet-Aufruf
- Loesung: Wrapper-Scripts nach `/usr/local/bin/` installieren
- greetd-Installer entsprechend aktualisiert

### 🛠 Improvements

- Niri Keybindings: `center-column` statt externem Script
- Entfernte Script-Referenzen: `wallpaper-cycle.sh`, `toggle-center.sh`
- Bessere Kommentare in Konfigurationsdateien

### 📚 Documentation

- OPUS_REVIEW_REPORT.md hinzugefuegt (vollstaendige Code-Analyse)
- KNOWN_ISSUES.md mit allen aktuellen Problemen aktualisiert
- QA_REPORT.md mit Opus Review Addendum erweitert
- README.md auf v0.4.1 aktualisiert
- Alle Versionsnummern vereinheitlicht

---

## v0.3.0 - 2026-01-12

### ✨ New Features

#### Swaylock with Blur Effect
- High Contrast Lockscreen configuration
- Blur effect (7x5) with vignette
- Wallpaper integration from `~/System/Wallpaper/current.jpg`
- Dark/Light theme variants following Inversion Rule
- Configs: `~/.config/swaylock/apollo-os-config-{dark,light}`

#### SwayOSD High Contrast
- Custom CSS styling for Volume/Brightness overlays
- Follows High Contrast Inversion Rule
- Smooth animations and gradient progress bars
- Dark system → Light OSD, Light system → Dark OSD
- Configs: `~/.config/swayosd/apollo-os-style-{dark,light}.css`

#### greetd/tuigreet Login Manager
- Terminal-based login experience
- Session selector with Apollo branding
- Remembers last session choice
- ASCII logo display on login
- Optional installation via installer
- Config: `/etc/greetd/config.toml`
- Installer: `apollo-os-greetd-installer.sh`

#### Boot Splash Integration
- Verbose boot with systemd messages
- ASCII logo display for 3 seconds during boot
- Disabled Plymouth (graphical splash)
- Configurable via systemd service
- Optional installation post-deployment
- Installer: `apollo-os-boot-splash-installer.sh`

#### Interactive Chat Function
- Rofi-based chat interface
- Seamless integration with Apollo AI
- System information queries (battery, disk, RAM, CPU)
- Chat history persistence
- Telegram integration for responses
- Command: `apollo-chat` or `apollo-os-chat.sh`

#### Interactive Notifications
- Click-to-reply functionality
- Dunstify support for better actions
- Graceful fallback to standard notifications
- Opens chat interface on notification click
- Daemon service: `apollo-os-notification-handler.service`

### 🔧 Improvements

- Added `dunst` package for better notification actions
- Enhanced daemon with interactive notification support
- Session selector for cleaner login flow
- Updated installer to v0.3.0 with new components
- Extended documentation with new features
- Added symlink `apollo-chat` for easier access

### 📚 Documentation

- Updated DEPLOYMENT.md for v0.3.0
- Added CHANGELOG.md
- Boot splash installation guide
- greetd/tuigreet setup instructions
- Interactive chat usage examples

### 🐛 Bug Fixes

- Fixed swaylock config paths
- Improved error handling in chat script
- Better systemd service dependencies

---

## v0.1.1 - 2026-01-11

### Initial Release

- Dual Window Manager support (Niri & Sway)
- Profile System (PRO/MOD)
- Hybrid AI Engine (Gemini + Ollama)
- High Contrast UI (Rofi, Mako)
- Theme Switcher
- System Monitoring
- Telegram Integration
- Apollo Daemon
- AI Tools (apollo-diagnose, ??)
- Waybar with interactive modules
- Complete installer script
- Comprehensive documentation

---

**Version:** 0.4.1
**Status:** Production Ready
**Last Updated:** 2026-01-12
