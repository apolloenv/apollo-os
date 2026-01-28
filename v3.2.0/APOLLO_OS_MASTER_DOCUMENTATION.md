# 🚀 APOLLO OS - Master Documentation & Development Guide

**Version:** v3.1.0  
**Last Updated:** 2026-01-21  
**Status:** Active Development  
**Platform:** Fedora Linux 43+ / Wayland / Dual Desktop (Niri + Hyprland)  

---

## 📌 AI ASSISTANT INSTRUCTIONS - READ FIRST!

### **Critical Workflow Rules:**

1. **🎯 Task Management**
   - ALWAYS create TODO lists with `update_todo` for every task
   - Break complex tasks into smaller sub-tasks
   - Check off completed items
   - Update this document after every significant change

2. **🔄 Development Workflow**
   - **Local Testing FIRST**: All changes tested locally on apollo's system
   - **Wait for Approval**: Never push to GitHub without explicit "OK" from user
   - **Update Documentation**: Document changes in this file immediately
   - **Git Process**: Local → Test → Approval → Project → GitHub

3. **📝 Code Documentation**
   - All scripts must have header comments (purpose, usage, dependencies)
   - Complex functions need inline comments
   - Use meaningful variable names
   - Add examples in comments where helpful

4. **💡 Innovation & Optimization**
   - Proactively suggest improvements
   - Identify potential issues before they occur
   - Propose new features aligned with Apollo OS vision
   - Optimize existing code for performance/readability

5. **📚 Documentation Updates**
   - Update this master file after every session
   - Document new features in "Features" section
   - Add known issues to "Issues" section
   - Log all changes in "Development Log"

---

## 🔐 GitHub Repository Access

**Repository:** https://github.com/apolloenv/apollo-os  
**User:** apolloenv  
**Token:** `[STORED SECURELY - NOT IN REPO]`

### Git Commands:
```bash
cd /home/apollo/AIQSAN01/apollo/apollo-os-dev/apollo-os-github-clone
git add .
git commit -m "Description"
git push origin main
```

**Note:** GitHub credentials are stored in local git config and should never be committed to repository.

### Sync Process:
1. Copy changes from `/home/apollo/AIQSAN01/apollo/apollo-os-dev/v2.1.0/`
2. Use rsync to sync to git repo
3. Commit and push after user approval

---

## 📁 Project Structure

```
/home/apollo/AIQSAN01/apollo/apollo-os-dev/
├── v2.1.0/                          # Current development version
│   ├── apollo-os-install.sh         # Main installer (1458 lines)
│   ├── APOLLO_OS_MASTER_DOCUMENTATION.md  # This file
│   ├── docs-archive/                # Old documentation (42 files)
│   ├── assets/                      # Resources
│   │   ├── wallpapers/              # Wallpaper collection
│   │   ├── spinner/watermark.png    # Boot animation
│   │   └── apollo-os-boot-logo.txt  # ASCII art
│   ├── config-data/                 # Template configs
│   │   ├── niri/                    # Window manager configs
│   │   │   ├── config-classic.kdl
│   │   │   ├── config-developer.kdl
│   │   │   ├── config-modern.kdl    # Modern style (updated)
│   │   │   ├── config-orbit.kdl
│   │   │   └── config-professional.kdl
│   │   ├── waybar/                  # Status bar configs
│   │   │   ├── config-niri-modern   # Modern layout (Orbit-based)
│   │   │   ├── style-modern.css     # Transparent, full-width
│   │   │   └── [other visual modes]
│   │   ├── mako/                    # Notifications
│   │   ├── rofi/                    # Launcher
│   │   ├── alacritty/               # Terminal
│   │   └── btop/                    # System monitor
│   ├── scripts/                     # Apollo OS scripts (30+)
│   │   ├── apollo-wake-listener.py  # Voice control (Vosk)
│   │   ├── apollo-speak.sh          # TTS output
│   │   ├── apollo-os-*.sh           # System scripts
│   │   └── [29 other scripts]
│   ├── systemd/                     # System services
│   │   ├── apollo-wake.service      # Voice control service
│   │   └── apollo-os-sleep.service  # Sleep/wake TTS
│   ├── sounds/                      # Audio files
│   │   ├── sleep.mp3
│   │   └── wake.mp3
│   └── docs/                        # User documentation
├── apollo-os-github-clone/          # Git repository clone
└── [older versions v0.1.0 - v1.0.2]
```

---

## 🎨 Visual Modes (5 Styles)

