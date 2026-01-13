# 🚀 Apollo OS v0.4.1

**Modern Wayland Desktop with AI Integration**

A custom Fedora 43 Workstation overlay featuring dual window managers (Niri/Sway), hybrid AI engine (Gemini + Ollama), and integrated Text-to-Speech system.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Fedora](https://img.shields.io/badge/Fedora-43-blue.svg)](https://getfedora.org/)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-green.svg)]()

---

## ✨ Features

- 🪟 **Dual Window Managers**: Niri (Scrollable) + Sway (i3-style)
- 🤖 **Hybrid AI Engine**: Gemini + Ollama with graceful degradation
- 🔊 **Integrated TTS**: LUNA Voice with system announcements
- 🎨 **Dark/Light Themes**: Complete theme system
- ⚡ **Quick Actions**: Super+Shift+Space (13 actions)
- 🖼️ **69+ Wallpapers**: Auto-cycling wallpaper system
- 📱 **Telegram Integration**: Remote control
- 🔐 **Secure**: Sandboxed systemd services

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

**Required:**
```bash
GEMINI_API_KEY="YOUR_KEY"  # Get from https://ai.google.dev/
```

**Optional:**
```bash
TELEGRAM_BOT_TOKEN="YOUR_TOKEN"
TELEGRAM_USER_ID="YOUR_ID"
```

---

## ⌨️ Essential Keybindings

| Key | Action |
|-----|--------|
| `Super + Space` | Rofi Launcher |
| `Super + Shift + Space` | Quick Menu |
| `Super + Ctrl + Space` | Cycle Wallpaper |
| `Super + Return` | Terminal |
| `Super + L` | Lock Screen |

**[→ Full Documentation](APOLLO_OS_BENUTZERHANDBUCH.md)**

---

## 📖 Documentation

- **[Complete User Manual](APOLLO_OS_BENUTZERHANDBUCH.md)** (35 KB, German)
- **[All Keybindings](APOLLO_OS_BENUTZERHANDBUCH.md#tastenkürzel-keybindings)** (60+ shortcuts)
- **[Package List](PAKET_VERFUEGBARKEIT_FEDORA43.md)** (48 packages verified)
- **[Recent Fixes](FIXES_APPLIED.md)** (v0.4.1 improvements)

---

## 🤖 AI Commands

```bash
apollo-chat                          # AI Chat
??                                   # Natural language shell
apollo-speak "Hello World"          # Text-to-Speech
```

---

## 📜 License

MIT License - Copyright © 2026 Manuel Kraibacher

---

**Made with ❤️ in Austria | Powered by AI 🤖**
