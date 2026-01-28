# Apollo OS Visual Modes

## Overview

Apollo OS includes 16 unique visual modes that can be switched on-the-fly using the Quick Menu (Super+Shift+Space) or the visual-mode.sh script.

## Available Modes

| Mode | Description |
|------|-------------|
| **Classic** | Traditional desktop look with standard colors |
| **Developer** | Dark theme optimized for coding |
| **Enterprise** | Professional business appearance |
| **i3** | Tiling WM inspired minimal design |
| **i3-retro** | Retro i3 style with vintage colors |
| **i3-contrast** | High contrast i3 variant |
| **Minimal** | Ultra-clean minimalist design |
| **Modern** | Contemporary rounded design with shadows |
| **Nova** | Vibrant and colorful theme |
| **Orbit** | Space-inspired dark theme |
| **Professional** | Clean professional appearance |
| **Professional-Next** | Enhanced professional with modern touches |
| **Professional-Plus** | Premium professional variant |
| **SGI** | Silicon Graphics inspired retro theme |
| **Tech-Blue** | Technology-focused blue theme |
| **macOS** | macOS Sequoia inspired design with dock |

## Directory Structure

```
visual-modes/
├── niri/           # Niri window manager configs
├── waybar/
│   ├── configs/    # Waybar JSON configurations
│   └── styles/     # Waybar CSS styles
├── dock/           # macOS-style dock (waybar)
├── mako/           # Notification daemon configs
├── hyprlock/       # Lock screen configs
├── voice-input/    # Voice input with Whisper
├── sounds/         # Sound effects
└── scripts/        # Helper scripts
```

## Installation

Copy the configs to your home directory:

```bash
# Niri configs
cp visual-modes/niri/* ~/.config/niri/

# Waybar configs
cp visual-modes/waybar/configs/* ~/.config/waybar/
cp visual-modes/waybar/styles/* ~/.config/waybar/

# Dock (macOS mode)
cp visual-modes/dock/* ~/.config/waybar/

# Mako configs
cp visual-modes/mako/* ~/.config/mako/

# Scripts
cp visual-modes/scripts/apollo-os-visual-mode.sh ~/.local/bin/
cp visual-modes/scripts/apollo-os-lock*.sh ~/.local/bin/
cp visual-modes/scripts/toggle-*.sh ~/.config/niri/
chmod +x ~/.local/bin/apollo-os-visual-mode.sh
chmod +x ~/.local/bin/apollo-os-lock*.sh
chmod +x ~/.config/niri/toggle-*.sh

# Hyprlock (Lock Screen)
mkdir -p ~/.config/hypr/hyprlock
cp visual-modes/hyprlock/hyprlock.conf ~/.config/hypr/
cp visual-modes/hyprlock/colors.conf ~/.config/hypr/hyprlock/
cp visual-modes/hyprlock/*.sh ~/.config/hypr/hyprlock/
chmod +x ~/.config/hypr/hyprlock/*.sh
```

## Lock Screen (Hyprlock)

Hyprlock is configured to activate:
- **Super+L** - Lock screen immediately
- **Laptop lid close** - Automatic lock via swayidle

### Keybindings
| Shortcut | Action |
|----------|--------|
| Super+L | Lock with Hyprlock |
| Ctrl+Super+L | Lock with TTS announcement |

## Voice Input (Whisper)

Voice input uses Whisper.cpp for speech-to-text transcription.

### Installation
```bash
# Copy voice input scripts
cp visual-modes/voice-input/voice-input ~/.local/bin/
cp visual-modes/voice-input/voice-input-notification ~/.local/bin/
cp visual-modes/voice-input/voice-input-visualizer ~/.local/bin/
cp visual-modes/voice-input/apollo-os-rightctrl-voice.py ~/.local/bin/
chmod +x ~/.local/bin/voice-input*
chmod +x ~/.local/bin/apollo-os-rightctrl-voice.py

# Copy sound files
mkdir -p ~/.local/share/apollo-os/sounds
cp visual-modes/sounds/voice-start.wav ~/.local/share/apollo-os/sounds/
cp visual-modes/sounds/voice-end.wav ~/.local/share/apollo-os/sounds/

# Install systemd service for Right Ctrl Push-to-Talk
mkdir -p ~/.config/systemd/user
cp visual-modes/voice-input/apollo-rightctrl-voice.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now apollo-rightctrl-voice.service

# Install Python evdev (required for Right Ctrl detection)
pip install evdev
```

