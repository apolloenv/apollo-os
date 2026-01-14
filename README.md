# 🚀 Apollo OS v0.5.1

**Modern Wayland Desktop Environment for Fedora 43**

A streamlined custom layer for Fedora 43 Workstation featuring Niri scrollable tiling window manager, GTK dark theme integration, power profile management, and intelligent Text-to-Speech system.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Fedora](https://img.shields.io/badge/Fedora-43-blue.svg)](https://getfedora.org/)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-green.svg)]()

---

## ✨ Features

- 🪟 **Niri Window Manager**: Scrollable tiling compositor (Wayland-native)
- 🎨 **GTK Dark Theme**: Consistent dark mode across all applications
- 🔋 **Power Management**: Click battery icon to cycle power profiles
- 🔆 **Brightness Control**: Fn keys for screen brightness (laptops)
- 🔊 **Intelligent TTS**: LUNA Voice with system event announcements (English)
  - Login greeting
  - Battery warnings (low/critical)
  - Network status changes
  - Power profile switches
- ⚡ **Quick Menu**: Super+Shift+Space for instant actions
- 🖼️ **Wallpaper Cycling**: Dynamic wallpaper system
- 📱 **Telegram Integration**: Optional notification system
- 🔐 **Secure**: Minimal attack surface, systemd integration

---

## 🔧 Latest Changes (v0.5.1)

### Fixed: Brightness Control
- Added automatic user permissions configuration (`video` and `input` groups)
- Created udev rules for backlight access
- Hotfix script available for existing installations: `scripts/apollo-os-brightness-fix.sh`
- See [docs/BRIGHTNESS_FIX.md](docs/BRIGHTNESS_FIX.md) for details

---

## 📦 Quick Start

### Installation

```bash
# Clone repository
git clone https://github.com/apolloenv/apollo-os.git
cd apollo-os

# Run installer (~15-30 minutes)
chmod +x apollo-os-install.sh
./apollo-os-install.sh
```

### Configuration

```bash
nano ~/.config/apollo-os/config.env
```

**Optional:**
```bash
TELEGRAM_BOT_TOKEN="YOUR_TOKEN"  # For notifications
TELEGRAM_USER_ID="YOUR_ID"       # Your Telegram user ID
```

**Note:** Telegram integration is optional and can be configured later.

---

## ⌨️ Essential Keybindings

| Key | Action |
|-----|--------|
| `Super + Space` | Rofi Launcher |
| `Super + Shift + Space` | Quick Menu |
| `Super + Ctrl + Space` | Cycle Wallpaper |
| `Super + Return` | Terminal |
| `Super + L` | Lock Screen |

**[→ Full Documentation](docs/)**

---

## 📖 Documentation

- **[Installation Guide](docs/INSTALLATION.md)** - Step-by-step setup
- **[Keybindings Reference](docs/KEYBINDINGS.md)** - All keyboard shortcuts
- **[FAQ](docs/FAQ.md)** - Common questions and troubleshooting
- **[Project Validation](PROJEKT_VALIDIERUNG.md)** - Technical audit report

---

## 🔊 Voice Commands

```bash
apollo-speak "Hello World"          # Text-to-Speech with LUNA voice
apollo-speak boot                   # Predefined system message
apollo-os-greeting.sh               # Time-based greeting (auto on login)
```

**Automatic TTS Announcements (English):**
- 🎉 Login greeting ("Good morning. Welcome to Apollo OS. All systems operational")
- 🔋 Battery warnings ("Warning. Energy levels at 20 percent")
- 🔌 Power events ("Power connected" / "On battery power")
- 🌐 Network changes ("Network connected" / "disconnected")
- ⚡ Power profile switches ("Performance mode activated")

**All announcements start after Niri is fully loaded** - no audio issues!

**Privacy:** No usernames are spoken via TTS.

---

## 📜 License

MIT License - Copyright © 2026 Manuel Kraibacher

---

**Made with ❤️ in Austria | Powered by AI 🤖**
