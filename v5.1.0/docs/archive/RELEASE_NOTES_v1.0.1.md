# Apollo OS v1.0.1 - Release Notes

**Release Date**: January 15, 2026  
**Type**: Major Feature Release  
**Status**: Production Ready

---

## 🎯 Overview

Apollo OS v1.0.1 represents a significant upgrade to the desktop environment, bringing enterprise-grade features, extensive software integration, and enhanced user controls. This release incorporates production-tested configurations and adds over 30 new applications.

---

## 🌟 Highlights

### Display Management Revolution
- **Installation-time Scaling**: Choose your preferred display scale (1.0x - 2.0x) during setup
- **Dual Monitor Support**: Separate scaling controls for internal and external displays
- **Live Configuration**: Quick Menu integration for on-the-fly adjustments

### Enhanced User Experience
- **Keyboard Shortcuts Viewer**: Press ⌨️ in Quick Menu to see all shortcuts
- **Window Centering**: Toggle with Super+C for better focus
- **Power Profile Clarity**: Clear descriptions instead of technical names
- **Integrated Web Search**: Press Alt+Enter in launcher to search web instantly
- **Automatic Winboat Setup**: Windows VM manager installed automatically

### Professional Software Suite
- **Development**: Docker, Neovim, VSCodium, NetBeans, Eclipse
- **Creativity**: GIMP, Blender, Kdenlive, Audacity
- **Productivity**: OnlyOffice, Obsidian, Xournal++
- **Virtualization**: Winboat Windows VM manager with full KVM support

---

## 📋 What's New

### Installation & Setup
```bash
✓ Interactive display scaling selection (1.0, 1.25, 1.5, 2.0)
✓ Automated Flatpak application installation (30+ apps)
✓ Docker setup with proper user permissions
✓ Qt Wayland support for better app compatibility
✓ zsh shell installation
```

### Quick Menu Enhancements
```
⚡ Power Profiles    - Clear descriptions (Power Saver/Balanced/Performance)
🔍 Display Scaling   - Internal display (1.0-2.0x)
🖥️  External Monitor  - Separate external display scaling
⌨️  Shortcuts        - View all keyboard shortcuts
```

### App Launcher & Web Search
```
Super+Space          - Launch applications
Alt+Enter            - Search web (while in launcher)
                       Type query and press Alt+Enter
                       Opens in default browser
```

### New Applications (Flatpak)

**Development & IDEs**
- NetBeans, Eclipse, VSCodium, Geany
- Meld (diff viewer), Devhelp (API docs)

**Multimedia & Creativity**
- VLC Media Player, Kdenlive (video), Audacity (audio)
- GIMP, Blender, ImageRoll, Image Upscaler

**Browsers & Communication**
- Brave Browser, Zen Browser, Tor Browser
- Slack, Telegram, Discord

**Productivity**
- OnlyOffice Suite, Obsidian Notes
- Xournal++ (PDF annotation), Adobe Reader
- Biblioteca (document manager)

**Utilities**
- LocalSend (local file sharing)
- VideoDownloader, Speedtest, WhatIP
- Warehouse (Flatpak manager)
- Ptyxis (modern terminal)

**Remote & Virtualization**
- AnyDesk, Remmina (with RDP plugin)
- Winboat (Windows VM manager - auto-installed)
- Docker with full container support

### Configuration Upgrades
- 6 Niri config variants (Classic, Developer, Modern, Orbit, Professional + base)
- 6 Waybar configurations with matching CSS styles
- Production-tested Rofi theme
- All configs imported from working production system

### New Scripts
```bash
apollo-os-shortcuts.sh        # Display keyboard shortcuts in Rofi
apollo-os-web-search.sh       # Web search with browser detection
apollo-os-rofi-launcher.sh    # Smart launcher (Alt+Enter for web search)
toggle-center.sh              # Window centering toggle (Super+C)
```

---

## 🔧 Technical Details

