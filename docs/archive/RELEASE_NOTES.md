# Apollo OS v0.4.1 - Release Notes

**Release Date:** 2026-01-12
**Status:** Production Ready (Bug Fix Release)
**Copyright:** © 2026 by Manuel Kraibacher

---

## 🎉 Release Highlights

Apollo OS v0.4.1 ist ein **Critical Bug Fix Release**, das 40 hardcodierte Pfade und mehrere kritische Fehler behebt. Diese Version macht Apollo OS tatsaechlich produktionsreif fuer alle Benutzer (nicht nur "apollo").

### 🔴 Kritische Fixes in v0.4.1

- **40 hardcodierte `/home/apollo/` Pfade entfernt**
- **Boot-Service funktioniert jetzt korrekt**
- **greetd Session-Selector funktioniert**
- **Dokumentation vollstaendig aktualisiert**

### 🆕 Neue Hauptfeatures

#### 1. Swaylock mit Blur-Effekt ✨
- **High Contrast Design**: Folgt der Inversion Rule (Dark System → Light UI)
- **Blur Effect**: 7x5 Blur mit Vignette auf Wallpaper
- **Intelligente Ring-Farben**: Verschiedene Farben für Clear/Verify/Wrong States
- **Configs**: Dark & Light Varianten

#### 2. SwayOSD High Contrast 🎨
- **CSS-basiertes Styling**: Vollständig anpassbare Appearance
- **Gradient Progress Bars**: Moderne, visuell ansprechende Darstellung
- **Smooth Animations**: fadeIn-Effekt für sanftes Erscheinen
- **Konsistent**: Folgt High Contrast Inversion Rule

#### 3. greetd/tuigreet Login Manager 🖥️
- **Terminal-based**: Cleaner, minimalistischer Login
- **ASCII-Art Branding**: Apollo OS Logo beim Login
- **Session Memory**: Merkt sich letzte Session-Auswahl
- **Session Selector**: Interaktive Auswahl aller WM-Profile
- **Optional**: Kann nach Installation hinzugefügt werden

#### 4. Boot Splash Integration 🚀
- **Verbose Boot**: Sichtbare systemd-Messages während Boot
- **ASCII Logo Display**: 3 Sekunden Apollo Logo-Anzeige
- **Plymouth Disabled**: Textueller Boot-Prozess
- **Systemd Service**: Saubere Integration via Service
- **Revertierbar**: Einfach deaktivierbar

#### 5. Interactive Chat Function 💬
- **Rofi-based Interface**: Nahtlose UI-Integration
- **System Queries**: Direkte Abfragen zu Battery, Disk, RAM, CPU
- **Chat History**: Persistente Conversation History
- **Telegram Integration**: Responses auch via Telegram
- **Click-to-Reply**: Benachrichtigungen öffnen Chat automatisch
- **Hybrid AI**: Automatischer Gemini → Ollama Fallback

---

## 📊 Statistiken

### Code
- **Scripts**: 12 (Bash + Python)
- **Lines of Code**: ~2200 LOC
- **Config Files**: 34
- **Systemd Services**: 3
- **Desktop Entries**: 4

### Komponenten
- **Window Manager Wrapper**: 2 (Niri, Sway)
- **AI Tools**: 3 (diagnose, nl2bash, chat)
- **System Scripts**: 4 (theme-switcher, session-selector, handlers)
- **Installer Scripts**: 3 (main, greetd, boot-splash)

---

## 🔧 Technische Details

### Neue Dependencies
- `dunst` - Für bessere Notification Actions
- `swaylock-effects` - Blur-Effekt Support
- `greetd` + `tuigreet` - Login Manager (optional)

### Architektur-Verbesserungen
- **Interactive Notifications**: Dunstify-Support mit Action-Handling
- **Notification Handler Daemon**: Separater Service für Benachrichtigungs-Actions
- **Enhanced Daemon**: Erweiterte send_interactive() Methode
- **FIFO Communication**: Unix-Socket für IPC zwischen Prozessen

