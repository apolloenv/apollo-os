# Apollo OS v0.4.1 - Deployment Guide

**Copyright © 2026 by Manuel Kraibacher**

---

## 📋 Uebersicht

Dieses Dokument beschreibt die Deployment-Strategie fuer Apollo OS v0.4.1. Apollo OS ist ein intelligenter Layer, der sich ueber eine frische Fedora 43 Workstation Installation legt und diese in ein futuristisches, KI-unterstuetztes System transformiert.

### 🆕 Was ist neu in v0.4.1

- 🔴 **Kritische Bugfixes** - 40 hardcodierte Pfade behoben
- 🛠️ **Boot Service Fix** - Funktioniert jetzt korrekt
- 🔐 **Session Selector Fix** - greetd/tuigreet funktioniert
- 📚 **Dokumentation** - Vollstaendig aktualisiert

## 🎯 Systemanforderungen

### Basis-System
- **OS:** Fedora 43 Workstation (frische Installation)
- **RAM:** Mindestens 8 GB (16 GB empfohlen)
- **Disk:** Mindestens 50 GB freier Speicherplatz
- **Internet:** Aktive Internetverbindung während Installation
- **Hardware:** Laptop-optimiert (WiFi, Bluetooth, Battery Management)

### Voraussetzungen
- Sudo-Rechte für den ausführenden Benutzer
- Git installiert (für Repository-Clone)
- Aktive Internetverbindung
- Google Gemini API Key ([Get API Key](https://makersuite.google.com/app/apikey))
- Telegram Bot Token (optional, empfohlen)

## 🚀 Installation

### Schritt 1: Repository Klonen

```bash
cd ~
git clone https://github.com/YOUR-USERNAME/apollo-os-dev.git
cd apollo-os-dev/v0.4.1
```

### Schritt 2: Installer Ausführbar Machen

```bash
chmod +x apollo-os-install.sh
```

### Schritt 3: Installation Starten

```bash
./apollo-os-install.sh
```

### Schritt 4: Konfiguration Eingeben

Der Installer fragt interaktiv nach:

1. **Google Gemini API Key**
   - Wird für AI-Features benötigt
   - Sicher gespeichert in `~/.config/apollo-os/config.env`

2. **Telegram Bot Token** (optional)
   - Erstelle Bot via [@BotFather](https://t.me/botfather)
   - Ermöglicht System-Benachrichtigungen via Telegram

3. **Telegram User ID** (optional)
   - Deine persönliche Telegram Chat-ID
   - Finde sie via [@userinfobot](https://t.me/userinfobot)

### Schritt 5: Installation Abwarten

Die Installation dauert ca. 15-30 Minuten, abhängig von:
- Internetgeschwindigkeit
- System-Hardware
- Anzahl der zu installierenden Pakete

## 📂 Installierte Komponenten

### Window Managers
- **Niri** - Scrollable Tiling WM (Wayland)
- **Sway** - Classic i3-style Tiling WM (Wayland)

### Profile System
Jeder WM hat zwei Profile:
- **PRO** - Minimalistisch, professionell, performant
- **MOD** - Visuell beeindruckend, mit Effekten

### UI Komponenten
- **Waybar** - Interaktive Statusleiste
- **Rofi** - Application Launcher (High Contrast)
- **Mako** - Notification Daemon (High Contrast)
- **SwayOSD** - On-Screen Display für Volume/Brightness
- **Swaylock** - Lockscreen mit Blur-Effekt

### Apollo Intelligence
- **apollo-os-daemon.py** - Hybrid AI Engine (Gemini + Ollama)
- **apollo-diagnose** - AI-powered System Diagnostics
- **??** - Natural Language to Bash Converter

### Systemd Services
- `apollo-os-daemon.service` - Haupt-Daemon (auto-start)
- `apollo-os-boot.service` - Boot Splash mit ASCII Logo

## 🎨 Profile & Themes

### Verfügbare WM Sessions

Nach Installation sind folgende Sessions im Login Manager verfügbar:

- **Apollo OS - Niri PRO** (Dark)
- **Apollo OS - Niri MOD** (Dark)
- **Apollo OS - Sway PRO** (Dark)
- **Apollo OS - Sway MOD** (Dark)

### Theme Switching

Wechsel zwischen Dark und Light Theme:

```bash
apollo-os-theme-switcher.sh dark   # Zu Dark wechseln
apollo-os-theme-switcher.sh light  # Zu Light wechseln
apollo-os-theme-switcher.sh toggle # Toggle Dark/Light
```

**Wichtig:** Die High Contrast "Inversion Rule" wird automatisch angewendet:
- **Dark System → Light UI** (Launcher, Notifications hell)
- **Light System → Dark UI** (Launcher, Notifications dunkel)

## 🤖 AI Features

### Hybrid AI Engine

Apollo OS nutzt eine intelligente Hybrid-Strategie:

1. **Primary:** Google Gemini (gemini-2.0-flash)
   - Schnell und leistungsfähig
   - Benötigt Internet

2. **Fallback:** Ollama (llama3.2:1b)
   - Lokales Modell, funktioniert offline
   - Wird beim Boot in RAM geladen (Preloading)
   - Keep-Alive für sofortige Antworten

### AI Tools

#### apollo-diagnose

Analysiert System-Logs mit AI:

```bash
apollo-diagnose 100                    # Letzte 100 Fehler-Logs
apollo-diagnose 200 --service NetworkManager  # Bestimmter Service
```

#### ?? (Natural Language Helper)

Konvertiert natürliche Sprache in Bash-Befehle:

```bash
?? wie finde ich große Dateien
?? zeige mir die Systemauslastung
?? wie checke ich den Festplattenspeicher
```

### Apollo Daemon

Der Daemon läuft permanent im Hintergrund und:

- **Monitort** System-Ressourcen (Battery, Disk, RAM)
- **Sendet** Benachrichtigungen bei kritischen Events
- **Kommuniziert** via Telegram
- **Begrüßt** den User zeitbasiert (Morgen/Abend)
- **Generiert** zufällige, humorvolle System-Nachrichten

## 📁 Verzeichnisstruktur

Nach Installation:

```
~/.config/
├── apollo-os/
│   ├── config.env              # Haupt-Konfiguration
│   ├── daemon-state.json       # Daemon-Zustand
│   └── daemon.log              # Daemon-Logs
├── niri/
│   ├── apollo-os-config-pro.kdl
│   ├── apollo-os-config-mod.kdl
│   └── [light variants...]
├── sway/
│   ├── apollo-os-config-pro
│   ├── apollo-os-config-mod
│   └── [light variants...]
├── waybar/
│   └── [profile-specific configs & styles]
├── mako/
│   ├── apollo-os-config-dark
│   └── apollo-os-config-light
└── rofi/
    ├── apollo-os-theme-dark.rasi
    └── apollo-os-theme-light.rasi

~/.local/bin/
├── apollo-os-daemon.py
├── apollo-os-diagnose.sh
├── apollo-os-nl2bash.sh
├── apollo-os-theme-switcher.sh
├── apollo-os-wrapper-niri.sh
├── apollo-os-wrapper-sway.sh
├── ?? -> apollo-os-nl2bash.sh
└── apollo-diagnose -> apollo-os-diagnose.sh

~/System/Wallpaper/
└── [Alle Wallpapers + current.jpg symlink]
```

## 🔧 Manuelle Anpassungen

### Wallpaper Ändern

```bash
cd ~/System/Wallpaper
ln -sf Apollo-OS-15.png current.jpg  # Ändert Wallpaper
```

### Waybar Module Anpassen

Editiere die Waybar-Config deines Profils:

```bash
nano ~/.config/waybar/apollo-os-config-niri-pro
```

### Ollama Model Ändern

```bash
nano ~/.config/apollo-os/config.env
# Ändere OLLAMA_MODEL="llama3.2:1b" zu anderem Modell
ollama pull <new-model>  # Model herunterladen
systemctl --user restart apollo-os-daemon.service
```

## 🐛 Troubleshooting

### Daemon startet nicht

```bash
# Status checken
systemctl --user status apollo-os-daemon.service

# Logs anschauen
journalctl --user -u apollo-os-daemon.service -f

# Manual starten für Debug
~/.local/bin/apollo-os-daemon.py
```

### Waybar zeigt nicht an

```bash
# Waybar neu starten
pkill waybar
waybar -c ~/.config/waybar/apollo-os-config-niri-pro \
       -s ~/.config/waybar/apollo-os-style-niri-pro.css &
```

### Niri/Sway startet nicht

```bash
# Config validieren
niri validate ~/.config/niri/apollo-os-config-pro.kdl

# Logs checken
journalctl --user -xe
```

### AI nicht verfügbar

```bash
# Gemini API Key prüfen
cat ~/.config/apollo-os/config.env | grep GEMINI

# Ollama Status checken
ollama list
systemctl status ollama  # Falls als Service installiert
```

## 📝 Nächste Schritte

Nach erfolgreicher Installation:

1. **Logout** aus aktueller Session
2. **Wähle** Apollo OS Session beim Login (z.B. "Apollo OS - Niri PRO")
3. **Login** mit deinem Passwort
4. **Erkunde** die Tastenkombinationen:
   - `Super+Space` - Launcher öffnen
   - `Super+Return` - Terminal öffnen
   - `Super+Q` - Fenster schließen
   - `Klick auf Waybar Icons` - Interaktive Menüs

## 🔐 Sicherheit

- API Keys werden in `~/.config/apollo-os/config.env` gespeichert (chmod 600)
- Systemd Services laufen mit eingeschränkten Rechten
- Keine Root-Rechte nach Installation benötigt

## 📞 Support

Bei Problemen:
- GitHub Issues: [apollo-os-dev/issues](https://github.com/YOUR-USERNAME/apollo-os-dev/issues)
- Logs in: `~/.config/apollo-os/daemon.log`
- System-Logs: `journalctl --user -u apollo-os-daemon.service`

## 💬 Neue Features Nutzung (v0.3.0)

### Interactive Chat

Starte den Chat mit Apollo:

```bash
apollo-chat
# oder
apollo-os-chat.sh
```

Frage nach System-Informationen:
- "Wie ist mein Akkustand?"
- "Wie viel RAM wird verwendet?"
- "Wie voll ist meine Festplatte?"

Der Chat ist auch über klickbare Benachrichtigungen erreichbar!

### Swaylock mit Blur

Der Lockscreen wird automatisch mit dem aktuellen Wallpaper und Blur-Effekt konfiguriert:

```bash
# Lock screen
swaylock -f -C ~/.config/swaylock/apollo-os-config-dark
```

### greetd Login Manager

Falls installiert, bietet tuigreet beim Login eine ASCII-Art Begrüßung und Session-Auswahl.

### Boot Splash

Optional installierbar nach Hauptinstallation:

```bash
sudo ~/apollo-os-dev/v0.4.1/scripts/apollo-os-boot-splash-installer.sh
```

Zeigt Apollo OS ASCII Logo für 3 Sekunden während des Boots.

---

**Version:** 0.4.1
**Datum:** 2026-01-12
**Status:** Production Ready