### **1. Classic** - Traditional Clean Style
- Two bars (top/bottom)
- Minimalist design
- High contrast

### **2. Developer** - Code-Focused Layout
- Developer-centric information
- Git status integration
- Resource monitoring

### **3. Modern** ⭐ (Latest Update v2.1.0)
- **Single bar** (Orbit layout integrated)
- **100% transparent background**
- **Full width** (no margins)
- **12px border radius** on all modules
- All modules centered
- Drawers for additional info
- **Scale:** 1.0 (Orbit 1:1)

### **4. Orbit** - Cosmic Futuristic Theme
- Single centered bar
- Spacecraft-inspired design
- Dynamic module groups

### **5. Professional** - Business-Oriented Layout
- Corporate aesthetic
- Productivity-focused
- Clean information density

**Switch:** `apollo-os-visual-mode.sh [mode]` or Quick Menu (Super+Shift+Space)

---

## 🔊 Audio & Voice System

### **TTS (Text-to-Speech)**
- **Engine:** edge-tts (Microsoft Edge TTS)
- **Voice:** Amala (de-DE-AmalaNeural) - German, Female
- **Script:** `apollo-speak.sh <text>`
- **Config:** `~/.config/apollo-os/voice-config.env`

### **Voice Control (Wake Word System)**
- **Wake Word:** "apollo"
- **Engine:** Vosk (Offline Speech Recognition)
- **Model:** vosk-model-small-de-0.15 (German)
- **Script:** `apollo-wake-listener.py`
- **Service:** `apollo-wake.service` (systemd user service)
- **Status:** Auto-starts on login

#### Voice Commands (8 Predefined):
1. 🕐 **Uhrzeit**: "apollo wie spät ist es" / "apollo uhrzeit"
2. 📅 **Datum**: "apollo welcher tag ist heute" / "apollo datum"
3. 💻 **Terminal**: "apollo terminal öffnen"
4. 🌐 **Browser**: "apollo browser starten" / "apollo web starten"
5. 🔒 **Sperren**: "apollo sperren" / "apollo sperre"
6. 💤 **Ruhemodus**: "apollo ausschalten" / "apollo herunterfahren"
7. 🔄 **Neustart**: "apollo neustart" / "apollo neu starten"
8. 👋 **Status**: "apollo" (acknowledgment)

### **Gemini AI Integration (Optional - Local Only)**
- **Status:** NOT in standard installation
- **Location:** Local customization only
- **Documentation:** `docs-archive/GEMINI_AI_INTEGRATION.md`
- **Toggle:** Quick Menu → "🤖 Gemini AI Voice"
- **Flag File:** `~/.config/apollo-os/gemini-enabled`
- **Security:** No API keys in repository!

---

## 📦 Installation System

### **Main Installer:** `apollo-os-install.sh`
- **Version:** v3.1.0
- **Lines:** ~1700
- **Language:** Bash
- **Execution Time:** ~20-40 minutes (depending on desktop choice)
- **Root Required:** Yes (for system packages)
- **New:** Dual Desktop Support (Niri + Hyprland)

### Installation Steps:
1. **check_system()** - Verify Fedora 43+
2. **gather_user_config()** - User preferences
3. **select_desktop_environment()** ⭐ NEW - Choose Niri/Hyprland/Both
4. **install_packages()** - DNF packages (niri, waybar, hyprland, quickshell, etc.)
5. **configure_user_permissions()** - Groups, sudo
6. **verify_critical_packages()** - Check core tools
7. **deploy_configs()** - Copy configs (Niri + Hyprland if selected)
8. **copy_plymouth_watermark()** - Boot splash
9. **install_scripts()** - Copy scripts to ~/.local/bin/
10. **install_desktop_entries()** - WM session files
11. **setup_systemd()** - Enable services
12. **install_audio_system()** - edge-tts, TTS config
13. **install_voice_control()** - Vosk, wake word
14. **install_fresh_editor()** - Fresh text editor
15. **install_flatpak_apps()** - Flatpak applications
16. **setup_wallpapers()** - Copy wallpaper collection
17. **configure_login_manager()** ⭐ UPDATED - Install selected sessions
18. **finalize_installation()** - Cleanup, summary

### Desktop Environment Options:
- **Apollo OS Glass** (Hyprland) - Transparent, modern design with Quickshell
- **Apollo OS Orbit** (Niri) - Scrollable tiling with Waybar
- **Both** - Dual desktop setup with session selection at login

