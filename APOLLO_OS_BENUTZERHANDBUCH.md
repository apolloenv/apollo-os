# 🚀 Apollo OS v0.4.1 - Vollständiges Benutzerhandbuch

**Copyright © 2026 by Manuel Kraibacher**  
**Version:** 0.4.1  
**Basis:** Fedora 43 Workstation  
**Lizenz:** MIT

---

## 📚 INHALTSVERZEICHNIS

1. [Was ist Apollo OS?](#was-ist-apollo-os)
2. [Systemanforderungen](#systemanforderungen)
3. [Installation](#installation)
4. [Konfiguration](#konfiguration)
5. [Window Manager Modi](#window-manager-modi)
6. [Tastenkürzel (Keybindings)](#tastenkürzel-keybindings)
7. [Features & Funktionen](#features--funktionen)
8. [AI-Integration](#ai-integration)
9. [TTS-System](#tts-system)
10. [Theme-System](#theme-system)
11. [Tipps & Tricks](#tipps--tricks)
12. [Troubleshooting](#troubleshooting)

---

## 🌟 WAS IST APOLLO OS?

**Apollo OS** ist ein modernes, AI-gestütztes Wayland-Desktop-System basierend auf Fedora 43 Workstation. Es kombiniert die Kraft von zwei Window Managern (Niri & Sway), eine hybride AI-Engine (Gemini + Ollama) und ein vollständig integriertes Text-to-Speech System für ein einzigartiges Computing-Erlebnis.

### Kernmerkmale

- 🪟 **Dual Window Manager**: Wähle zwischen Niri (Scrollable Tiling) und Sway (i3-style Tiling)
- 🤖 **Hybrid AI-Engine**: Gemini (Cloud) + Ollama (lokal) mit automatischem Fallback
- 🔊 **Integriertes TTS-System**: LUNA Voice (Jenny Dioco) für Systemansagen
- 🎨 **Dark/Light Themes**: Vollständig themebar mit Theme-Switcher
- ⚡ **Performance**: Optimiert mit qwen2.5:0.5b (500MB, 3x schneller als llama3.2)
- 📱 **Telegram-Integration**: Steuere dein System remote über Telegram
- 🔐 **Sicherheit**: Sandboxed Services mit systemd security policies

### Design-Philosophie

**Apollo OS** folgt dem Prinzip "**Productivity meets Intelligence**":
- **Minimalistisch**: Keine unnötigen UI-Elemente
- **Intelligent**: AI assistiert bei täglichen Aufgaben
- **Schnell**: Optimiert für Low-Latency und hohen Throughput
- **Flexibel**: Zwei WM-Modi für unterschiedliche Workflows

---

## 💻 SYSTEMANFORDERUNGEN

### Minimum

- **OS:** Fedora 43 Workstation (frische Installation empfohlen)
- **CPU:** x86_64 mit 2+ Kernen
- **RAM:** 8 GB (4 GB für System + 4 GB für AI/Ollama)
- **Disk:** 30 GB freier Speicher
- **GPU:** Intel/AMD/NVIDIA mit Wayland-Support

### Empfohlen

- **CPU:** x86_64 mit 4+ Kernen (für Ollama)
- **RAM:** 16 GB (8 GB für System + 8 GB für AI)
- **Disk:** 50 GB SSD
- **GPU:** Intel Iris/AMD Radeon/NVIDIA (proprietärer Treiber für NVIDIA)
- **Internet:** Für Gemini AI und Telegram (optional für Ollama-Fallback)

### Getestete Hardware

✅ **Laptops:**
- ThinkPad X1 Carbon (Intel Iris Xe)
- Dell XPS 13/15 (Intel Iris)
- Framework Laptop (AMD Ryzen)

✅ **Desktops:**
- Intel i5/i7/i9 (11th Gen+)
- AMD Ryzen 5/7/9 (5000+)

---

## 🛠️ INSTALLATION

### Schritt 1: Fedora 43 Workstation installieren

1. Download **Fedora 43 Workstation ISO** von [getfedora.org](https://getfedora.org)
2. Erstelle bootfähigen USB-Stick mit `dd` oder Fedora Media Writer
3. Installiere Fedora 43 (Default Partitionierung OK)
4. Führe erste Updates aus:
   ```bash
   sudo dnf update -y
   sudo reboot
   ```

### Schritt 2: Apollo OS Installer herunterladen

```bash
# Apollo OS Installer klonen oder herunterladen
cd ~/Downloads
git clone https://github.com/DEIN_USERNAME/apollo-os.git
# ODER: ZIP herunterladen und entpacken

cd apollo-os/v0.4.1
```

### Schritt 3: Installer ausführen

```bash
# Installer ausführbar machen
chmod +x apollo-os-install.sh

# Installation starten (ca. 15-30 Minuten)
./apollo-os-install.sh
```

**Der Installer führt folgende Schritte aus:**

1. ✅ System-Check (Fedora Version, Architektur)
2. 📦 Paket-Installation (Niri, Sway, Waybar, Rofi, etc.)
3. 🤖 Ollama Installation (qwen2.5:0.5b Model)
4. ⚙️ Config-Deployment (Niri, Sway, Waybar, Mako, Rofi)
5. 📜 Script-Installation (~/.local/bin/)
6. 🖼️ Desktop Entries (Login-Manager)
7. 🔧 Systemd Services (Daemon, Boot-Splash)
8. 🔊 **Audio-System (TTS mit LUNA Voice)** ← NEU!
9. 🖼️ Wallpaper-Setup (~/System/Wallpaper/)
10. 🎨 Login-Manager Config (Optional: greetd)

### Schritt 4: Logout & Login

**WICHTIG:** Vor dem ersten Login die API-Keys eintragen!

```bash
# Öffne die Konfigurationsdatei
nano ~/.config/apollo-os/config.env
```

**Trage folgende Werte ein:**

```bash
# Google Gemini API Key (ERFORDERLICH für AI-Features)
GEMINI_API_KEY="DEIN_GEMINI_API_KEY_HIER"

# Telegram Bot Token (OPTIONAL für Remote-Steuerung)
TELEGRAM_BOT_TOKEN="DEIN_BOT_TOKEN_HIER"
TELEGRAM_USER_ID="DEINE_USER_ID_HIER"

# E-Mail Konfiguration (OPTIONAL)
EMAIL_ENABLED=false
SMTP_HOST="smtps.udag.de"
SMTP_PORT=587
SMTP_USER="aiq@kraibacher.com"
SMTP_PASSWORD="DEIN_PASSWORT_HIER"
SMTP_FROM="ApolloAIQ"
```

#### 🔑 Wie bekomme ich einen Gemini API Key?

1. Gehe zu [ai.google.dev](https://ai.google.dev/)
2. Klicke auf "Get API Key" → "Create API Key in new project"
3. Kopiere den generierten Key
4. Füge ihn in `~/.config/apollo-os/config.env` ein

**Beispiel:**
```bash
GEMINI_API_KEY="your_gemini_api_key_here"
```

#### 📱 Wie erstelle ich einen Telegram Bot?

1. Öffne Telegram und suche nach `@BotFather`
2. Sende `/newbot` und folge den Anweisungen
3. Notiere den **Bot Token** (z.B. `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz123456789`)
4. Starte deinen Bot und sende `/start`
5. Hole deine **User ID** mit `@userinfobot` (`/start` senden)
6. Trage beide Werte in `config.env` ein

**Beispiel:**
```bash
TELEGRAM_BOT_TOKEN="1234567890:ABCdefGHIjklMNOpqrsTUVwxyz123456789"
TELEGRAM_USER_ID="123456789"
```

### Schritt 5: Logout & Login

```bash
# Ausloggen
sudo systemctl restart gdm
# ODER: Reboot
sudo reboot
```

**Im Login-Manager erscheinen 4 neue Sessions:**

- 🌀 **Apollo Orbit (Fluid)** - Niri PRO (Dark)
- ✨ **Apollo Orbit (Enhanced)** - Niri MOD (Dark)
- 🔲 **Apollo Grid (Static)** - Sway PRO (Dark)
- ⚡ **Apollo Grid (Enhanced)** - Sway MOD (Dark)

**Audio-System ist bereits installiert!** Teste es:
```bash
# Nach dem Login:
apollo-speak welcome
# → Sollte "Welcome back to Apollo OS" sprechen
```

---

## ⚙️ KONFIGURATION

### Verzeichnisstruktur

```
~/.config/apollo-os/
├── config.env              # Haupt-Konfiguration (API-Keys, Profile)
├── daemon.log              # AI-Daemon Log
└── daemon-state.json       # Session-State (Uptime, AI-Stats)

~/.config/niri/
├── apollo-os-config-pro.kdl       # Niri PRO (Dark)
├── apollo-os-config-pro-light.kdl # Niri PRO (Light)
├── apollo-os-config-mod.kdl       # Niri MOD (Dark)
└── apollo-os-config-mod-light.kdl # Niri MOD (Light)

~/.config/sway/
├── apollo-os-config-pro           # Sway PRO (Dark)
├── apollo-os-config-pro-light     # Sway PRO (Light)
├── apollo-os-config-mod           # Sway MOD (Dark)
└── apollo-os-config-mod-light     # Sway MOD (Light)

~/.config/waybar/
├── apollo-os-config-niri-pro      # Waybar Config für Niri PRO
├── apollo-os-style-niri-pro.css   # Waybar Dark Style
├── apollo-os-style-niri-pro-light.css # Waybar Light Style
└── ... (8 Dateien pro WM/Profil)

~/.local/bin/
├── apollo-os-*                    # Alle Apollo OS Scripts
├── ??                             # Alias für nl2bash (AI Shell)
├── apollo-chat                    # Alias für Chat
└── apollo-diagnose                # Alias für Diagnostics
```

### config.env - Alle Optionen

```bash
# ===== PROFILE & THEME =====
DEFAULT_PROFILE="pro"              # pro | mod
DEFAULT_THEME="dark"               # dark | light
APOLLO_WM="niri"                   # niri | sway (auto-set by wrapper)

# ===== AI CONFIGURATION =====
GEMINI_API_KEY="YOUR_KEY_HERE"     # Google Gemini API Key
OLLAMA_MODEL="qwen2.5:0.5b"        # Ollama Fallback Model
AI_TIMEOUT=30                      # AI Response Timeout (seconds)

# ===== TELEGRAM BOT =====
TELEGRAM_BOT_TOKEN="YOUR_TOKEN"    # Bot Token from @BotFather
TELEGRAM_USER_ID="YOUR_ID"         # Your Telegram User ID
TELEGRAM_ENABLED=true              # Enable/Disable Telegram

# ===== EMAIL (OPTIONAL) =====
EMAIL_ENABLED=false                # Enable Email notifications
SMTP_HOST="smtps.udag.de"
SMTP_PORT=587
SMTP_USER="aiq@kraibacher.com"
SMTP_PASSWORD="YOUR_PASSWORD"
SMTP_FROM="ApolloAIQ"

# ===== SYSTEM MONITORING =====
BATTERY_LOW_THRESHOLD=20           # Low battery warning (%)
BATTERY_CRITICAL_THRESHOLD=10      # Critical battery warning (%)
DISK_WARNING_THRESHOLD=85          # Disk usage warning (%)
RAM_WARNING_THRESHOLD=85           # RAM usage warning (%)

# ===== TTS CONFIGURATION =====
APOLLO_DND=false                   # Do Not Disturb (disable TTS)
TTS_VOICE="en_GB-jenny_dioco-medium" # Piper Voice Model
```

---

## 🪟 WINDOW MANAGER MODI

Apollo OS bietet **4 verschiedene Modi** an:

### 🌀 Niri - Scrollable Tiling

**Konzept:** Fenster werden in **Spalten** organisiert, horizontal scrollbar.

```
┌──────────────────────────────────────────┐
│  [Terminal]  [Browser]  [Editor]  ...   │  ← Horizontal scrollbar
└──────────────────────────────────────────┘
```

**Vorteile:**
- ✅ Unendlich viele Fenster nebeneinander
- ✅ Smooth Scrolling zwischen Workspaces
- ✅ Natürliches Multitasking (wie Tabs)
- ✅ Perfekt für Ultrawide-Monitore

**Perfekt für:**
- Web-Entwicklung (Browser + Editor + Terminal)
- Content Creation (Player + Editor + Preview)
- Multi-Monitor-Setups

#### Niri PRO vs MOD

| Feature | PRO | MOD |
|---------|-----|-----|
| Gaps | 13px | 13px |
| Animationen | Aus | An |
| Fokus folgt Maus | Ja | Ja |
| Border-Stil | Weiß (Dark) / Grau (Light) | Identisch |

### 🔲 Sway - i3-style Tiling

**Konzept:** Klassisches **binäres Tiling** (splitten in Hälften).

```
┌─────────────┬─────────────┐
│   Terminal  │   Browser   │
├─────────────┼─────────────┤
│   Editor    │   Player    │
└─────────────┴─────────────┘
```

**Vorteile:**
- ✅ Vorhersagbares Layout
- ✅ Maximale Bildschirmnutzung
- ✅ i3-kompatible Keybindings
- ✅ Stabil und ausgereift

**Perfekt für:**
- Terminal-Power-User
- i3wm-Umsteiger
- Laptop-Setups (kleinere Displays)

#### Sway PRO vs MOD

| Feature | PRO | MOD |
|---------|-----|-----|
| Gaps | Smart Gaps | Smart Gaps |
| Border | 2px | 2px |
| Layout-Stil | Identisch | Identisch |

---

## ⌨️ TASTENKÜRZEL (KEYBINDINGS)

### 🌐 Universal (Niri & Sway)

#### Launcher & Menü

| Tastenkürzel | Funktion |
|--------------|----------|
| `Super + Space` | 🚀 **Rofi Launcher** (Apps starten) |
| `Super + Shift + Space` | ⚡ **Quick Action Menu** (13 Aktionen) |
| `Super + Ctrl + Space` | 🖼️ **Wallpaper wechseln** (Cycle) |
| `Super + Shift + /` | ❓ **Hotkey-Übersicht** (nur Niri) |

#### Applikationen

| Tastenkürzel | Funktion |
|--------------|----------|
| `Super + Return` | 🖥️ **Terminal** (Alacritty) |
| `Super + B` | 🌐 **Browser** (Firefox) |
| `Super + D` | 📁 **Dateimanager** (Nautilus) |
| `Super + N` | 📝 **Text-Editor** (GNOME Text Editor) |
| `Super + T` | 🖥️ **Terminal 2** (Ptyxis) |

#### Fenster-Management

| Tastenkürzel | Funktion |
|--------------|----------|
| `Super + Q` | ❌ **Fenster schließen** |
| `Super + W` | 🎈 **Floating toggle** (schwebend) |
| `Super + F` | ⛶ **Fullscreen** |
| `Super + C` | ⊕ **Fenster zentrieren** |
| `Super + M` | ⬜ **Spalte maximieren** (nur Niri) |
| `Super + R` | ↔️ **Fensterbreite wechseln** (33%/50%/66%/85%) |

#### Navigation

| Tastenkürzel | Funktion |
|--------------|----------|
| `Super + Left` | ← Fokus nach links |
| `Super + Right` | → Fokus nach rechts |
| `Super + Up` | ↑ Fokus nach oben / Workspace hoch (Niri) |
| `Super + Down` | ↓ Fokus nach unten / Workspace runter (Niri) |
| `Super + Tab` | ⇥ Nächstes Fenster |
| `Super + Shift + Tab` | ⇤ Vorheriges Fenster |

#### Fenster verschieben

| Tastenkürzel | Funktion |
|--------------|----------|
| `Super + Alt + Left` | ← Fenster/Spalte nach links |
| `Super + Alt + Right` | → Fenster/Spalte nach rechts |
| `Super + Alt + Up` | ↑ Fenster nach oben |
| `Super + Alt + Down` | ↓ Fenster nach unten |

#### Fenster-Größe ändern

| Tastenkürzel | Funktion |
|--------------|----------|
| `Super + Ctrl + Left` | ← Breite -10% |
| `Super + Ctrl + Right` | → Breite +10% |
| `Super + Ctrl + Up` | ↑ Höhe -10% |
| `Super + Ctrl + Down` | ↓ Höhe +10% |

#### Workspaces

| Tastenkürzel | Funktion |
|--------------|----------|
| `Super + 1..9` | Workspace 1-9 wechseln |
| `Super + 0` | Workspace 10 |
| `Super + Shift + 1..9` | Fenster zu Workspace 1-9 verschieben |

#### System

| Tastenkürzel | Funktion |
|--------------|----------|
| `Super + L` | 🔒 **Bildschirm sperren** (Swaylock) |
| `Super + Shift + E` | 🚪 **Logout** (WM beenden) |
| `Super + Shift + R` | 🔄 **Waybar neu laden** |

#### Screenshots

| Tastenkürzel | Funktion |
|--------------|----------|
| `Super + S` | 📸 **Screenshot** (Bereich wählen mit slurp) |

**Speicherort:** `~/Bilder/Screenshots/screenshot-YYYYMMDD-HHMMSS.png`

#### Multimedia-Tasten

| Tastenkürzel | Funktion |
|--------------|----------|
| `XF86AudioRaiseVolume` | 🔊 Lautstärke +5% |
| `XF86AudioLowerVolume` | 🔉 Lautstärke -5% |
| `XF86AudioMute` | 🔇 Mute toggle |
| `XF86AudioMicMute` | 🎤 Mikrofon Mute |
| `XF86MonBrightnessUp` | ☀️ Helligkeit +10% |
| `XF86MonBrightnessDown` | 🌙 Helligkeit -10% |
| `XF86AudioPlay` | ⏯️ Play/Pause |
| `XF86AudioNext` | ⏭️ Nächster Track |
| `XF86AudioPrev` | ⏮️ Vorheriger Track |

### ⚡ Quick Action Menu (Super + Shift + Space)

Das **Quick Menu** bietet 13 häufig genutzte Aktionen:

```
🔒 Lock Screen          → Bildschirm sperren
🌙 Toggle Theme         → Dark/Light wechseln
💬 Open Chat            → AI-Chat öffnen
🔍 System Diagnostics   → Diagnose-Bericht
📊 Show Statistics      → Session-Statistiken
🖼️ Next Wallpaper       → Wallpaper wechseln
⚡ Power Profiles       → Power-Profile wechseln
🔄 Reload Waybar        → Waybar neu starten
🔄 Reload Mako          → Mako neu starten
🚪 Logout               → WM beenden
🔄 Restart WM           → WM neu starten
⏻ Shutdown             → System herunterfahren (mit Bestätigung)
🔁 Reboot               → System neu starten (mit Bestätigung)
```

**Beispiel-Workflow:**
1. `Super + Shift + Space` drücken
2. "Toggle Theme" auswählen (Pfeiltasten + Enter)
3. System wechselt automatisch zu Light/Dark Theme

---

## 🎯 FEATURES & FUNKTIONEN

### 1. 🤖 Hybrid AI-Engine

Apollo OS nutzt **zwei AI-Engines** mit automatischem Fallback:

```
┌──────────────────────────────────────────┐
│  User Request                            │
└────────────┬─────────────────────────────┘
             │
             ▼
      ┌──────────────┐
      │ Gemini (Primary) │ ← Cloud-basiert, mächtig
      └──────┬───────┘
             │ (bei Fehler)
             ▼
      ┌──────────────┐
      │ Ollama (Fallback) │ ← Lokal, schnell (qwen2.5:0.5b)
      └──────┬───────┘
             │ (bei Fehler)
             ▼
      ┌──────────────┐
      │ Generic Messages │ ← Keyword-basiert
      └──────────────┘
```

#### Gemini (Primary)

- **Model:** gemini-2.5-flash
- **Vorteile:** Hochwertige Antworten, Reasoning, großer Context
- **Nachteile:** Benötigt Internet, API-Key erforderlich
- **Verwendung:** Chat, nl2bash, Greetings, Humor

#### Ollama (Fallback)

- **Model:** qwen2.5:0.5b (500 MB)
- **Vorteile:** Offline, 3x schneller als llama3.2, kein Reasoning-Overhead
- **Nachteile:** Kleineres Model, weniger Context
- **Verwendung:** Wenn Gemini nicht verfügbar

#### Generic Fallback

Falls beide AI-Engines fehlschlagen, nutzt Apollo OS **keyword-basierte Antworten**:

```python
fallback_responses = {
    'greeting_morning': "Good morning! Welcome back to Apollo OS.",
    'greeting_evening': "Good evening! Hope you had a productive day.",
    'random': "All systems operational. Everything running smoothly.",
    'default': "System message acknowledged."
}
```

### 2. 💬 AI-Chat (Rofi-basiert)

**Starten:**
```bash
Super + Shift + Space → "Open Chat"
# ODER:
apollo-chat
```

**Funktionsweise:**
1. Rofi-Dialog öffnet sich
2. Tippe deine Frage ein (z.B. "Erkläre Docker Compose")
3. AI antwortet in Notification (Mako)
4. Antwort wird auch in `~/.config/apollo-os/daemon.log` gespeichert

**Beispiele:**
```
User: "What is the weather in Vienna?"
AI: "I cannot access real-time weather data..."

User: "Generate a Python function to parse JSON"
AI: "import json\n\ndef parse_json(data):\n..."
```

### 3. 🐚 AI-Shell (nl2bash)

**Natural Language to Bash** - Beschreibe was du tun willst, AI generiert Befehl!

**Starten:**
```bash
??
# ODER:
apollo-os-nl2bash.sh
```

**Workflow:**
```
$ ??
Enter command description: "Find all Python files larger than 1MB"
Generated command: find . -name "*.py" -size +1M
Execute? [y/N]: y
```

**Beispiele:**
```
"Show disk usage of home directory"
→ du -h ~/ | sort -h

"Kill all Chrome processes"
→ pkill -9 chrome

"Find files modified in last 24 hours"
→ find . -mtime -1
```

**⚠️ SICHERHEIT:** nl2bash führt Befehle mit `eval` aus - prüfe generierte Befehle!

### 4. 🖼️ Wallpaper-System

**Wallpaper-Verzeichnis:** `~/System/Wallpaper/`

**Wallpaper wechseln:**
```bash
Super + Ctrl + Space
# ODER:
apollo-os-wallpaper-cycle.sh
```

**Funktionsweise:**
1. Script findet alle `.jpg`, `.png`, `.jpeg` in `~/System/Wallpaper/`
2. Sortiert alphabetisch
3. Wechselt zum nächsten Wallpaper
4. Updated Symlink `current.jpg`
5. Reload: swaybg (Niri) oder swaymsg (Sway)
6. Optional: TTS-Ansage (falls DND=false)

**Eigene Wallpaper hinzufügen:**
```bash
cp mein-wallpaper.jpg ~/System/Wallpaper/
apollo-os-wallpaper-cycle.sh  # Wechselt zum neuen Wallpaper
```

**Standard-Wallpaper setzen:**
```bash
ln -sf ~/System/Wallpaper/Apollo-OS-15.png ~/System/Wallpaper/current.jpg
```

### 5. 📊 Session-Statistiken

**Starten:**
```bash
Super + Shift + Space → "Show Statistics"
# ODER:
apollo-os-stats.sh
```

**Angezeigte Informationen:**
- 🕒 Session-Start-Zeit
- ⏱️ Uptime
- 📈 CPU-Auslastung (%)
- 💾 RAM-Nutzung (GB / %)
- 💿 Disk-Nutzung (%)
- 🔋 Batterie-Status (%, Status)
- 🤖 AI-Statistiken (Gemini vs Ollama Calls)
- 📊 Load Average (1/5/15 min)

**Beispiel-Output:**
```
═══════════════════════════════════════
       APOLLO OS SESSION STATS
═══════════════════════════════════════

Session Info:
  Started: 2026-01-12 20:00:00
  Uptime: up 2 hours, 15 minutes
  Load Avg: 0.85, 1.02, 0.97

Resources:
  CPU: 12.5%
  RAM: 6.2 GB / 15.8 GB (39.2%)
  Disk: 45% used (123 GB free)
  Battery: 67% (Discharging)

AI Statistics:
  Total AI calls: 42
  Gemini calls: 38
  Ollama fallbacks: 4
  Success rate: 100%
```

### 6. 🔍 System-Diagnostics

**Starten:**
```bash
Super + Shift + Space → "System Diagnostics"
# ODER:
apollo-diagnose
```

**Prüft:**
- ✅ Systemd Services (daemon, boot-splash, notification-handler)
- ✅ Kritische Pakete (niri, sway, waybar, rofi, etc.)
- ✅ Config-Dateien (Niri, Sway, Waybar, Mako)
- ✅ Scripts (~/.local/bin/apollo-os-*)
- ✅ AI-Engine (Gemini API, Ollama)
- ✅ Audio-System (Piper, LUNA Voice)
- ✅ Telegram Bot (falls konfiguriert)

**Output-Beispiel:**
```
======================================
 APOLLO OS DIAGNOSTICS REPORT
======================================

[✓] Systemd Services
    - apollo-os-daemon.service: active
    - apollo-os-boot.service: inactive (oneshot)

[✓] Critical Packages
    - niri: installed (0.1.10)
    - sway: installed (1.10)
    - waybar: installed (0.11.0)

[✓] AI Engines
    - Gemini: OK (API Key valid)
    - Ollama: OK (qwen2.5:0.5b loaded)

[!] Audio System
    - Piper: not found
    - TTS: disabled

Overall Status: HEALTHY (95/100)
```

### 7. 🌙 Theme-Switcher

**Dark ⟷ Light Mode wechseln:**
```bash
Super + Shift + Space → "Toggle Theme"
# ODER:
apollo-os-theme-switcher.sh toggle
```

**Was wird geändert:**
- ✅ Niri/Sway Config (Border-Farben)
- ✅ Waybar CSS (Background, Text-Farbe)
- ✅ Mako Notifications (Background, Text)
- ✅ Rofi Theme (Dark/Light Variant)
- ✅ SwayOSD (GTK-Theme inversion)
- ✅ GTK-Theme (Adwaita:light/dark)

**Automatische Reloads:**
- Waybar wird neu gestartet
- Mako wird neu gestartet
- SwayOSD wird neu gestartet
- Fenster-Border ändern sich sofort

**Manuell Theme setzen:**
```bash
apollo-os-theme-switcher.sh dark
apollo-os-theme-switcher.sh light
```

### 8. 🔊 Text-to-Speech (TTS)

**Installiert mit:** `apollo-os-audio-installer.sh`

**Predefined Phrases:**
```bash
apollo-speak boot              # "Apollo OS is booting up"
apollo-speak welcome           # "Welcome back to Apollo OS"
apollo-speak lock              # "Screen locked"
apollo-speak unlock            # "Screen unlocked"
apollo-speak shutdown          # "Apollo OS is shutting down"
apollo-speak battery_low       # "Battery low - 20% remaining"
apollo-speak battery_critical  # "Battery critical - 10% remaining"
apollo-speak uplink_ready      # "Uplink established"
apollo-speak uplink_lost       # "Uplink connection lost"
```

**Eigene Texte sprechen:**
```bash
apollo-speak "This is a custom message"
```

**Features:**
- ✅ LUNA Voice (en_GB-jenny_dioco-medium)
- ✅ Chime vor jeder Ansage (880Hz → 660Hz)
- ✅ MD5-Caching (bereits generierte Ansagen werden gecached)
- ✅ DND-Mode Support (`APOLLO_DND=true` deaktiviert TTS)

**TTS in Apollo OS:**
- 🚀 **Boot:** "Apollo OS is booting up" (optional, via boot service)
- 👋 **Login:** "Welcome back to Apollo OS" (in Wrapper-Scripts)
- 🔋 **Batterie:** "Battery low/critical" (bei 20%/10%, in Daemon)

**DND-Mode aktivieren:**
```bash
# In config.env:
APOLLO_DND=true
```

### 9. 📱 Telegram-Integration

**Remote-Steuerung über Telegram Bot:**

**Setup:**
1. Bot erstellen bei @BotFather
2. Token + User-ID in `~/.config/apollo-os/config.env` eintragen
3. Daemon neu starten: `systemctl --user restart apollo-os-daemon.service`

**Befehle:**
```
/start           → Bot starten, Info anzeigen
/status          → System-Status (CPU, RAM, Battery)
/chat <text>     → AI-Chat (nutzt Gemini/Ollama)
/screenshot      → Screenshot machen und senden
/lock            → Screen locken
/notify <text>   → Desktop-Notification senden
```

**Beispiel-Workflow:**
```
User (Telegram): /status
Bot: CPU: 15%, RAM: 45%, Battery: 78%

User: /chat What is the capital of France?
Bot: The capital of France is Paris.

User: /screenshot
Bot: [Sendet aktuellen Screenshot]
```

**Sicherheit:**
- ✅ Nur konfigurierte `TELEGRAM_USER_ID` darf Bot nutzen
- ✅ Andere User bekommen "Unauthorized" Message

---

## 🤖 AI-INTEGRATION

### Gemini Setup

**API-Key holen:**
1. [ai.google.dev](https://ai.google.dev/) besuchen
2. "Get API Key" klicken
3. Key kopieren
4. In `~/.config/apollo-os/config.env` eintragen:
   ```bash
   GEMINI_API_KEY="AIzaSy..."
   ```

**Limits (Free Tier):**
- 60 Requests pro Minute
- 1500 Requests pro Tag
- Ausreichend für normale Nutzung

**Model:** `gemini-2.5-flash` (schnell, kostengünstig)

### Ollama Setup

**Automatisch installiert** vom Apollo-Installer.

**Model-Info:**
- **Name:** qwen2.5:0.5b
- **Größe:** 500 MB
- **Performance:** 3x schneller als llama3.2:1b
- **Vorteil:** Kein Reasoning-Overhead → Schnellere Antworten
- **Nachteil:** Kleinerer Context als größere Models

**Manuell starten:**
```bash
ollama serve
ollama run qwen2.5:0.5b "Hello World"
```

**Anderes Model nutzen:**
```bash
# In config.env:
OLLAMA_MODEL="llama3.2:1b"

# Model pullen:
ollama pull llama3.2:1b
```

### AI-Daemon Logs

**Log-Datei:** `~/.config/apollo-os/daemon.log`

**Beispiel-Log:**
```
2026-01-12 20:15:32 [INFO] Apollo OS Daemon started
2026-01-12 20:15:33 [INFO] Gemini initialized successfully
2026-01-12 20:15:34 [INFO] Ollama initialized successfully
2026-01-12 20:16:10 [INFO] Chat request: "What is Docker?"
2026-01-12 20:16:12 [INFO] Response generated by Gemini
2026-01-12 20:18:45 [WARNING] Gemini failed: Network error, falling back to Ollama
2026-01-12 20:18:46 [INFO] Response generated by Ollama
```

**Log anzeigen:**
```bash
tail -f ~/.config/apollo-os/daemon.log
```

---

## 🎨 THEME-SYSTEM

### Dark Theme (Default)

**Farben:**
- Background: `rgba(20, 20, 20, 0.95)` (fast schwarz)
- Foreground: `#ffffff` (weiß)
- Active Border: `rgba(255, 255, 255, 1.0)` (weiß)
- Inactive Border: `rgba(80, 80, 80, 0.8)` (grau)

**Waybar:**
- Background: `rgba(0, 0, 0, 0.0)` (transparent)
- Text: `#ffffff`
- Active Workspace: `rgba(255, 255, 255, 1.0)` (weiß)

### Light Theme

**Farben:**
- Background: `rgba(240, 240, 240, 0.95)` (hell-grau)
- Foreground: `#1a1a1a` (dunkel-grau)
- Active Border: `rgba(60, 60, 60, 1.0)` (dunkel-grau)
- Inactive Border: `rgba(200, 200, 200, 0.8)` (hell-grau)

**Waybar:**
- Background: `rgba(240, 240, 240, 0.95)` (hell-grau)
- Text: `#1a1a1a`
- Active Workspace: `rgba(60, 60, 60, 0.9)` (dunkel)

### Theme-Dateien

**Niri:**
- Dark: `~/.config/niri/apollo-os-config-{pro|mod}.kdl`
- Light: `~/.config/niri/apollo-os-config-{pro|mod}-light.kdl`

**Sway:**
- Dark: `~/.config/sway/apollo-os-config-{pro|mod}`
- Light: `~/.config/sway/apollo-os-config-{pro|mod}-light`

**Waybar:**
- Dark: `~/.config/waybar/apollo-os-style-{niri|sway}-{pro|mod}.css`
- Light: `~/.config/waybar/apollo-os-style-{niri|sway}-{pro|mod}-light.css`

**Mako:**
- Dark: `~/.config/mako/apollo-os-config-dark`
- Light: `~/.config/mako/apollo-os-config-light`

**Rofi:**
- Dark: `~/.config/rofi/apollo-os-theme-dark.rasi`
- Light: `~/.config/rofi/apollo-os-theme-light.rasi`

---

## 💡 TIPPS & TRICKS

### 1. Schnellerer AI-Response

**Problem:** Gemini antwortet langsam bei schwacher Internetverbindung.

**Lösung:**
```bash
# In config.env Ollama als Primary setzen:
AI_PRIMARY="ollama"  # statt "gemini"
```

### 2. Automatischer Theme-Switch

**Per Tageszeit:**
```bash
# Cronjob erstellen:
crontab -e

# 06:00 Uhr → Light Theme
0 6 * * * ~/.local/bin/apollo-os-theme-switcher.sh light

# 18:00 Uhr → Dark Theme
0 18 * * * ~/.local/bin/apollo-os-theme-switcher.sh dark
```

### 3. Custom Keybindings

**Niri Config editieren:**
```bash
nano ~/.config/niri/apollo-os-config-pro.kdl

# Beispiel: Super+G öffnet GIMP
binds {
    ...
    Mod+G { spawn "gimp"; }
}

# Niri neu laden:
niri msg action reload-config
```

**Sway Config editieren:**
```bash
nano ~/.config/sway/apollo-os-config-pro

# Beispiel: Super+G öffnet GIMP
bindsym $mod+g exec gimp

# Sway neu laden:
Super + Shift + R
```

### 4. Mehrere Monitore

**Niri:**
```kdl
output "eDP-1" {
    scale 1.25
    position x=0 y=0
}

output "DP-2" {
    scale 1.0
    position x=1536 y=0  # Rechts neben eDP-1
}
```

**Sway:**
```sway
output eDP-1 scale 1.25 pos 0 0
output DP-2 scale 1.0 pos 1536 0
```

**Monitor-Namen finden:**
```bash
# Niri:
niri msg outputs

# Sway:
swaymsg -t get_outputs
```

### 5. Custom Wallpaper-Rotation

**Automatisch alle 30 Minuten:**
```bash
# Cronjob:
*/30 * * * * ~/.local/bin/apollo-os-wallpaper-cycle.sh
```

### 6. Notification-Filter

**Mako konfigurieren:**
```bash
nano ~/.config/mako/apollo-os-config-dark

# Kritische Notifications länger anzeigen:
[urgency=critical]
default-timeout=10000
background-color=#e01b24

# Unwichtige Notifications kürzer:
[app-name=Telegram]
default-timeout=3000
```

### 7. Power-Profile wechseln

**Manuell:**
```bash
# Balanced (default)
powerprofilesctl set balanced

# Performance
powerprofilesctl set performance

# Power-Saver
powerprofilesctl set power-saver

# Status:
powerprofilesctl
```

**Über Quick Menu:**
```
Super + Shift + Space → "Power Profiles"
```

---

## 🛠️ TROUBLESHOOTING

### Problem: Gemini API-Key funktioniert nicht

**Symptome:**
- AI-Chat gibt "API Key invalid" Error
- Daemon-Log zeigt `[ERROR] Gemini initialization failed`

**Lösung:**
```bash
# 1. API-Key prüfen
cat ~/.config/apollo-os/config.env | grep GEMINI

# 2. Key testen:
curl -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=DEIN_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"contents":[{"parts":[{"text":"Hello"}]}]}'

# 3. Falls "API_KEY_INVALID":
# → Neuen Key holen auf ai.google.dev
# → In config.env eintragen
# → Daemon neu starten:
systemctl --user restart apollo-os-daemon.service
```

### Problem: Kein Wallpaper in Niri

**Symptome:**
- Schwarzer Hintergrund nach Login
- `ps aux | grep swaybg` zeigt keinen Prozess

**Lösung:**
```bash
# 1. Wallpaper existiert?
ls -la ~/System/Wallpaper/current.jpg

# 2. Manuell swaybg starten:
swaybg -i ~/System/Wallpaper/current.jpg -m fill &

# 3. Falls funktioniert → Wrapper-Script prüfen:
nano ~/.local/bin/apollo-os-wrapper-niri.sh
# Stelle sicher dass swaybg-Block vorhanden ist (Zeile ~92-99)

# 4. Neu einloggen
```

### Problem: Waybar zeigt nicht an

**Symptome:**
- Keine Bar oben/unten
- `ps aux | grep waybar` zeigt keinen Prozess

**Lösung:**
```bash
# 1. Manuell starten:
waybar -c ~/.config/waybar/apollo-os-config-niri-pro \
       -s ~/.config/waybar/apollo-os-style-niri-pro.css &

# 2. Falls Fehler → Config-Syntax prüfen:
waybar --help

# 3. Log anzeigen:
journalctl --user -u waybar -f

# 4. Config neu deployen:
cd ~/Downloads/apollo-os/v0.4.1
./apollo-os-install.sh  # Nur Configs neu kopieren
```

### Problem: Ollama antwortet nicht

**Symptome:**
- AI-Chat hängt bei "Generating response..."
- Daemon-Log: `[ERROR] Ollama failed: timeout`

**Lösung:**
```bash
# 1. Ollama-Service prüfen:
systemctl status ollama

# 2. Falls nicht läuft:
sudo systemctl start ollama

# 3. Model vorhanden?
ollama list

# Falls qwen2.5:0.5b fehlt:
ollama pull qwen2.5:0.5b

# 4. Manuell testen:
ollama run qwen2.5:0.5b "Hello"
```

### Problem: TTS funktioniert nicht

**Symptome:**
- `apollo-speak welcome` gibt Fehler
- Keine Stimme bei Login

**Lösung:**
```bash
# 1. Audio-System installiert?
which piper

# Falls nicht:
~/.local/bin/apollo-os-audio-installer.sh

# 2. LUNA Voice vorhanden?
ls ~/.local/share/piper/voices/

# 3. Manuell testen:
echo "Test" | piper \
  --model ~/.local/share/piper/voices/en_GB-jenny_dioco-medium.onnx \
  --output_file /tmp/test.wav && aplay /tmp/test.wav

# 4. Falls funktioniert → apollo-speak prüfen:
bash -x ~/.local/bin/apollo-speak.sh welcome
```

### Problem: Rofi zeigt kein Theme

**Symptome:**
- Rofi sieht aus wie Default-Theme
- Dark/Light Theme wird nicht angewendet

**Lösung:**
```bash
# 1. ROFI_THEME_FILE gesetzt?
echo $ROFI_THEME_FILE

# 2. Manuell Theme setzen:
rofi -show drun -theme ~/.config/rofi/apollo-os-theme-dark.rasi

# 3. Falls funktioniert → Config prüfen:
# Niri:
grep ROFI_THEME ~/.config/niri/apollo-os-config-pro.kdl

# Sway:
grep ROFI_THEME ~/.config/sway/apollo-os-config-pro

# 4. Falls fehlt → Configs neu deployen
```

### Problem: Notifications erscheinen nicht

**Symptome:**
- `notify-send "Test"` zeigt nichts
- Mako läuft nicht

**Lösung:**
```bash
# 1. Mako läuft?
ps aux | grep mako

# 2. Manuell starten:
mako --config ~/.config/mako/apollo-os-config-dark &

# 3. Test:
notify-send "Test" "Hello World"

# 4. Mako-Log:
journalctl --user -u mako -f
```

### Problem: Swaylock sperrt nicht

**Symptome:**
- `Super + L` macht nichts
- Swaylock gibt Fehler

**Lösung:**
```bash
# 1. SWAYLOCK_CONFIG gesetzt?
echo $SWAYLOCK_CONFIG

# 2. Manuell testen:
swaylock -f -C ~/.config/swaylock/apollo-os-config-dark

# 3. Falls "cannot read config":
# → Config neu deployen
cp ~/Downloads/apollo-os/v0.4.1/config-data/swaylock/* \
   ~/.config/swaylock/
```

---

## 📖 WEITERE RESSOURCEN

### Offizielle Dokumentation

- **Niri:** https://github.com/YaLTeR/niri
- **Sway:** https://swaywm.org/
- **Waybar:** https://github.com/Alexays/Waybar
- **Rofi:** https://github.com/davatorium/rofi
- **Gemini:** https://ai.google.dev/gemini-api/docs
- **Ollama:** https://ollama.com/

### Apollo OS Links

- **GitHub:** [Coming Soon]
- **Changelog:** `/home/apollo/AIQSAN01/apollo/apollo-os-dev/v0.4.1/CHANGELOG.md`
- **Fehlerberichte:** `CRITICAL_ERRORS_FOUND.md`
- **Implementation:** `IMPLEMENTIERTE_FEATURES.md`

### Community

- **Matrix:** [Coming Soon]
- **Discord:** [Coming Soon]
- **E-Mail:** manuel@kraibacher.com

---

## 📝 CHANGELOG

### v0.4.1 (2026-01-12)

**✅ Neue Features:**
- Wallpaper-Cycle System (Super+Ctrl+Space)
- Quick Action Menu (Super+Shift+Space, 13 Aktionen)
- Session-Statistiken (apollo-os-stats.sh)
- Graceful AI-Degradation (Fallback-Messages)
- Error Recovery im Installer
- Audio-System mit LUNA Voice
- TTS-Integration (Login, Batterie-Warnungen)

**🔧 Fixes:**
- swaybg-Start in Niri-Wrapper hinzugefügt
- Light-Themes differenziert (Niri, Sway, Waybar CSS)
- Rofi-Theme Parameter hinzugefügt
- Tilde durch $HOME ersetzt
- Ollama Model: qwen2.5:0.5b (statt llama3.2:1b)
- Englisch-only AI-Prompts

**🎨 Verbesserungen:**
- Rebranding: Apollo Orbit/Grid
- Desktop-Einträge aktualisiert
- Keybindings konsistent in Niri & Sway

---

## 🙏 CREDITS

**Entwickelt von:** Manuel Kraibacher  
**E-Mail:** manuel@kraibacher.com  
**Jahr:** 2026  
**Lizenz:** MIT

**Besonderer Dank an:**
- YaLTeR (Niri WM)
- Sway Development Team
- Alexays (Waybar)
- Google (Gemini API)
- Ollama Team
- Piper TTS Project

---

## 📜 LIZENZ

```
MIT License

Copyright (c) 2026 Manuel Kraibacher

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

**🚀 Viel Spaß mit Apollo OS! 🚀**
