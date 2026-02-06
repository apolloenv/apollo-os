# Apollo OS v0.5.0 - Dokumentation

**Copyright © 2026 by Manuel Kraibacher**

Willkommen zur offiziellen Dokumentation von Apollo OS!

---

## 📚 Dokumentations-Index

### 🚀 Für Einsteiger
- **[Installation Guide](INSTALLATION.md)** - Schritt-für-Schritt Installationsanleitung
- **[FAQ](FAQ.md)** - Häufig gestellte Fragen und Problemlösungen
- **[Keybindings](KEYBINDINGS.md)** - Vollständige Tastenkürzel-Referenz

### 🔧 Für Fortgeschrittene
- **[Audio System](AUDIO_SYSTEM.md)** - TTS-Konfiguration (Piper + LUNA)
- **[Audio Implementation](AUDIO_IMPLEMENTATION.md)** - Technische Details zur Audio-Integration

### ⚡ Features & Tools
- **[Power Management](../scripts/apollo-os-power-profile.sh)** - Power Profile Switcher Script

### 🎨 Design & Branding
- **[Branding Ideas](APOLLO_BRANDING_IDEAS.md)** - Logo, Farben, Visual Identity

---

## 📖 Schnellstart

### Installation
```bash
git clone https://github.com/apolloenv/apollo-os.git
cd apollo-os
chmod +x apollo-os-install.sh
./apollo-os-install.sh
```

### Wichtigste Keybindings
- `Super + Space` - Rofi Launcher
- `Super + Return` - Terminal
- `Super + Shift + ?` - Keybindings anzeigen

### Voice Commands
```bash
apollo-speak "Hello World"
```

---

## 🗂️ Projekt-Struktur

```
apollo-os/
├── apollo-os-install.sh          # Master Installer
├── README.md                     # Projekt-Übersicht
├── PROJEKT_VALIDIERUNG.md        # Technischer Audit-Bericht
│
├── config-data/                  # Konfigurationsdateien
│   ├── niri/                     # Niri WM Config
│   ├── waybar/                   # Waybar Config + CSS
│   ├── mako/                     # Notification Config
│   ├── rofi/                     # Rofi Theme
│   └── gtk-*.ini                 # GTK Theme Settings
│
├── scripts/                      # System-Scripts
│   ├── apollo-os-wrapper-niri.sh
│   ├── apollo-speak.sh
│   ├── apollo-os-greeting.sh
│   └── ...
│
├── docs/                         # Dokumentation (dieser Ordner)
├── assets/                       # Logos, Wallpapers
└── systemd/                      # Systemd Services
```

---

## 🔧 Konfigurationsdateien

### Niri Window Manager
**Config:** `~/.config/niri/config.kdl`  
**Autostart:** `~/.config/niri/apollo-autostart.sh`

### Waybar (Status-Bar)
**Config:** `~/.config/waybar/config`  
**Style:** `~/.config/waybar/style.css`

### Rofi (Launcher)
**Theme:** `~/.config/rofi/config.rasi`

### Mako (Notifications)
**Config:** `~/.config/mako/config`

### Apollo OS System
**Config:** `~/.config/apollo-os/config.env`

---

## 🎯 Kern-Features

### 🪟 Niri Window Manager
- Scrollbares Tiling-Layout (horizontal)
- Wayland-native (kein X11)
- Moderne KDL-Konfiguration
- Integrierte Übersicht (Super+O)

### 🎨 GTK Dark Theme
- Konsistente Dark-Mode Integration
- adw-gtk3-dark Theme
- XDG Desktop Portal Unterstützung

### 🔊 Text-to-Speech
- **Engine:** Piper TTS
- **Voice:** LUNA (en_GB-jenny_dioco-medium)
- **Fallback:** espeak-ng
- **Chime:** 880Hz → 660Hz

### ⚡ Quick Menu
`Super + Shift + Space` öffnet Schnellmenü mit:
- Lock, Logout, Reboot, Shutdown
- Screenshot, Wallpaper, Theme
- Audio, Network, Bluetooth
- System Stats

### 🔋 Power Management
- **Click Battery Icon**: Cycle through power profiles
- **Power Saver**: Maximum battery life
- **Balanced**: Default mode
- **Performance**: Maximum performance

---

## 📦 Installierte Pakete

### Window Manager & Wayland
- niri, waybar, rofi, mako
- grim, slurp (Screenshots)
- swaylock, swayidle, swaybg
- wl-clipboard

### Terminal Emulators
- alacritty (Standard)
- kitty (Alternative)

### System Tools
- NetworkManager, Blueman
- brightnessctl, playerctl
- **power-profiles-daemon** (Power Management)
- btop, fastfetch
- jq, wget, unzip

### Fonts
- JetBrainsMono Nerd Font
- Noto Emoji, FontAwesome
- Fira Code

---

## 🔐 Sicherheit

### Systemd Service Sandboxing
Alle Apollo OS Services laufen mit:
- `PrivateTmp=yes`
- `ProtectHome=read-only`
- `NoNewPrivileges=yes`

### Keine Root-Rechte erforderlich
Alle Scripts laufen im User-Space (außer Installation).

---

## 🆘 Support

### GitHub
- **Issues:** https://github.com/apolloenv/apollo-os/issues
- **Discussions:** https://github.com/apolloenv/apollo-os/discussions

### E-Mail
**aiq@kraibacher.com**

### Community
- Reddit: r/apolloos (geplant)
- Discord: Apollo OS Community (geplant)

---

## 📜 Lizenz

**MIT License**  
Copyright © 2026 Manuel Kraibacher

Siehe `LICENSE` Datei für Details.

---

## 🙏 Credits

### Verwendete Projekte
- **Niri** - YaLTeR (https://github.com/YaLTeR/niri)
- **Waybar** - Alexays (https://github.com/Alexays/Waybar)
- **Rofi** - DaveDavenport (https://github.com/davatorium/rofi)
- **Piper TTS** - Rhasspy (https://github.com/rhasspy/piper)
- **Fedora** - Fedora Project (https://getfedora.org/)

### Inspiration
- **Sway** - swaywm.org
- **i3** - i3wm.org
- **Hyprland** - hyprland.org

---

## 🗺️ Roadmap

### v0.5.1 (geplant)
- [ ] Multi-Monitor Hotplugging
- [ ] Auto-Update Mechanismus
- [ ] Erweiterte Wallpaper-Engine

### v0.6.0 (geplant)
- [ ] Optionale AI-Integration (Modul)
- [ ] Remote Control via Web-UI
- [ ] Advanced Power Management

---

## 📝 Changelog

Siehe `CHANGELOG.md` im Hauptverzeichnis für vollständige Versionshistorie.

---

**Made with ❤️ in Austria | Powered by Niri 🪟**