### Usage
| Method | Description |
|--------|-------------|
| **Super+V** | Toggle recording on/off |
| **Right Ctrl (hold)** | Push-to-Talk: Hold to record, release to transcribe |

### Features
- **Start sound**: Plays when recording begins
- **End sound**: Plays when recording stops
- **Whisper.cpp**: Fast local speech-to-text (German)
- **Auto-type**: Transcribed text is typed automatically + Enter
- **Push-to-Talk**: Right Ctrl key for hands-free operation

### Dependencies
- `whisper.cpp` - Speech recognition (installed via main script)
- `ffmpeg` - Audio conversion
- `parecord` - Audio recording (PipeWire)
- `wtype` - Wayland text input
- `python3-evdev` - Right Ctrl key detection

## Wake Word "Apollo" (Voice Assistant)

The Apollo Wake Word Listener provides hands-free voice control using Vosk speech recognition.

### Installation
```bash
# Copy wake listener script
cp visual-modes/voice-input/apollo-wake-listener.py ~/.local/bin/
cp visual-modes/voice-input/apollo-speak.sh ~/.local/bin/
chmod +x ~/.local/bin/apollo-wake-listener.py
chmod +x ~/.local/bin/apollo-speak.sh

# Install systemd service
cp visual-modes/voice-input/apollo-wake.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now apollo-wake.service

# Install Vosk model (German)
mkdir -p ~/.local/share/vosk-models
cd ~/.local/share/vosk-models
wget https://alphacephei.com/vosk/models/vosk-model-small-de-0.15.zip
unzip vosk-model-small-de-0.15.zip
rm vosk-model-small-de-0.15.zip

# Install Python dependencies
pip install vosk sounddevice
```

### Voice Commands
Say "Apollo" followed by a command:

| Command | Action |
|---------|--------|
| "Apollo, wie spät ist es?" | Speaks the current time |
| "Apollo, Uhrzeit" | Speaks the current time |
| "Apollo, welcher Tag ist heute?" | Speaks the current date |
| "Apollo, Datum" | Speaks the current date |
| "Apollo, Terminal öffnen" | Opens Alacritty terminal |
| "Apollo, Browser starten" | Opens Microsoft Edge |
| "Apollo, sperren" | Locks the screen |
| "Apollo, ausschalten" | Suspends the system |
| "Apollo, Neustart" | Reboots the system |

### Features
- **Wake Word**: "Apollo" activates listening mode
- **Vosk**: Fast offline speech recognition (German)
- **Amala Voice**: German TTS voice (edge-tts)
- **Sound Feedback**: Start/end sounds when processing
- **5 Second Timeout**: Command window after wake word

### Dependencies
- `vosk` - Offline speech recognition
- `sounddevice` - Audio input
- `edge-tts` - Text-to-speech (Amala German voice)
- `pw-play` - Audio playback (PipeWire)

## Usage

### Switch Mode via Script
```bash
# Switch to a specific mode
apollo-os-visual-mode.sh macos
apollo-os-visual-mode.sh modern
apollo-os-visual-mode.sh developer

# Toggle through modes
apollo-os-visual-mode.sh toggle

# Check current mode
apollo-os-visual-mode.sh status
```

### Keyboard Shortcuts
- **Super+Shift+Space** - Open Quick Menu (includes visual mode selection)
- **Super+J** - Toggle Dock visibility (macOS mode only)

## macOS Mode Special Features

The macOS mode includes:
- Transparent top menubar with Apple logo
- macOS-style dock at the bottom with app icons
- 26px rounded window corners
- 50% transparency for inactive windows
- Strong shadows for depth
- Bounce animations
- macOS-styled notifications

### Dock Applications
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

## Credits

Copyright 2025 by Manuel Kraibacher
Apollo OS Project