### Core Packages Installed:

**Niri Desktop (Orbit):**
```
Window Manager: niri (0.1.10+)
Status Bar: waybar
Terminal: alacritty, ptyxis
Notifications: mako
Launcher: rofi
Lock Screen: swaylock
```

**Hyprland Desktop (Glass):**
```
Window Manager: hyprland
UI Shell: quickshell (Qt6-based)
Status Bar: Integrated in Quickshell
Terminal: kitty, alacritty
Notifications: Quickshell notifications
Launcher: rofi
```

**Shared Components:**
```
Background: swaybg
Idle Management: swayidle
Screenshot: grim, slurp
Brightness: brightnessctl
Audio: pipewire, wireplumber, pavucontrol
Fonts: JetBrainsMono Nerd Font, Material Icons
Browser: firefox, microsoft-edge-stable
File Manager: nautilus
Text Editor: gnome-text-editor, Fresh Editor
System Monitor: btop
Python: python3, pip, vosk, sounddevice
TTS: edge-tts
```

### Flatpak Apps:
- ImageRoll (image viewer)
- Celluloid (video player)
- Flatseal (permissions)
- Fragments (torrent)
- Extension Manager
- Font Downloader
- Warp (file sharing)
- Warehouse (Flatpak cleaner)

---

## ⌨️ Keyboard Shortcuts

### Window Management
- `Super+Q` - Close window
- `Super+W` - Toggle floating
- `Super+F` - Fullscreen
- `Super+M` - Maximize column
- `Super+C` - Toggle center
- `Super+R` - Cycle preset widths

### Navigation
- `Super+Left/Right` - Focus window
- `Super+Up/Down` - Focus workspace
- `Super+1-9` - Jump to workspace

### Applications
- `Super+Space` - Launcher
- `Super+Shift+Space` - Quick Menu
- `Super+Return` - Terminal (Alacritty)
- `Super+T` - Terminal (Ptyxis)
- `Super+B` - Browser (Firefox)
- `Super+D` - Files (Nautilus)
- `Super+N` - Text Editor

### System
- `Super+L` - Lock screen
- `Super+Shift+E` - Logout
- `Super+S` - Screenshot (area)

### Audio
- `XF86AudioRaiseVolume` - Volume up
- `XF86AudioLowerVolume` - Volume down
- `XF86AudioMute` - Mute toggle

---

## 🛠️ System Scripts (30+)

### Core Scripts:
- **apollo-speak.sh** - TTS wrapper
- **apollo-wake-listener.py** - Voice control main
- **apollo-os-quickmenu.sh** - Quick actions menu
- **apollo-os-visual-mode.sh** - Switch visual styles
- **apollo-os-rofi-launcher.sh** - Application launcher
- **apollo-os-wallpaper-cycle.sh** - Change wallpaper
- **apollo-os-power-profile.sh** - Power management
- **apollo-os-lock.sh** - Lock screen
- **apollo-os-scale-setter.sh** - Display scaling

### System Monitors:
- **apollo-os-power-monitor.sh** - Battery notifications
- **apollo-os-network-monitor.sh** - Network status
- **apollo-os-sleep-monitor.sh** - Sleep/wake events
- **apollo-os-event-monitor.sh** - System event handler

### Audio/TTS:
- **apollo-os-tts-notify.sh** - Event announcements
- **apollo-os-voice-switcher.sh** - Change TTS voice
- **apollo-os-welcome-tts.sh** - Login greeting

### Utilities:
- **apollo-os-stats.sh** - System statistics
- **apollo-os-update.sh** - Update Apollo OS from GitHub
- **apollo-os-brightness-fix.sh** - Fix brightness controls
- **apollo-os-shortcuts.sh** - Show keybindings

---

## ✅ Implemented Features (v2.1.0)

### Window Management
- ✅ Niri window manager (scrollable tiling)
- ✅ 5 visual modes with different layouts
- ✅ Dynamic workspace management
- ✅ Floating window support
- ✅ Fullscreen mode
- ✅ Window centering

### User Interface
- ✅ Waybar status bar (5 style variants)
- ✅ Rofi launcher with custom styling
- ✅ Mako notifications
- ✅ GTK dark theme (adw-gtk3-dark)
- ✅ Custom wallpaper collection (40+ images)
- ✅ Wallpaper cycling
- ✅ Display scaling (1.0, 1.25, 1.5, 2.0)

