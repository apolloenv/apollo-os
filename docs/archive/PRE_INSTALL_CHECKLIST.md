# Apollo OS v0.4.1 - Pre-Installation Checklist

## ✅ Vor der Installation pruefen

### System-Voraussetzungen
- [ ] Fedora 43 Workstation (frische Installation)
- [ ] Mindestens 8 GB RAM (16 GB empfohlen)
- [ ] Mindestens 50 GB freier Speicherplatz
- [ ] Aktive Internetverbindung
- [ ] Sudo-Rechte fuer ausfuehrenden Benutzer

### API Keys & Tokens vorbereiten
- [ ] Google Gemini API Key ([Get here](https://makersuite.google.com/app/apikey))
- [ ] Telegram Bot Token (optional, via [@BotFather](https://t.me/botfather))
- [ ] Telegram User ID (optional, via [@userinfobot](https://t.me/userinfobot))

### Repository Vorbereitung
- [ ] Git installiert: `sudo dnf install -y git`
- [ ] Repository geklont
- [ ] In v0.4.1 Verzeichnis gewechselt
- [ ] Installer ausfuehrbar gemacht: `chmod +x apollo-os-install.sh`

## 🔍 Installations-Validierung

### Syntax-Checks (optional, aber empfohlen)
```bash
# Bash Scripts prüfen
for script in scripts/*.sh apollo-os-install.sh; do
    bash -n "$script" && echo "✓ $script" || echo "✗ $script FEHLER"
done

# Python Daemon prüfen
python3 -m py_compile scripts/apollo-os-daemon.py && echo "✓ Python OK" || echo "✗ Python FEHLER"
```

### Datei-Struktur Validierung
```bash
# Prüfe ob alle kritischen Dateien vorhanden sind
ls -la apollo-os-install.sh
ls -la scripts/apollo-os-daemon.py
ls -la scripts/apollo-os-wrapper-niri.sh
ls -la scripts/apollo-os-wrapper-sway.sh
ls -la config-data/swaylock/apollo-os-config-dark
ls -la config-data/swayosd/apollo-os-style-dark.css
ls -la wayland-sessions/apollo-niri-pro.desktop
ls -la systemd/apollo-os-daemon.service
```

## 📋 Installations-Ablauf

### Schritt 1: Basis-Installation
```bash
./apollo-os-install.sh
```

**Erwartete Dauer**: 15-30 Minuten

**Was passiert**:
- System-Checks (Fedora 43, Sudo, Internet)
- User-Config Eingabe (Gemini API, Telegram)
- Package Installation (~200+ packages)
- Config Deployment
- Script Installation
- Desktop Entries Installation
- Systemd Services Setup
- Wallpaper Setup

### Schritt 2: Optional - greetd Login Manager
```bash
sudo ./scripts/apollo-os-greetd-installer.sh
```

**Nur bei "Ja" während Hauptinstallation**

### Schritt 3: Optional - Boot Splash
```bash
sudo ./scripts/apollo-os-boot-splash-installer.sh
```

**Nach Hauptinstallation, falls gewünscht**

## ⚠️ Bekannte Probleme & Workarounds

### Problem: Niri nicht in Repos
**Symptom**: `dnf install niri` schlägt fehl
**Workaround**: COPR Repo oder manueller Build erforderlich
**Impact**: Nur Sway verfügbar bis Niri installiert

### Problem: greetd/tuigreet nicht verfügbar
**Symptom**: Package not found
**Workaround**: Installer überspringt, GDM bleibt aktiv
**Impact**: Kein Terminal-Login, aber ansonsten voll funktional

### Problem: Ollama Model Download langsam
**Symptom**: Installation hängt bei "Pulling llama3.2:1b"
**Workaround**: Warten (1-5 Minuten je nach Verbindung)
**Impact**: Verzögert Installation

## ✅ Post-Installation Validierung

### Service Status prüfen
```bash
# Apollo Daemon
systemctl --user status apollo-os-daemon.service

# Notification Handler
systemctl --user status apollo-os-notification-handler.service

# Logs checken (sollte keine Fehler zeigen)
journalctl --user -u apollo-os-daemon.service -n 50
```

### Config-Dateien prüfen
```bash
# Apollo OS Config
cat ~/.config/apollo-os/config.env

# Swaylock Config
ls -la ~/.config/swaylock/

# SwayOSD Styles
ls -la ~/.config/swayosd/

# Wallpaper
ls -la ~/System/Wallpaper/current.jpg
```

### Commands testen
```bash
# AI Tools (benötigt Config)
?? "list files"
apollo-diagnose 50
apollo-chat

# Theme Switcher
apollo-os-theme-switcher.sh toggle

# Wrapper (nicht direkt ausführen, nur Syntax)
bash -n ~/.local/bin/apollo-os-wrapper-niri.sh
```

## 🚀 Erster Login

### Nach Installation:
1. **Logout** aus aktueller Session
2. Im Login Manager **Apollo OS Session wählen**:
   - Apollo OS - Niri PRO
   - Apollo OS - Niri MOD
   - Apollo OS - Sway PRO
   - Apollo OS - Sway MOD
3. **Login** mit Passwort
4. **Warten** (~5-10 Sekunden) bis Waybar erscheint

### Erste Schritte nach Login:
```bash
# Check Services
systemctl --user status apollo-os-daemon

# Test AI Chat
apollo-chat

# Test Lockscreen
# Super+L (falls konfiguriert) oder:
swaylock -f -C ~/.config/swaylock/apollo-os-config-dark
```

### Keyboard Shortcuts (Standard):
- `Super+Space` - Launcher
- `Super+Return` - Terminal
- `Super+Q` - Window schließen
- `Super+F` - Fullscreen
- `Super+W` - Toggle floating
- `Volume/Brightness Keys` - OSD anzeigen

## 📞 Bei Problemen

### Installation schlägt fehl
1. Log prüfen: `/tmp/apollo-os-install.log`
2. Letzten Befehl identifizieren
3. Manuell wiederholen
4. Installation fortsetzen

### Services starten nicht
1. Logs checken: `journalctl --user -xe`
2. Python Packages prüfen: `pip3 list | grep -E "google|telegram|psutil"`
3. Daemon manual testen: `~/.local/bin/apollo-os-daemon.py`

### WM startet nicht
1. Config validieren:
   ```bash
   niri validate ~/.config/niri/apollo-os-config-pro.kdl
   sway -C ~/.config/sway/apollo-os-config-pro --validate
   ```
2. Wrapper-Script testen:
   ```bash
   bash -x ~/.local/bin/apollo-os-wrapper-niri.sh pro dark
   ```

---

**Version**: 0.3.0
**Datum**: 2026-01-12
**Status**: Production Ready ✅
