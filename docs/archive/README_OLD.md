# Apollo OS (v0.4.1)

> **A Next-Generation Custom Layer for Fedora Workstation**
> Combining aesthetics, productivity, and AI-driven interaction.

---

**Copyright © 2026 by Manuel Kraibacher**
**Project:** Apollo OS
**Version:** v0.4.1 (Bug Fix Release)
**Base System:** Fedora 43 Workstation

---

## 📋 Ueber dieses Projekt

Apollo OS ist kein klassisches Distributions-Derivat, sondern ein intelligenter "Layer", der sich ueber eine frische Fedora Installation legt. Es transformiert die Workstation in ein futuristisches, KI-unterstuetztes System mit zwei primaeren Window-Managern: **Niri** (Scrollable Tiling) und **Sway** (Classic Tiling).

Das System zeichnet sich durch seine "Persoenlichkeit" aus - es kommuniziert proaktiv mit dem Nutzer via Telegram und Desktop-Benachrichtigungen, generiert durch Google Gemini.

## 🚀 Changelog

### Version v0.4.1 (Bug Fix Release)
*   **KRITISCH:** 36 hardcodierte `/home/apollo/` Pfade in Niri-Configs behoben
*   **KRITISCH:** 4 hardcodierte Pfade in Sway-Configs behoben
*   **KRITISCH:** Boot-Service %h Expansion behoben (funktioniert jetzt in System-Services)
*   **KRITISCH:** Session-Selector $USER Problem behoben (globale Wrapper-Pfade)
*   **FIX:** Nicht-existierende Script-Referenzen entfernt (wallpaper-cycle.sh, toggle-center.sh)
*   **FIX:** Niri spawn-at-startup Duplikate entfernt (Wrapper startet Services)
*   **DOC:** Alle Versionsnummern vereinheitlicht
*   **DOC:** OPUS_REVIEW_REPORT.md hinzugefuegt

### Version v0.3.0 (Feature Complete)
*   **Swaylock:** Lockscreen mit Blur-Effekt und High Contrast Design
*   **SwayOSD:** Volume/Brightness OSD mit High Contrast Styling
*   **greetd/tuigreet:** Terminal-basierter Login Manager mit ASCII-Art
*   **Boot Splash:** ASCII Logo waehrend des Bootvorgangs
*   **Interactive Chat:** Rofi-basierte Chat-Funktion mit Apollo AI
*   **Notifications:** Interaktive Benachrichtigungen mit Click-to-Reply

### Version v0.1.1 (Initial-Release)
*   **Core:** Vollständige Projektstruktur
*   **Architecture:** Dual-Mode System (PRO/MOD) für Niri und Sway
*   **AI:** Hybrid Engine (Gemini + Ollama) vollständig implementiert
*   **Installer:** Kompletter automatischer Installer

---

## 🛠 Features & Funktionen

### 1. Dual-Mode Window Management
Apollo OS bietet für jeden Window Manager zwei Betriebsmodi, die beim Login gewählt oder per Skript gewechselt werden können:
*   **PRO Mode:** Minimalistisch, High-Performance, ablenkungsfrei.
*   **MOD Mode:** Visuell beeindruckend, Blur-Effekte, Animationen.
*   *Zusätzlich:* Globaler Light/Dark Mode Switch.

### 2. Smart UI (Waybar & OSD)
Die Statusleiste ist nicht nur Anzeige, sondern Werkzeug:
*   **Interaktive Module:** Klick auf WLAN/BT öffnet schwebende Manager-Fenster.
*   **Power-Management:** Direktzugriff auf Performance-Profile (Energiesparen/Ausbalanciert/Leistung) über das Batterie-Icon.
*   **Visual Feedback:** On-Screen-Display (OSD) Balken für Lautstärke und Helligkeit.

### 3. Apollo Intelligence Core
Ein Hintergrund-Daemon, der das System "lebendig" macht:
*   **Telegram-Integration:** Sendet Sicherheitswarnungen (Login/Unlock) und Statusberichte.
*   **Gemini-Personality:** Wünscht "Guten Morgen", macht gelegentlich Witze ("Fluxkompensator"), fragt bei Inaktivität nach dem Status des Nutzers.
*   **Interaktiver Chat:** Schwebendes Terminal für direkte Unterhaltungen mit der System-KI.

### 4. Boot & Login Experience
*   **Boot:** Verbose-Mode (Textbasiert) mit ASCII-Art Pause ("Cyberpunk Feeling").
*   **Login:** Terminal-basierter Login Manager (`tuigreet`) für nahtlosen Übergang.

---

## 📦 Paket-Übersicht

Das Installations-Skript (`install.sh`) richtet folgende Hauptkomponenten ein:

### Core System
- `niri` (Wayland Scrollable Tiling WM)
- `sway` (Wayland Tiling WM)
- `waybar` (Status Bar)
- `rofi-wayland` / `fuzzel` (App Launcher)
- `alacritty` / `kitty` (Terminal)
- `swaylock-effects` (Lockscreen mit Blur)
- `swayidle` (Idle Management)
- `swayosd` (On-Screen Display)

### Python / AI Backend
- `python3-pip`
- `google-generativeai` (Gemini API SDK)
- `python-telegram-bot`
- `psutil` (System Monitoring)

### Connectivity & Tools
- `NetworkManager` + `nm-connection-editor`
- `blueman`
- `pulseaudio-utils` / `pavucontrol`
- `brightnessctl`

---

## 🔧 Installation & Nutzung

*(Dieser Abschnitt wird in zukünftigen Versionen mit den konkreten Git-Befehlen gefüllt)*

1.  **Repository klonen:**
    ```bash
    git clone https://github.com/manuelkraibacher/apollo-os-dev.git
    cd apollo-os-dev/v0.1.0
    ```

2.  **Installer starten:**
    ```bash
    chmod +x install.sh
    ./install.sh
    ```

3.  **Setup-Dialog:**
    Das Skript fragt interaktiv nach:
    - Google Gemini API Key
    - Telegram Bot Token & User ID

---

## 📂 Dateistruktur & Namensgebung

Alle projektbezogenen Dateien folgen dem Präfix `apollo-os-` für einfache Auffindbarkeit.

```text
/home/apollo/AIQSAN01/apollo/apollo-os-dev/v0.1.0/
├── install.sh                  # Haupt-Installer
├── apollo-os-daemon.py         # Der KI-Kern
├── config/
│   ├── apollo-os-niri-pro.kdl
│   ├── apollo-os-niri-mod.kdl
│   ├── apollo-os-sway-pro.config
│   └── ...
└── assets/
    └── apollo-os-boot-logo.txt
```