### Audio System
- ✅ PipeWire audio
- ✅ TTS with edge-tts (Amala voice)
- ✅ Voice control with Vosk wake word
- ✅ 8 predefined voice commands
- ✅ Sleep/wake audio feedback
- ✅ System event announcements

### System Integration
- ✅ greetd login manager with gtkgreet
- ✅ Plymouth boot splash
- ✅ Systemd services for monitoring
- ✅ Power profile management
- ✅ Network monitoring
- ✅ Battery notifications
- ✅ Brightness control fix

### Applications
- ✅ Microsoft Edge browser
- ✅ Firefox browser
- ✅ Alacritty & Ptyxis terminals
- ✅ Fresh Editor (text editor)
- ✅ GNOME Text Editor
- ✅ Nautilus file manager
- ✅ btop system monitor
- ✅ 8+ Flatpak apps

### Development Tools
- ✅ Git integration
- ✅ Docker support
- ✅ Winboat (Windows VM manager)
- ✅ Python 3 environment
- ✅ Quick Menu for common tasks
- ✅ Config editor access

---

## 🐛 Known Issues & Limitations

### Critical (Must Fix)
- None currently

### Medium Priority
- **Brightness Control**: Requires kernel parameter (documented workaround exists)
- **XWayland Apps**: Some apps need special handling (e.g., Synology Drive)
- **Multiple Monitors**: Scaling needs reconnection to apply

### Low Priority
- **Voice Control**: Limited to predefined commands (by design)
- **Boot Splash**: Sometimes flickers on some hardware
- **Font Rendering**: May need tweaking on HiDPI displays

### Workarounds Documented
- Brightness fix: `scripts/apollo-os-brightness-fix.sh`
- XWayland: `xwayland-satellite` service running
- Synology Drive: Desktop entry with XWayland flag

---

## 💡 Ideas for Future Development

### High Priority
1. **🎨 Theme System**
   - User-customizable color schemes
   - Light/dark mode toggle
   - Per-app theme settings

2. **🔄 Update System**
   - Automatic update checking
   - Rollback functionality
   - Version management

3. **📱 Mobile Device Integration**
   - KDE Connect support
   - Phone notifications
   - File sharing

### Medium Priority
4. **🪟 Window Rules**
   - Per-app floating rules
   - Workspace assignments
   - Size/position presets

5. **🔌 Plugin System**
   - User-installable extensions
   - Custom scripts integration
   - Community contributions

6. **📊 System Monitoring**
   - Resource usage graphs
   - Performance analytics
   - Health checks

### Low Priority
7. **🎮 Gaming Mode**
   - Optimized performance profile
   - Disable notifications
   - Full-screen window rules

8. **🌍 Multi-language Support**
   - UI translations
   - TTS language switching
   - Voice commands in other languages

9. **🎨 Waybar Widgets**
   - Weather widget
   - Calendar integration
   - Crypto/stock ticker

---

## 🔧 Configuration Files

### Niri (Window Manager)
**Location:** `~/.config/niri/config.kdl`  
**Templates:** `config-data/niri/config-[mode].kdl`

Key sections:
- `input` - Keyboard, mouse, touchpad
- `output` - Monitor configuration, scaling
- `layout` - Gaps, borders, columns
- `binds` - Keyboard shortcuts
- `window-rule` - Per-app rules
- `spawn-at-startup` - Autostart apps

### Waybar (Status Bar)
**Config:** `~/.config/waybar/config-niri`  
**Style:** `~/.config/waybar/style.css`  
**Templates:** `config-data/waybar/`

Modules used:
- niri/workspaces
- clock, battery, network
- CPU, memory, disk, temperature
- Custom modules (power profile, hostname, etc.)

### Quickshell Bar (Hyprland/Glass)
**Main Config:** `~/.config/illogical-impulse/config.json`  
**Quickshell Modules:** `~/.config/quickshell/ii/modules/`

**Key Configuration Files:**
```
~/.config/quickshell/ii/modules/common/Config.qml       # Default settings
~/.config/quickshell/ii/modules/ii/bar/BarContent.qml   # Bar layout & spacing
~/.config/quickshell/ii/modules/ii/bar/SysTray.qml      # System tray (separator)
~/.config/quickshell/ii/modules/ii/bar/UtilButtons.qml  # Utility buttons
~/.config/hypr/hyprland/keybinds.conf                   # Keybindings
~/.config/hypr/custom/keybinds.conf                     # Custom keybindings
```

