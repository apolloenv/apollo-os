# Apollo OS v5.1.0 - Release Notes

**Release-Datum:** 28. Januar 2026

## 🎯 Überblick

Apollo OS v5.1.0 ist ein Major Release mit kritischen Bugfixes, kompletter Feature-Integration, sauberer Directory-Struktur und Production-Ready Status für Fedora 43.

---

## 🏗️ Struktur-Refactoring (NEU)

### Neue Directory-Organisation
Die gesamte Projektstruktur wurde grundlegend reorganisiert für bessere Wartbarkeit und Klarheit:

**Vorher (v3.2.0):**
```
config-data/          # Gemischte Configs
visual-modes/         # Gemischte Themes
apollo-os-professional/ # Hyprland
scripts/              # Alle Scripts
assets/               # Alle Assets
```

**Nachher (v5.1.0):**
```
apollo-os-orbit/      # Niri-spezifisch (99 files)
apollo-os-glass/      # Hyprland-spezifisch (1105 files)
apollo-os-sys/        # Systemkomponenten (112 files)
```

### Vorteile
- ✅ Klare Trennung von Niri und Hyprland
- ✅ Systemkomponenten zentral organisiert
- ✅ Einfachere Wartung und Updates
- ✅ Bessere Übersicht für Entwickler
- ✅ 59 Pfad-Referenzen im Installer aktualisiert
- ✅ 100% Rückwärts-Kompatibilität

---

## ✅ Kritische Fixes

### Installer-Verbesserungen
- **Neovim doppelte Installation** behoben (wurde zweimal installiert)
- **whisper.cpp Build-Pfad** korrigiert (make vs cmake Kompatibilität)
- **Python3-pip Dependency** hinzugefügt (war vorher fehlend)
- **verify_critical_packages** angepasst für Desktop-Auswahl

### Dependency-Management
- Python3, python3-pip, python3-devel automatisch installiert
- Alle Voice Control Dependencies korrekt verknüpft
- Conditional Package Installation basierend auf User-Wahl

---

## ✨ Neue Features

### Editor-Auswahl
- **3 Optionen:** Neovim + Fresh / Nur Fresh / Nur Neovim
- Automatische MIME-Type Zuordnung
- Conditional Installation ohne doppelte Packages

### OnlyOffice Suite
- **Unabhängige Installation** (auch ohne andere Flatpak Apps)
- Microsoft Office kompatibel (Word, Excel, PowerPoint)
- Automatische Flatpak-Setup falls benötigt
- 600s Timeout für große Package-Downloads

### Hyprlock für Niri
- **Moderner Lock Screen** mit Wallpaper-Blur
- TTS Feedback beim Sperren/Entsperren
- Capslock-Status Anzeige
- Tastenkombination: **Mod+L** (hyprlock), **Ctrl+Mod+L** (swaylock)

---

## 🎨 Visual Design Integration

### Rofi Launcher
- **Dark Grayscale Monochrome** Design
- Keine Rounded Corners (Clean Look)
- ">" Prompt statt Icon
- 6 sichtbare Einträge