### System Requirements
- Fedora 43 (recommended)
- Wayland-compatible GPU
- 8GB+ RAM recommended (16GB for Winboat/VMs)
- 50GB+ disk space (for full software suite)

### New Dependencies
```bash
# Qt Wayland Support
qt5-qtwayland, qt6-qtwayland

# Docker & Containers
docker-ce, docker-ce-cli, containerd.io
docker-buildx-plugin, docker-compose-plugin

# Virtualization (Winboat)
qemu-kvm, libvirt, virt-manager
bridge-utils, freerdp

# Additional Tools
neovim, zsh, vlc, gnome-podcasts
remmina-plugins-rdp
```

### Permission Management
```bash
# Automatically configured during installation
video group    - Brightness control
input group    - Input device access
docker group   - Container management
libvirt group  - Virtual machine management
```

---

## 📊 Comparison with v0.5.0

| Feature | v0.5.0 | v1.0.1 |
|---------|--------|--------|
| Display Scaling | Manual config | Interactive setup + Quick Menu |
| Flatpak Apps | None | 30+ applications |
| Power Profiles | Basic | Enhanced with descriptions |
| Shortcuts Display | External docs | In-app viewer (Rofi) |
| Window Centering | Manual | Super+C toggle |
| Web Search | No | Alt+Enter in launcher |
| Docker Support | No | Yes (full) |
| Winboat | No | Yes (auto-installed) |
| Qt Wayland | No | Yes |
| Config Variants | 2 | 6 (all styles) |

---

## 🚀 Installation

### Fresh Install
```bash
git clone https://github.com/apolloenv/apollo-os.git
cd apollo-os/v1.0.1
chmod +x apollo-os-install.sh
./apollo-os-install.sh
```

### Upgrade from v0.5.x
**Note**: Clean installation recommended due to extensive configuration changes.

Backup your data and perform fresh installation.

---

## ⚠️ Known Limitations

1. **External Monitor Scaling**: Requires monitor reconnection to apply
2. **Docker & libvirt Groups**: Require re-login after installation
3. **Winboat Download**: Requires internet connection during installation

---

## 🎓 Usage Tips

### Display Scaling
```bash
# During installation
- Choose 1.25x for 1080p displays
- Choose 1.5x or 2.0x for 4K displays

# Change later via Quick Menu
Super+Shift+Space → Display Scaling
```

### Power Profiles
```bash
# Access via Quick Menu
Super+Shift+Space → Power Profiles

Modes:
🔋 Power Saver    - Maximize battery life
⚖️  Balanced       - Default balanced mode
⚡ Performance    - Maximum performance
```

### Keyboard Shortcuts
```bash
# View all shortcuts
Super+Shift+Space → Keyboard Shortcuts

# App Launcher with Web Search
Super+Space           - App Launcher
Alt+Enter             - Search web (in launcher)

# Most important
Super+C               - Toggle Window Centering
Super+Shift+Space     - Quick Menu
Super+L               - Lock Screen
```

---

## 📝 Configuration

### Display Scaling Config
```bash
# Edit after installation
nano ~/.config/apollo-os/config.env

# Add/modify
DISPLAY_SCALE="1.25"
```

### Quick Menu Access
```bash
# Keybinding
Super+Shift+Space

# Script location
~/.local/bin/apollo-os-quickmenu.sh
```

---

## 🐛 Bug Fixes from v0.5.x

- Fixed power profile display names
- Corrected external monitor scaling
- Improved Niri config deployment
- Fixed script permissions
- Enhanced error handling in installation

---

## 💡 Future Roadmap

- [ ] Additional Niri configuration presets
- [ ] Enhanced multi-monitor management
- [ ] Configuration migration tool
- [ ] Winboat integration improvements

---

## 👥 Credits

**Development**: Manuel Kraibacher  
**Copyright**: © 2026 Apollo OS Project  
**License**: MIT

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/apolloenv/apollo-os/issues)
- **Documentation**: See `docs/` directory
- **Configuration**: `~/.config/apollo-os/config.env`

---

**Enjoy Apollo OS v1.0.1! 🚀**