### High Contrast Compliance
Alle neuen UI-Komponenten folgen strikt der High Contrast Inversion Rule:
- ✅ Swaylock (Dark/Light)
- ✅ SwayOSD (Dark/Light)
- ✅ Rofi Chat Interface (nutzt bestehende Themes)

---

## 📦 Installation

### Voraussetzungen
- Fedora 43 Workstation (frisch installiert)
- 8+ GB RAM (16 GB empfohlen)
- 50+ GB freier Speicherplatz
- Internet-Verbindung
- Google Gemini API Key
- Telegram Bot Token (optional)

### Quick Start

```bash
# Clone Repository
git clone https://github.com/YOUR-USERNAME/apollo-os-dev.git
cd apollo-os-dev/v0.3.0

# Run Installer
chmod +x apollo-os-install.sh
./apollo-os-install.sh
```

### Optional Post-Installation

```bash
# greetd Login Manager
sudo ./scripts/apollo-os-greetd-installer.sh

# Boot Splash
sudo ./scripts/apollo-os-boot-splash-installer.sh
```

---

## 🎯 Nutzung

### Neue Commands

```bash
# Interactive Chat
apollo-chat

# System Diagnostics
apollo-diagnose [lines] [--service SERVICE]

# Natural Language to Bash
?? "how do I find large files?"

# Theme Switching
apollo-os-theme-switcher.sh [dark|light|toggle]
```

### Tastenkombinationen

- `Super+Space` - Launcher
- `Super+Return` - Terminal
- `Super+L` - Lock Screen (mit Blur)
- `Super+Q` - Window schließen

---

## 🐛 Bekannte Issues

### Minor Issues
- **Dunstify Actions**: Benötigt neuere Version von dunst (falls nicht verfügbar, Fallback aktiv)
- **Niri Installation**: Möglicherweise COPR oder Source-Build erforderlich
- **greetd Sessions**: User-spezifische Sessions könnten zusätzliche Konfiguration benötigen

### Workarounds
Alle bekannten Issues haben dokumentierte Workarounds in DEPLOYMENT.md

---

## 🔄 Migration von v0.1.1

v0.3.0 ist ein **In-Place Upgrade** von v0.1.1:

1. Backup bestehende Configs (optional):
   ```bash
   cp -r ~/.config/apollo-os ~/.config/apollo-os.backup
   ```

2. Neue Installation durchführen:
   ```bash
   cd ~/apollo-os-dev/v0.3.0
   ./apollo-os-install.sh
   ```

3. Bestehende Konfiguration wird übernommen (config.env bleibt erhalten)

---

## 📚 Dokumentation

- **DEPLOYMENT.md**: Vollständige Installations- und Konfigurationsanleitung
- **CHANGELOG.md**: Detaillierte Änderungsliste
- **README.md**: Projekt-Übersicht und Features
- **RELEASE_NOTES.md**: Dieses Dokument

---

## 🙏 Credits

**Entwickelt von:** Manuel Kraibacher
**Powered by:**
- Google Gemini AI
- Ollama (llama3.2:1b)
- Anthropic Claude (Development Assistant)

**Open Source Components:**
- Niri (Scrollable Tiling WM)
- Sway (i3-compatible Tiling WM)
- Waybar (Status Bar)
- Rofi (Application Launcher)
- Mako/Dunst (Notifications)
- greetd/tuigreet (Login Manager)

---

## 📞 Support & Feedback

- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions
- **Documentation**: See docs/ folder
- **Logs**: `~/.config/apollo-os/daemon.log`

---

## 🚀 Nächste Schritte

Apollo OS v0.3.0 ist **Feature Complete**. Zukünftige Releases fokussieren auf:
- Bug Fixes
- Performance Optimizations
- Community Contributions
- Additional Themes
- Extended AI Capabilities

---

**Viel Spaß mit Apollo OS v0.3.0!** 🚀

*"The flux capacitor is running smoothly."* - Apollo AI
