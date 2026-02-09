# Apollo OS v0.6.0

**Custom Linux Desktop Environment built on Fedora 43 with dual Wayland Window Manager support.**

Apollo OS provides two fully configured desktop experiences:

- **Apollo OS Orbit** — Based on [Niri](https://github.com/YaLTeR/niri) (scrolling tiling WM)
- **Apollo OS Glass** — Based on [Hyprland](https://hyprland.org/) (dynamic tiling WM with animations)

Both environments share a unified set of tools, security modules, and system services.

---

## Installation

### Requirements

- **Fedora 43** (clean/minimal install recommended)
- **x86_64** architecture
- Internet connection
- `sudo` access

### Quick Start

```bash
git clone https://github.com/apolloenv/apollo-os.git
cd apollo-os/apollo-os-v0600
chmod +x apollo-os-install.sh
sudo ./apollo-os-install.sh
```

### Optional: Bitdefender Security Tools

The Bitdefender RPM (~289 MB) exceeds GitHub's file size limit and is **not included** in the repository.
To install Bitdefender alongside Apollo OS:

1. Download the RPM from your [GravityZone Control Center](https://gravityzone.bitdefender.com) (Network → Packages → Linux)
2. Place it in `apollo-os-v0600/apollo-os-sys/packages/` before running the installer
3. The installer detects it automatically

> Apollo OS works fully without Bitdefender — all other 16 security modules are included.

### What the Installer Does

The installer will:
1. Ask which desktop(s) to install (Orbit / Glass / Both)
2. Ask for editor preference (Neovim / Fresh Editor / Both)
3. Install all packages, configs, and security modules (~20-40 min)
4. Configure the boot system (TTY login → WM selection)
5. Reboot into Apollo OS

### After Reboot

1. Log in at the TTY prompt
2. The boot sequence shows system status
3. Select your Window Manager (Orbit or Glass)
4. Desktop loads automatically

---

## Keybindings

### General (Both WMs)

| Shortcut | Action |
|----------|--------|
| `Super + Space` | App Launcher (Rofi) |
| `Super + Shift + Space` | Quick Action Menu |
| `Super + Return` | Terminal (Alacritty) |
| `Super + T` | Terminal (Ptyxis) |
| `Super + K` | Terminal (Kitty) |
| `Super + B` | Firefox |
| `Super + D` | File Manager (Nautilus) |
| `Super + N` | Text Editor |
| `Super + Q` | Close Window |
| `Super + F` | Fullscreen |
| `Super + W` | Toggle Floating |
| `Super + L` | Lock Screen (Hyprlock) |
| `Super + S` | Screenshot |
| `Print` | Screenshot |
| `Super + Shift + E` | Logout / Quit WM |

### Window Management (Orbit / Niri)

| Shortcut | Action |
|----------|--------|
| `Super + O` | Overview |
| `Super + M` | Maximize Column |
| `Super + C` | Toggle Center |
| `Super + G` | Toggle Gaps |
| `Super + J` | Toggle Dock |
| `Super + R` | Switch Column Width |
| `Super + E` | Consume/Expel Window |
| `Super + ←/→` | Focus Column Left/Right |
| `Super + ↑/↓` | Focus Window Up/Down |
| `Super + Alt + ←/→` | Move Column Left/Right |
| `Super + Alt + ↑/↓` | Move Window Up/Down |
| `Super + Ctrl + ←/→` | Resize Width ±10% |
| `Super + Ctrl + ↑/↓` | Resize Height ±10% |
| `Super + 1-9` | Switch Workspace |
| `Super + Shift + 1-9` | Move Window to Workspace |
| `Super + Shift + R` | Reload Infobar |

### System Shortcuts

| Shortcut | Action |
|----------|--------|
| `Super + Ctrl + Space` | Cycle Wallpaper |
| `Super + Ctrl + B` | Bluetooth Manager (TUI) |
| `Super + Ctrl + W` | WiFi Manager (TUI) |
| `Super + Ctrl + L` | Lock Screen (TTS) |
| `Super + Print` | Color Picker |
| `Alt + Print` | Screen Recording |
| `Super + V` | Voice Input (Whisper) |
| `Super + Shift + /` | Show Keybindings |

### Quick Menu (`Super + Shift + Space`)

- System Update (3 modes: System / Full Reinstall / Security Only)
- Visual Mode Switcher (18 themes)
- Power Profile (Performance / Balanced / Power Saver)
- Lock / Shutdown / Reboot / Logout
- Clipboard History
- Quick Notes
- System Health Dashboard
- Security Status

---

## What Gets Installed

### Desktop Environment

| Component | Package |
|-----------|---------|
| WM (Orbit) | Niri |
| WM (Glass) | Hyprland + Quickshell |
| Bar | Waybar |
| Launcher | Rofi (Wayland) |
| Notifications | Mako |
| Lock Screen | Hyprlock |
| Wallpaper | swaybg |
| Idle | swayidle |
| Terminal | Alacritty, Kitty, Ptyxis, Foot |
| File Manager | Nautilus |
| Browser | Firefox + Microsoft Edge |
| Editor | Neovim / Fresh Editor (optional) |
| Shell | Fish + Starship prompt |
| Screenshots | grim + slurp |
| Screen Recording | gpu-screen-recorder / wf-recorder |
| Clipboard | cliphist + wl-clipboard |
| Color Picker | hyprpicker |
| Screen Corners | screen-corners.py |

### Security Modules (17)

| Module | Description |
|--------|-------------|
| firewalld | Network firewall |
| fail2ban | Brute-force protection |
| ClamAV | Antivirus with auto-updates |
| rkhunter | Rootkit detection |
| Lynis | Security auditing |
| AIDE | File integrity monitoring |
| Kernel Hardening | sysctl security parameters |
| SSH Hardening | Secure SSH configuration |
| DNS-over-TLS | Encrypted DNS (Cloudflare + Quad9) |
| MAC Randomization | WiFi MAC address randomization |
| Auto-Updates | Automatic security patches (dnf-automatic) |
| Core Dump Restriction | Prevents memory dumps |
| Port Monitor | Network port surveillance |
| Security Audit | Daily automated security scan |
| Battery Monitor | Low battery warnings (TTS) |
| Disk Monitor | Disk space monitoring |
| Service Watchdog | Auto-restart critical services |

### Visual Modes (18 Themes)

Apollo Core · Code Forge · Command Center · Command Deck · Crystal Bay · Cyber Matrix · Deep Space · Frost Byte · Light Bridge · Neon Edge · Nova Pulse · Pixel Grid · Quantum Flux · Retro Wave · Silicon Dawn · Star Deck · Zen Flow · Command Deck Clean

Switch between themes via Quick Menu → Visual Mode.

### Additional Software

- **Office:** OnlyOffice (optional)
- **Media:** VLC, mpv
- **System:** btop, fastfetch, brightnessctl
- **Voice:** whisper.cpp (speech-to-text), edge-tts (text-to-speech)
- **Remote:** Remmina (RDP client)
- **Containers:** Docker + Podman
- **Fonts:** JetBrainsMono Nerd Font, Bibata cursor theme

---

## Project Structure

```
apollo-os-v0600/
├── apollo-os-install.sh          # Master installer (~2800 lines)
├── apollo-os-orbit/              # Niri "Orbit" configs
│   ├── base-config/              # Niri + Waybar base configs
│   ├── visual-modes/             # 18 visual themes
│   ├── scripts/                  # Toggle scripts
│   └── extras/                   # Hyprlock for Niri
├── apollo-os-glass/              # Hyprland "Glass" configs
│   ├── dots/                     # Dotfiles (.config/hypr, kitty, etc.)
│   ├── sdata/                    # Dependency management
│   └── setup/                    # Glass setup scripts
├── apollo-os-sys/                # Shared system components
│   ├── scripts/                  # 49 system scripts
│   ├── security/                 # Security configurations
│   ├── systemd/                  # Service files
│   ├── config/                   # Terminal + GTK configs
│   ├── sddm/                    # Login theme
│   ├── lib/                      # Shared bash library
│   └── assets/                   # Boot logo, sounds
└── docs/                         # Documentation
```

---

## Boot Flow

```
GRUB → Kernel (verbose) → Apollo Boot Splash → TTY Login
→ Boot Sequence (system checks) → WM Selection → Desktop
```

On logout, the system returns to the TTY login prompt.

---

## License

MIT

---

**Apollo OS** — Built by [apolloenv](https://github.com/apolloenv)