**Apollo OS Bar Customizations:**
- `showPerformanceProfileToggle: false` - Performance icon hidden
- `showDarkModeToggle: false` - Dark mode toggle hidden  
- `showSeparator: false` - SysTray dot separator hidden
- `verbose: false` - Empty UtilButtons hidden
- `spacing: 4` - Reduced bar element spacing (line 187 in BarContent.qml)
- `Super+O` → Workspace Overview (`qs ipc call search toggle`)

**Reload Quickshell:** `Super+Shift+R`

### Voice Control
**Script:** `~/.local/bin/apollo-wake-listener.py`  
**Service:** `~/.config/systemd/user/apollo-wake.service`  
**Model:** `~/.local/share/vosk-models/vosk-model-small-de-0.15/`

### TTS Configuration
**Config:** `~/.config/apollo-os/voice-config.env`
```bash
CURRENT_VOICE="🇩🇪 AMALA - Deutsch Weiblich"
VOICE_ENGINE="edge-tts"
VOICE_MODEL="de-DE-AmalaNeural"
```

---

## 🚀 Development Workflow

### Starting a New Feature

1. **Create TODO List**
```markdown
- [ ] Research requirements
- [ ] Design implementation
- [ ] Write code with documentation
- [ ] Test locally on apollo's system
- [ ] Get user approval
- [ ] Update APOLLO_OS_MASTER_DOCUMENTATION.md
- [ ] Sync to project
- [ ] Push to GitHub
```

2. **Local Testing**
- All changes made to `~/.config/` or `~/.local/bin/` first
- User tests functionality
- Iterate based on feedback

3. **Project Integration**
- Copy to `/home/apollo/AIQSAN01/apollo/apollo-os-dev/v2.1.0/`
- Verify file structure
- Test installer if needed

4. **GitHub Push**
- Sync to `apollo-os-github-clone/`
- Commit with descriptive message
- Push after explicit user approval

### Code Documentation Standards

```bash
#!/bin/bash

#####################################################################
# Apollo OS - [Script Name]
# Copyright © 2025 by Manuel Kraibacher
#
# Description: [What this script does]
# Usage: [How to use it]
# Dependencies: [Required packages/tools]
# Version: [Version number]
#####################################################################

# Global variables
VARIABLE_NAME="value"  # Description of what this is

# Function description
function_name() {
    local param=$1  # Description of parameter
    
    # Implementation with inline comments for complex logic
    if [[ condition ]]; then
        # Explain why this check is needed
        action
    fi
    
    return 0
}

# Main execution
main() {
    function_name "argument"
}

main "$@"
```

---

## 📝 Development Log

### 2026-01-21 (v3.1.0 - Dual Desktop Release) 🎉

#### **Major Feature: Dual Desktop Support**
- ✅ Integrated Hyprland (Apollo OS Glass) alongside Niri (Apollo OS Orbit)
- ✅ Created `apollo-os-professional/` folder with complete Hyprland setup
- ✅ Implemented desktop selection during installation (Niri/Hyprland/Both)
- ✅ Session files for both desktops (apollo-os-glass.desktop, apollo-os-orbit.desktop)
- ✅ Updated greetd login manager to show both session options

#### **Hyprland Integration**
- ✅ Added Hyprland package installation (hyprland, hyprland-guiutils, xdg-desktop-portal-hyprland)
- ✅ Integrated Quickshell (Qt6-based UI shell) with build process
- ✅ COPR repos added: ririko66z/dots-hyprland, sdegler/hyprland, deltacopy/darkly
- ✅ Config deployment for Hyprland + Quickshell (illogical-impulse dots)
- ✅ Custom Apollo OS Professional customizations applied:
  - German keyboard layout
  - Window transparency (90% active, 40% inactive)
  - No borders, enhanced shadows
  - "APOLLO OS" branding in bar
  - Weather widget integration
  - Custom shortcuts (Super+K for cheatsheet)

#### **Installer Enhancements (apollo-os-install.sh)**
- ✅ Added `select_desktop_environment()` function with 3 options
- ✅ Expanded `install_packages()` with Hyprland-specific packages
- ✅ Enhanced `deploy_configs()` to handle Hyprland configs conditionally
- ✅ Updated `configure_login_manager()` to install both session files
- ✅ Full automation: all `-y` flags added to dnf/copr commands
- ✅ Version bumped to v3.1.0 with comprehensive changelog