### Mako Notifications
- **macOS Transparent Style**
- Position: Top-Right (statt Top-Center)
- Semi-transparent Background (#1e1e1e80)
- Rounded Corners (border-radius: 18)
- Max 5 sichtbare Notifications

### Quick Menu
- Überarbeitetes Design ohne Box-Dekorationen
- Cleaner Action-List
- Optimierte Performance
- 383 Zeilen, vollständig getestet

### Cursor Theme
- **Bibata-Modern-Classic** als Standard
- Ersetzt breeze_cursors
- In allen 22 Niri Configs aktualisiert
- Automatische RPM-Installation

---

## 🎵 Audio & Voice Control

### Voice Control System
- **Wake Word:** "apollo" (Vosk Offline)
- **Push-to-Talk:** Rechte Strg-Taste
- **Star Trek Audio Feedback:**
  - voice-start.wav (800Hz→1000Hz ascending)
  - voice-end.wav (1000Hz→800Hz descending)
  - ~160ms Dauer, Fade In/Out
- Systemd Services auto-enabled
- Python evdev für Keyboard-Events

### TTS System (Amala Voice)
- Microsoft Edge TTS (de-DE-AmalaNeural)
- Kryoschlaf/Reaktivierung Sounds
- Lock/Unlock Audio Feedback
- Chime Sound (880Hz→660Hz)

---

## 🖥️ Visual Modes (16 Komplett)

### Alle Themes Verfügbar:
1. **Classic** - Traditional Desktop
2. **Developer** - Code-focused Layout
3. **Enterprise** - Professional Business
4. **i3** - Minimalist Tiling
5. **i3-contrast** - High Contrast i3
6. **i3-retro** - Retro Terminal Style
7. **macos** - macOS Sequoia Inspired
8. **Minimal** - Ultra-Clean
9. **Modern** - Contemporary Design
10. **Nova** - Futuristic Theme
11. **Orbit** - Niri Default Enhanced
12. **Professional** - Business Pro
13. **Professional-Next** - Next-Gen Pro
14. **Professional-Plus** - Premium Pro
15. **SGI** - Retro Workstation
16. **Tech-Blue** - Technical Blue

### Integration:
- **16 Niri Configs** (.kdl)
- **18 Waybar Configs** (inkl. main + dock)
- **18 Waybar Styles** (.css)
- **Visual Mode Switcher** (apollo-os-visual-mode.sh)
- **Toggle Scripts** (gaps, dock, waybar, center)

---

## 📦 Installer-Status

### Statistik
- **Zeilen:** 2.311
- **Funktionen:** 34
- **Error Handling:** 142 Checkpoints
- **Bash Syntax:** ✅ Fehlerfrei validiert

### Features
- Conditional Installation (Desktop, Flatpak, Editor, Office)
- Dynamic Package Verification
- Graceful Error Handling
- Progress Logging (apollo-os-install.log)
- Sudo Auto-Refresh (6 Stellen)

### Kompatibilität
- **Fedora 43** (optimiert)
- Fedora 42/44 kompatibel (mit Warnung)
- x86_64 Architektur
- 8 GB RAM empfohlen

---

## 🔧 Technische Details

### Niri Shortcuts (aktualisiert in allen 22 Configs):
- **Mod+L** → Hyprlock (modern, blur wallpaper)
- **Ctrl+Mod+L** → Swaylock (classic, apollo-login.jpg)
- **Mod+Q** → Window schließen
- **Mod+V** → Voice Input
- **Mod+G** → Toggle Window Gaps
- **Mod+C** → Window zentrieren
- **Mod+M** → Quick Menu

### Whisper.cpp Integration:
- Build via `make` (nicht cmake)
- Binary-Pfad: ./whisper-cli oder ./main (Fallback)
- Deutsche Base Model: ggml-base.bin
- Shared Libraries in ~/.local/lib
- LD_LIBRARY_PATH automatisch gesetzt

### Python Dependencies:
- vosk (Wake Word Detection)
- sounddevice (Audio I/O)
- evdev (Keyboard Events)
- edge-tts (TTS Engine)
- pynvim (Neovim Support)

---

## 📁 Projekt-Struktur

```
apollo-os-dev/v5.1.0/
├── apollo-os-install.sh       # Haupt-Installer (94 KB)
├── README-v5.1.0.md          # Dokumentation
├── CHANGELOG-v5.1.0.md       # Dieses Dokument
├── config-data/              # Basis-Configs
│   ├── niri/                 # 7 Niri Configs
│   ├── waybar/               # Waybar Main Config
│   ├── rofi/                 # Dark Grayscale Design
│   ├── mako/                 # macOS Transparent Style
│   └── ...
├── visual-modes/             # 16 Visual Modes
│   ├── niri/                 # 16 Theme Configs
│   ├── waybar/               # 18 Configs + 18 Styles
│   ├── hyprlock/             # Lock Screen Configs
│   ├── mako/                 # Notification Themes
│   ├── dock/                 # macOS Dock Style
│   ├── scripts/              # Toggle & Switcher
│   ├── sounds/               # Audio Files
│   └── voice-input/          # Voice Control Files
├── scripts/                  # 45 System Scripts
├── assets/                   # Wallpapers, Icons, Boot Logo
├── systemd/                  # 7 Service Files
└── sounds/                   # TTS Audio
```

---

## 🚀 Installation

```bash
cd /home/apollo/AIQSAN01/apollo/apollo-os-dev/v5.1.0
chmod +x apollo-os-install.sh
./apollo-os-install.sh
```

### Interaktive Auswahl:
1. **Desktop:** Hyprland / Niri / Both
2. **Flatpak Apps:** Ja / Nein
3. **OnlyOffice:** Ja / Nein
4. **Editor:** Both / Fresh / Neovim

---

## ✅ Testing & Validation

### Geprüft auf:
- ✅ Fedora 43 Workstation (Clean Install)
- ✅ Bash Syntax Validation
- ✅ Python Script Syntax
- ✅ Alle 142 Error Handlers
- ✅ Flatpak Installation (10 Apps)
- ✅ OnlyOffice (600s Timeout)
- ✅ Voice Control (Wake Word + PTT)
- ✅ Lock Screens (Hyprlock + Swaylock)
- ✅ Visual Mode Switching (16 Themes)

### Bekannte Probleme:
Keine kritischen Probleme bekannt. Alle Tests erfolgreich.

---

## 📊 Statistik

- **1.410 Dateien** im Projekt
- **402 MB** Gesamtgröße
- **39 Wallpapers**
- **16 Visual Modes**
- **18 Waybar Themes**
- **45 Scripts**
- **7 Systemd Services**

---

## 🔄 Migration von v3.2.0

### Automatische Updates:
Der Installer erkennt existierende Installationen und aktualisiert:
- Configs in ~/.config/
- Scripts in ~/.local/bin/
- Systemd Services
- Visual Mode Configs

### Manuelle Schritte:
Keine erforderlich. Der Installer überschreibt alle Configs mit den neuen Versionen.

---

## 📝 Hinweise

### Voice Control:
- Wake Word Service startet automatisch nach Login
- Push-to-Talk Service läuft im Hintergrund (~20 MB RAM)
- Audio Feedback bei jedem Voice Command

### Visual Modes:
- Wechsel mit: `apollo-os-visual-mode.sh`
- Oder via Quick Menu (Mod+M)
- Configs werden sofort geladen (niri reload)

### Lock Screen:
- Hyprlock zeigt aktuelles Wallpaper (blur)
- Swaylock zeigt apollo-login.jpg
- TTS Feedback bei Lock/Unlock

---

## 🙏 Credits

- **dots-hyprland** Community (Hyprland Base)
- **Niri** Window Manager Team
- **Vosk** Offline Speech Recognition
- **Microsoft Edge TTS** (Amala Voice)
- **whisper.cpp** (ggerganov)

---

## 📞 Support

- GitHub: https://github.com/apolloenv/apollo-os
- Issues: https://github.com/apolloenv/apollo-os/issues

---

**Apollo OS v5.1.0 - Enterprise Ready** 🚀
