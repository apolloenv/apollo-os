# Apollo OS - Changelog

## v1.0.1 - 2026-01-15

### 🎉 Major Release - Feature Complete

#### ✨ New Features

**Display Management**
- Display scaling configuration during installation (1.0, 1.25, 1.5, 2.0x)
- Separate external monitor scaling control in Quick Menu
- Improved scaling persistence and reload handling

**Enhanced Quick Menu**
- Power Profile selector with clear descriptions (Power Saver, Balanced, Performance)
- External monitor scaling option (🖥️ icon)
- Keyboard shortcuts viewer (⌨️ icon) - displays all shortcuts in Rofi
- Better visual feedback for all options

**Integrated Web Search**
- Press Alt+Enter in Rofi app launcher to search web
- Automatic fallback when no app matches
- Uses default browser for search queries
- Smart launcher wrapper (apollo-os-rofi-launcher.sh)

**Window Management**
- Super+C toggles window centering (with live reload)
- Toggle script for Niri window centering (toggle-center.sh)
- Improved window behavior and control

**Software Suite Expansion**
- **Development Tools**: Docker, Neovim, zsh shell, Qt Wayland support
- **Virtualization**: Winboat (auto-installed from GitHub), QEMU/KVM, libvirt
- **Multimedia**: VLC, Kdenlive, Audacity, GIMP, Blender
- **Browsers**: Brave, Zen Browser, Tor Browser
- **Productivity**: OnlyOffice, Obsidian, Xournal++, Adobe Reader
- **IDEs**: NetBeans, Eclipse, VSCodium, Geany
- **Communication**: Slack (native), Telegram, Discord
- **Utilities**: LocalSend, VideoDownloader, Warehouse (Flatpak manager)
- **30+ Flatpak applications** automatically installed

**Configuration Improvements**
- Upgraded to production-tested Niri configurations (6 variants)
- Enhanced Waybar configurations (6 style variants)
- Improved Rofi theme from production system
- All configs imported from working local system

#### 🔧 Improvements

**Installation Process**
- Interactive display scaling selection
- Better package organization and grouping
- Flatpak batch installation with progress tracking
- Docker installation with proper group management
- Winboat dependencies and setup

**Scripts & Tools**
- `apollo-os-shortcuts.sh` - Display keyboard shortcuts in Rofi
- `apollo-os-web-search.sh` - Web search integration with browser detection
- `apollo-os-rofi-launcher.sh` - Smart launcher with Alt+Enter web search
- Enhanced scale-setter with external monitor support
- Better power profile descriptions and feedback
- Automatic Winboat installation from GitHub releases

**System Integration**
- Qt5/Qt6 Wayland support for better app compatibility
- Docker group management for development workflows
- libvirt group for VM management
- Improved permission handling
- Winboat automatic installation with version detection

#### 📦 Dependencies Added
- qt5-qtwayland, qt6-qtwayland (app compatibility)
- docker-ce, docker-ce-cli, containerd.io
- qemu-kvm, libvirt, virt-manager, bridge-utils, freerdp
- neovim, zsh, vlc, gnome-podcasts
- remmina-plugins-rdp

#### 🐛 Bug Fixes
- Fixed power profile switching with clear user feedback
- Corrected display scaling application
- Fixed external monitor handling
- Improved Niri config deployment paths

#### 📚 Documentation
- Updated README.md with v1.0.1 features
- Added comprehensive software list
- Updated installation instructions
- Enhanced feature descriptions
- Added keyboard shortcuts reference

#### 🔄 Configuration Migration
- Replaced project configs with production-tested versions
- All Niri variants (classic, developer, modern, orbit, professional)
- All Waybar variants with matching styles
- Rofi configuration from working system

---

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