#### **Project Structure Updates**
- ✅ New folder: `v3.1.0/` (based on v2.1.0)
- ✅ New folder: `v3.1.0/apollo-os-professional/` (Hyprland configs)
- ✅ New files: `config-data/wayland-sessions/apollo-os-glass.desktop`
- ✅ Updated: `config-data/greetd/environments` (both desktops listed)
- ✅ Documentation: `apollo-os-professional.md` with all Hyprland customizations

#### **Documentation Updates**
- ✅ Master documentation updated to v3.1.0
- ✅ Documented dual desktop architecture
- ✅ Installation steps updated (new step 3: select_desktop_environment)
- ✅ Package lists separated by desktop (Niri vs Hyprland vs Shared)
- ✅ Session selection workflow documented

### 2026-01-20 (v2.1.0 Release)

#### Voice Control Integration
- ✅ Added `install_voice_control()` to installer
- ✅ Installs Python dependencies (vosk, sounddevice)
- ✅ Downloads German Vosk model automatically
- ✅ Creates systemd service for autostart
- ✅ Documented in GEMINI_AI_INTEGRATION.md

#### Modern Visual Mode Update
- ✅ Adopted Orbit layout (single centered bar)
- ✅ Made waybar 100% transparent
- ✅ Full width (removed all margins)
- ✅ 12px border radius on all modules
- ✅ Updated both local and project configs
- ✅ Synced to GitHub

#### Documentation Consolidation
- ✅ Created `docs-archive/` folder
- ✅ Moved 42 old .md files to archive
- ✅ Created this master documentation file
- ✅ Included AI assistant instructions
- ✅ Documented entire project structure

#### Gemini Integration (Local Only)
- ✅ Added Quick Menu toggle option
- ✅ Flag-based enable/disable system
- ✅ Documented in separate .md (no code in repo)
- ✅ Security guidelines established

### Future Sessions
*New entries will be added here with date, changes, and context*

---

## 🎯 Current Development Goals

### Immediate (This Week)
- ✅ Voice control fully integrated
- ✅ Modern visual mode finalized
- ✅ Documentation consolidated
- ✅ Dual Desktop Support (v3.1.0) 🎉
- ⏳ Test v3.1.0 on fresh installation (Niri + Hyprland)

### Short-term (This Month)
- [ ] Create installation video/tutorial (dual desktop setup)
- [ ] Hyprland-specific wallpapers & themes
- [ ] Optimize startup time for both desktops
- [ ] Community feedback collection
- [ ] Performance comparison (Niri vs Hyprland)

### Long-term (This Quarter)
- [ ] Plugin system architecture
- [ ] Theme customization tool
- [ ] Mobile device integration
- [ ] Performance profiling

---

## 📚 Additional Resources

### Documentation Files (In Archive)
- **APOLLO_OS_BENUTZERHANDBUCH.md** - User manual (German)
- **INSTALLATION.md** - Installation guide
- **KEYBINDINGS.md** - Keyboard shortcuts reference
- **AUDIO_SYSTEM.md** - TTS architecture
- **FAQ.md** - Frequently asked questions
- **GEMINI_AI_INTEGRATION.md** - Optional AI voice feature

### External Resources
- **Niri Documentation**: https://github.com/YaLTeR/niri
- **Waybar Documentation**: https://github.com/Alexays/Waybar
- **Vosk API**: https://alphacephei.com/vosk/
- **Edge TTS**: https://github.com/rany2/edge-tts

---

## 🤝 Contributing Guidelines (Internal)

### For AI Assistant:
1. Always read this file first when starting a new session
2. Check "Development Log" for latest changes
3. Review "Current Development Goals" for priorities
4. Create TODO lists for every task
5. Update this file after every significant change
6. Test locally before committing to project
7. Wait for user approval before GitHub push
8. Document all code thoroughly
9. Suggest improvements proactively
10. Keep this document as single source of truth

### For Future Developers:
- Follow existing code style
- Document all changes in this file
- Test on clean Fedora 43 installation
- Never commit API keys or secrets
- Use descriptive commit messages
- Keep installer modular and maintainable

---

## 📞 Support & Contact

**Developer:** Manuel Kraibacher  
**Project:** Apollo OS  
**Repository:** https://github.com/apolloenv/apollo-os  
**Version:** v2.1.0  
**Platform:** Fedora Linux 43+ / Niri WM  

---

## 📄 License & Copyright

Copyright © 2025 by Manuel Kraibacher  
All rights reserved.

---

**END OF MASTER DOCUMENTATION**

*This document serves as the single source of truth for Apollo OS development. Always keep it updated and refer to it at the start of each development session.*
