# 🚀 Apollo OS v1.0.1

**Modern Wayland Desktop Environment for Fedora 43**

A streamlined custom layer for Fedora 43 Workstation featuring Niri scrollable tiling window manager, extensive software suite, enhanced UI controls, and intelligent Text-to-Speech system.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Fedora](https://img.shields.io/badge/Fedora-43-blue.svg)](https://getfedora.org/)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-green.svg)]()

---

## ✨ Features

- 🪟 **Niri Window Manager**: Scrollable tiling compositor (Wayland-native)
- 🎨 **GTK Dark Theme**: Consistent dark mode across all applications
- 🔍 **Display Scaling**: Configurable scaling (1.0-2.0x) for internal and external monitors
- 🔋 **Power Management**: Enhanced power profiles with clear descriptions
- 🔆 **Brightness Control**: Fn keys for screen brightness (laptops)
- 🖼️ **Boot Branding**: Apollo OS watermark for Plymouth boot splash
- 🔊 **Intelligent TTS**: LUNA Voice with system event announcements (English)
  - Login greeting
  - Battery warnings (low/critical)
  - Network status changes
  - Power profile switches
- ⚡ **Enhanced Quick Menu**: Super+Shift+Space for instant actions
  - Display scaling controls
  - External monitor scaling
  - Keyboard shortcuts viewer
  - Power profile switcher
- ⌨️ **Keyboard Shortcuts**: In-app shortcut display (Super+C for centering)
- 🔍 **Integrated Web Search**: Alt+Enter in app launcher to search web
- 🐳 **Docker Ready**: Container runtime for development
- 🪟 **Winboat**: Windows VM manager automatically installed
- 📦 **Rich Software Suite**: 30+ Flatpak applications pre-installed
- 📱 **Telegram Integration**: Optional notification system
- 🔐 **Secure**: Minimal attack surface, systemd integration

---

## 🔧 Latest Changes (v1.0.1)

### New Features
- **Display Scaling Configuration**: Choose between 1.0, 1.25, 1.5, 2.0x during installation
- **External Monitor Scaling**: Separate scaling control for external displays
- **Enhanced Power Profiles**: Clear descriptions (Power Saver, Balanced, Performance)
- **Keyboard Shortcuts Display**: View all shortcuts in Rofi (⌨️ icon in Quick Menu)
- **Window Centering**: Toggle with Super+C
- **Integrated Web Search**: Press Alt+Enter in app launcher to search web directly
- **Automatic Winboat Installation**: Windows VM manager installed from GitHub releases

### Software Additions
- **Development**: Docker, Neovim, zsh, Qt Wayland support, Winboat (auto-installed)
- **Multimedia**: VLC, Kdenlive, Audacity, GIMP, Blender
- **Productivity**: OnlyOffice, Obsidian, NetBeans, Eclipse, VSCodium
- **Communication**: Slack, Telegram, Discord, Brave Browser, Tor Browser
- **30+ Flatpak Applications**: Comprehensive software suite for all needs

### Improvements
- Upgraded configuration from local production system
- Better power profile management with visual feedback
- Enhanced Quick Menu with more options
- Improved external monitor handling

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

### Boot Splash (Optional)

Choose between two boot splash options:

**Option 1: Plymouth with Apollo OS Logo** (Professional)
```bash
sudo ./scripts/apollo-os-plymouth-installer.sh
```

**Option 2: ASCII Boot Splash** (Verbose/Debug-friendly)
```bash
sudo ./scripts/apollo-os-boot-splash-installer.sh
```

See [docs/BOOT_SPLASH.md](docs/BOOT_SPLASH.md) for details.

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
- **[Boot Splash Options](docs/BOOT_SPLASH.md)** - Plymouth vs ASCII splash
- **[Brightness Fix](docs/BRIGHTNESS_FIX.md)** - Fix brightness control
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
