# Apollo OS v5.1.0

## 🏗️ Directory Structure

Apollo OS v5.1.0 features a clean, organized directory structure:

```
v5.1.0/
├── apollo-os-orbit/        # Niri Window Manager (Orbit Edition)
│   ├── base-config/        # Base configurations
│   │   ├── niri/           # Niri configs
│   │   ├── waybar/         # Waybar configs
│   │   ├── mako/           # Notification configs
│   │   └── rofi/           # Application launcher
│   ├── visual-modes/       # 16 visual themes
│   │   ├── configs/        # Niri theme configs
│   │   ├── waybar/         # Waybar themes
│   │   └── mako/           # Notification themes
│   ├── scripts/            # Niri-specific scripts
│   └── extras/             # Additional features
│       ├── hyprlock/       # Lock screen configs
│       ├── dock/           # macOS-style dock
│       └── sounds/         # Audio feedback
│
├── apollo-os-glass/        # Hyprland Window Manager (Glass Edition)
│   ├── dots/               # Hyprland dotfiles
│   ├── dots-extra/         # Additional configs
│   └── sdata/              # Setup data
│
└── apollo-os-sys/          # Shared System Components
    ├── assets/             # Wallpapers, icons, boot logos
    ├── config/             # System-wide configs
    ├── scripts/            # Voice control & utilities
    ├── sounds/             # System sounds
    └── systemd/            # System services
```

## Release Notes

### New Features

#### Visual Modes System
This release includes the complete Visual Modes system with 16 unique themes:

- **Classic** - Traditional desktop look
- **Developer** - Dark theme for coding
- **Enterprise** - Professional business appearance
- **i3** - Tiling WM inspired design
- **i3-retro** - Vintage i3 style
- **i3-contrast** - High contrast i3 variant
- **Minimal** - Ultra-clean minimalist
- **Modern** - Contemporary rounded design
- **Nova** - Vibrant colorful theme
- **Orbit** - Space-inspired dark theme
- **Professional** - Clean professional look
- **Professional-Next** - Enhanced professional
- **Professional-Plus** - Premium professional variant
- **SGI** - Silicon Graphics inspired retro
- **Tech-Blue** - Technology-focused blue theme
- **macOS** - macOS Sequoia inspired design (NEW)

#### macOS Mode (New)
A complete macOS Sequoia-inspired visual experience:
- Transparent menubar with Apple logo
- macOS-style dock at bottom
- 26px rounded window corners
- 50% transparency for inactive windows
- Strong shadows for depth effect
- Bounce animations (spring-based)
- macOS-styled Mako notifications
- Kora icon theme integration
- White text throughout UI
- Dark GTK theme integration

#### Dock Applications
The macOS dock includes quick access to:
- Kitty Terminal
- Alacritty Terminal
- Files (Nautilus)
- Fresh Text Editor
- Remmina Remote Desktop
- Microsoft Edge
- VS Code
- Neovim
- OnlyOffice
- Google Search

### Directory Structure

```
v5.1.0/
├── apollo-os-install.sh        # Main installer
├── visual-modes/               # NEW: All visual mode configs
│   ├── niri/                   # Niri WM configurations
│   ├── waybar/
│   │   ├── configs/            # Waybar JSON configs
│   │   └── styles/             # Waybar CSS styles
│   ├── dock/                   # macOS dock configs
│   ├── mako/                   # Notification configs
│   └── scripts/                # Helper scripts
├── scripts/                    # System scripts
├── config/                     # Base configurations
├── docs/                       # Documentation
└── systemd/                    # Systemd services
```

### Keyboard Shortcuts (macOS Mode)

| Shortcut | Action |
|----------|--------|
| Super+Space | App Launcher (Rofi) |
| Super+Shift+Space | Quick Menu |
| Super+J | Toggle Dock |
| Super+O | Overview (Mission Control) |
| Super+Q | Close Window |
| Super+M | Maximize |
| Super+F | Fullscreen |

### Installation

```bash
# Run the installer
./apollo-os-install.sh

# Or manually copy visual modes
cp -r visual-modes/niri/* ~/.config/niri/
cp -r visual-modes/waybar/configs/* ~/.config/waybar/
cp -r visual-modes/waybar/styles/* ~/.config/waybar/
cp -r visual-modes/dock/* ~/.config/waybar/
cp -r visual-modes/mako/* ~/.config/mako/
cp visual-modes/scripts/* ~/.local/bin/
```

### Requirements

- Niri Window Manager
- Waybar
- Mako Notification Daemon
- Rofi
- Kora Icon Theme (for macOS mode)
- SF Pro Display Font (optional, for macOS mode)

### Credits

Copyright 2025 by Manuel Kraibacher
Apollo OS Project

### Changelog

- Added 16 visual modes with complete configurations
- Added macOS Sequoia-inspired theme
- Added macOS-style dock with Kora icons
- Added visual mode switcher script
- Added mode-specific Mako notification styles
- Improved animation system with spring-based bounces
- Added Voice Input with Whisper.cpp (Super+V)
- Added Right Ctrl Push-to-Talk support
- Added Wake Word "Apollo" voice assistant (Vosk)
- Added Hyprlock for Niri (Super+L + Laptop lid close)
- Added KDE System Settings installation for Niri
- Added optional Flatpak applications installation
- Added sound feedback for voice input (start/end)
