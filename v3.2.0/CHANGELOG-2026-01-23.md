# Apollo OS - Changelog 2026-01-23

---

## 🤖 ANLEITUNG FÜR LLMs: Wie mit diesem CHANGELOG zu arbeiten ist

**Zweck dieses Dokuments:** Dieses CHANGELOG dokumentiert NICHT was bereits implementiert wurde, sondern WIE Änderungen und Erweiterungen zu implementieren sind. Es dient als vollständige Implementierungsanleitung für ein neu aufgesetztes "altes" Apollo OS System.

### Workflow für LLMs bei der Implementierung

#### 1. Task-Management mit Tools

**KRITISCH WICHTIG:** Du MUSST für jeden Abschnitt in diesem CHANGELOG strukturiert vorgehen:

**Schritt 1 - Tasks erstellen:**
```
Für jeden Abschnitt (z.B. Abschnitt 10, 11, 12):
- Erstelle mit TaskCreate mehrere granulare Sub-Tasks
- Beispiel Abschnitt 11 (Audio-Feedback):
  * Task 1: "Audio-Verzeichnis erstellen"
  * Task 2: "voice-start.wav generieren mit ffmpeg"
  * Task 3: "voice-end.wav generieren mit ffmpeg"
  * Task 4: "voice-input Script um Audio-Playback erweitern"
  * Task 5: "Audio-Files testen"
```

**Schritt 2 - Tasks abarbeiten:**
```
- Nutze TaskUpdate um jeden Task auf "in_progress" zu setzen BEVOR du damit beginnst
- Arbeite einen Task nach dem anderen ab
- TaskUpdate auf "completed" setzen NACHDEM Task erfolgreich abgeschlossen
```

**Schritt 3 - Selbst-Testing:**
```
Nach JEDEM implementierten Task MUSST du testen:
- Führe das generierte Script/Binary aus
- Prüfe auf Fehler (Exit Codes, Logs)
- Teste die Funktionalität
- Prüfe auf Logikfehler
- Verifiziere dass alle Dependencies vorhanden sind
```

**Beispiel Testing-Ansatz:**
```bash
# Nach Generierung von voice-start.wav:
ls -lh ~/.local/share/apollo-os/sounds/voice-start.wav  # Existiert File?
file ~/.local/share/apollo-os/sounds/voice-start.wav    # Korrektes Format?
pw-play ~/.local/share/apollo-os/sounds/voice-start.wav # Funktioniert Playback?
```

#### 2. Fortschritts-Protokoll erstellen

**Du MUSST ein separates Protokoll-File erstellen:**

**File-Pfad:** `~/apollo-os-implementation-progress.md`

**Struktur des Protokolls:**
```markdown
# Apollo OS Implementation Progress
Datum: YYYY-MM-DD HH:MM

## Abschnitt 10: Hyprlock Integration

### Task 1: apollo-os-lock-hypr.sh erstellen
- Status: ✅ Completed
- Gestartet: 2026-01-25 10:00
- Abgeschlossen: 2026-01-25 10:05
- Testing: ✅ Script ausführbar, TTS funktioniert, hyprlock startet
- Probleme: Keine

### Task 2: Shortcut in Niri Configs hinzufügen
- Status: ✅ Completed
- Gestartet: 2026-01-25 10:05
- Abgeschlossen: 2026-01-25 10:15
- Testing: ✅ Ctrl+Super+L Shortcut funktioniert in allen 14 Configs
- Probleme:
  - Problem 1: sed Befehl funktionierte nicht bei config-minimal.kdl
  - Lösung: Manuelle Edit statt sed verwendet

### Task 3: Hyprlock Config anpassen
- Status: 🔄 In Progress
- Gestartet: 2026-01-25 10:15
- Testing: Pending
- Probleme:
  - Problem 1: Wallpaper-Pfad ~/System/Wallpaper/current.jpg existiert nicht
  - Nächster Schritt: Prüfen ob Verzeichnis existiert, ggf. erstellen

## Abschnitt 11: Audio-Feedback
[...]

## Statistik
- Abgeschlossene Tasks: 2
- Laufende Tasks: 1
- Offene Tasks: 15
- Fehlerhafte Tasks: 0
- Gesamtzeit: 15 Minuten
```

**Das Protokoll MUSS enthalten:**
- ✅ Jeden Task mit Status (Pending/In Progress/Completed/Failed)
- ✅ Start- und End-Zeit pro Task
- ✅ Testing-Ergebnisse (Was wurde getestet, Resultat)
- ✅ Alle aufgetretenen Probleme mit Lösung
- ✅ Hinweise auf Abhängigkeiten zu anderen Tasks
- ✅ Am Ende: Statistik und Zusammenfassung

#### 3. Umgang mit Problemen

**Wenn ein Task fehlschlägt:**
```markdown
### Task X: [Name]
- Status: ❌ Failed
- Problem: ModuleNotFoundError: No module named 'vosk'
- Fehleranalyse:
  1. Python-Modul vosk nicht installiert
  2. pip selbst nicht verfügbar
- Lösungsversuch 1: python3 -m pip install vosk
  - Ergebnis: Fehler "No module named pip"
- Lösungsversuch 2: python3 -m ensurepip --user
  - Ergebnis: ✅ Erfolg, pip installiert
- Lösungsversuch 3: python3 -m pip install vosk
  - Ergebnis: ✅ Erfolg
- Status aktualisiert: ✅ Completed (nach Problemlösung)
```

#### 4. Reihenfolge der Abschnitte

**Beachte Dependencies zwischen Abschnitten:**
- Abschnitt 11 (Audio-Feedback) muss VOR Abschnitt 12 (Wake Word) implementiert werden
- Grund: Wake Word System benötigt voice-start.wav und voice-end.wav
- Dokumentiere solche Dependencies im Fortschritts-Protokoll

#### 5. Testing-Checkliste pro Abschnitt

**Nach Abschluss eines Abschnitts erstelle Testing-Checkliste:**
```markdown
## Abschnitt 11: Audio-Feedback - Testing Checkliste

- [x] Audio-Files existieren
  - [x] ~/.local/share/apollo-os/sounds/voice-start.wav
  - [x] ~/.local/share/apollo-os/sounds/voice-end.wav
- [x] File-Größe korrekt (~14 KB pro File)
- [x] Audio-Format korrekt (WAV, 44.1kHz)
- [x] Playback funktioniert
  - [x] pw-play voice-start.wav → Ton hörbar
  - [x] pw-play voice-end.wav → Ton hörbar
  - [x] Sounds unterscheidbar (aufsteigend vs. absteigend)
- [x] Integration in voice-input Script
  - [x] Start-Sound wird abgespielt bei Aufnahme-Beginn
  - [x] Ende-Sound wird abgespielt nach Transkription
  - [x] Sounds blockieren Script nicht (Background Execution)
- [x] Testing mit beiden Input-Methoden
  - [x] Super+V Toggle funktioniert mit Sounds
  - [x] Rechte Strg Push-to-Talk funktioniert mit Sounds
- [ ] Edge Cases getestet
  - [x] Was passiert wenn Sound-Files fehlen? (Script läuft trotzdem)
  - [x] Was passiert wenn pw-play nicht verfügbar? (Silent fail)
```

#### 6. Finale Verifikation

**Nachdem ALLE Abschnitte implementiert sind:**
```markdown
## Finale System-Verifikation

### Alle Services laufen
- [ ] systemctl --user status apollo-wake.service → active (running)
- [ ] systemctl --user status apollo-rightctrl-voice.service → active (running)
- [ ] systemctl --user status apollo-os-*.service → Alle aktiv

### Alle Shortcuts funktionieren
- [ ] Super+L → swaylock
- [ ] Ctrl+Super+L → hyprlock
- [ ] Super+V → Voice Input Toggle
- [ ] Rechte Strg → Push-to-Talk

### Alle Audio-Feedbacks funktionieren
- [ ] Voice Input Start → voice-start.wav
- [ ] Voice Input Ende → voice-end.wav
- [ ] Wake Word "Apollo" → voice-start.wav
- [ ] Wake Word Command Ende → voice-end.wav

### Alle Configs konsistent
- [ ] 14 Niri Configs haben Bibata-Modern-Classic Cursor
- [ ] 14 Niri Configs haben Ctrl+Mod+L Shortcut
- [ ] Hyprlock nutzt JetBrains Mono Schrift
- [ ] Hyprlock nutzt gleiches Wallpaper wie Niri
```

#### 7. Dokumentation aktualisieren

**Am Ende der Implementierung:**
- Erstelle `IMPLEMENTATION-SUMMARY.md` mit:
  - Alle implementierten Abschnitte
  - Gesamtzeit
  - Aufgetretene Probleme und Lösungen
  - Hinweise für zukünftige Implementierungen
  - Bekannte Einschränkungen

#### 8. Best Practices

**Während der Implementierung:**
- ✅ IMMER Code lesen BEVOR du ihn änderst
- ✅ IMMER Backups erstellen vor destruktiven Änderungen
- ✅ IMMER testen nach jeder Änderung
- ✅ NIEMALS Befehle mit `sudo` ohne Bestätigung ausführen
- ✅ NIEMALS Placeholder-Werte in Production-Code
- ✅ IMMER vollständige Pfade verwenden (nicht relative Pfade)
- ✅ IMMER Error-Handling überprüfen
- ✅ IMMER Logs ansehen bei Problemen (`journalctl`)

**Code-Qualität:**
- Kein Copy-Paste ohne Verständnis
- Keine Magic Numbers (dokumentiere Werte wie Frequenzen, Timeouts)
- Konsistente Namensgebung
- Kommentare für komplexe Logik

#### 9. Wenn du nicht weiterkommst

**Eskalations-Stufen:**
1. Logs prüfen (`journalctl`, Fehlerausgaben)
2. Dependencies verifizieren (Module, Binaries, Files)
3. Manuelle Tests durchführen (einzelne Befehle isoliert testen)
4. Im Fortschritts-Protokoll dokumentieren: "BLOCKED - Reason: XYZ"
5. Alternativen prüfen (z.B. paplay statt pw-play)
6. User fragen wenn unlösbar

### Zusammenfassung

**Ein LLM das mit diesem CHANGELOG arbeitet MUSS:**
1. ✅ Tasks mit TaskCreate/TaskUpdate/TaskList verwalten
2. ✅ Fortschritts-Protokoll in `~/apollo-os-implementation-progress.md` führen
3. ✅ JEDEN Task selbst testen (Funktionalität + Logikfehler)
4. ✅ Probleme dokumentieren mit Lösungen
5. ✅ Reihenfolge beachten (Dependencies)
6. ✅ Testing-Checklisten abarbeiten
7. ✅ Finale Verifikation durchführen
8. ✅ Implementation-Summary erstellen

**Das Resultat ist:** Ein vollständig funktionsfähiges Apollo OS System mit allen dokumentierten Erweiterungen, wobei jeder Schritt getestet und dokumentiert wurde.

---

## 🔴 WICHTIG: Offene Aufgaben / To-Do Liste

### Kritische Bugfixes
- [ ] **Waybar i3-contrast: App Icon Benachrichtigungen**
  - Problem: Wenn eine App etwas meldet, färbt sich nur ein schmaler roter Balken (so breit wie das Icon selbst), aber nicht die ganze rechte dunkelgraue Box die die Icons beinhaltet
  - Datei: `~/.config/waybar/style-i3-contrast.css`
  - Ziel: Gesamte Tray-Box soll rot werden bei Benachrichtigungen

- [ ] **SDDM Wallpaper-Übernahme funktioniert nicht**
  - Problem: Das aktuelle Niri-Wallpaper wird nicht automatisch beim SDDM Login-Bildschirm übernommen
  - Aktuell: Manuelles Kopieren nach `/usr/share/backgrounds/apollo-os/login.jpg` erforderlich
  - Ziel: Automatische Synchronisation des Niri-Wallpapers zu SDDM

- [ ] **Bluetooth: Maus-Verbindungsproblem beheben**
  - Problem: Beim Verbinden einer Bluetooth-Maus gibt es Probleme/Fehler
  - Analyse und Fehlerbehebung erforderlich
  - Logs prüfen, evtl. bluez/blueman Konfiguration anpassen

### Niri Window Manager Optimierungen
- [ ] **Alle Shortcuts bei Niri überdenken**
  - Aktuelle Tastenkombinationen auf Sinnhaftigkeit prüfen
  - Konsistenz zwischen verschiedenen Visual Modes sicherstellen
  - Dokumentation der Shortcuts erstellen

- [x] **Hyprland Mauszeiger auch bei Niri verwenden** ✅ (Dokumentiert in Abschnitt 10)
  - Cursor-Theme: Bibata-Modern-Classic
  - In allen 14 Niri Configs integriert

- [x] **Hyprland Lockscreen auch für Niri evaluieren** ✅ (Dokumentiert in Abschnitt 10)
  - hyprlock funktioniert unter Niri
  - Dual-Lockscreen-Lösung: Super+L (swaylock) + Ctrl+Super+L (hyprlock)
  - Beide mit TTS-Feedback

- [ ] **Visual Modes: Bessere Namen vergeben**
  - Aktuelle Namen: classic, developer, enterprise, i3, i3-retro, i3-contrast, minimal, modern, nova, orbit, professional, sgi, tech-blue
  - Problem: Namen nicht intuitiv oder beschreibend genug
  - Vorschläge prüfen und einheitliche Namenskonvention entwickeln
  - Beispiele: "Retro Terminal" statt "i3-retro", "High Contrast" statt "i3-contrast"
  - Namen sollten Funktion/Zweck widerspiegeln
  - Umbenennung in allen Configs, Scripts und Dokumentation

### UI/UX Verbesserungen
- [x] **Spracheingabe: Akustisches Feedback hinzufügen** ✅ (Dokumentiert in Abschnitt 11)
  - **Start-Sound:** Zwei aufsteigende Töne (800Hz → 1000Hz, Star Trek Stil)
  - **Ende-Sound:** Zwei absteigende Töne (1000Hz → 800Hz)
  - Generiert mit ffmpeg, sine waves mit fade-in/out
  - Audio-Files: `~/.local/share/apollo-os/sounds/voice-start.wav` und `voice-end.wav`
  - Playback via `pw-play` (PipeWire)
  - Detaillierte Implementierungsanleitung mit allen ffmpeg-Befehlen vorhanden

- [ ] **Spracheingabe-Benachrichtigung optimieren**
  - Aktuelle Animation und Text überarbeiten
  - Feedback während Transkription verbessern
  - Fehlerbehandlung bei fehlgeschlagener Transkription

- [x] **Wake Word "Apollo" für Sprachbefehle** ✅ (Dokumentiert in Abschnitt 12)
  - System existiert bereits: `apollo-wake-listener.py`
  - Wake Word: "Apollo"
  - Muss repariert werden (Python-Module fehlen)
  - Star Trek Sounds hinzufügen (nach Wake Word Detection & nach Befehl-Ausführung)
  - Details siehe Abschnitt 12

- [x] **Rechte Strg-Taste: Push-to-Talk Modus + Auto-Enter** ✅
  - **UMGESETZT:** Taste halten = aufnehmen, loslassen = stoppen & transkribieren
  - Nach Transkription wird automatisch Enter gedrückt
  - Perfekt für schnelle Terminal-Befehle per Sprache
  - Script: `~/.local/bin/apollo-os-rightctrl-voice.py` (Push-to-Talk Logik)
  - Script: `~/.local/bin/voice-input` (Auto-Enter mit wtype -k Return)
  - Service neu gestartet und aktiv

- [ ] **Mako Benachrichtigungs-Design überarbeiten**
  - Einheitliches Design für alle Visual Modes
  - Farben, Schriftgrößen, Positionen optimieren
  - Konsistenz mit Waybar und Niri-Theme
  - **Icons aus Benachrichtigungen entfernen** (icons=0)
  - Nur Text-basierte Benachrichtigungen für minimalistisches Design

- [ ] **TTS-Ansagen kürzen**
  - Datei: `~/.local/bin/apollo-os-welcome-tts.sh`
  - Aktuell: "Apollo OS System Core gestartet. Alle Module initialisiert. Diagnose abgeschlossen. Netzwerkverbindung etabliert. Datenlink aktiv. Bereit für Einsatz."
  - Ziel: Kürzere, prägnantere Ansage (z.B. "Apollo OS bereit")

- [ ] **Benachrichtigungen generell überarbeiten**
  - Konsistente Formulierungen
  - Einheitliche Icons
  - Timing und Dauer optimieren

- [ ] **SDDM Theme weiter überarbeiten**
  - Design-Feinschliff
  - Animation beim Login (optional)
  - Keyboard-Layout-Anzeige (falls gewünscht)

### Installer & System
- [ ] **Hyprland aus apollo-os-install.sh entfernen**
  - Nur noch Niri installieren und konfigurieren
  - Hyprland-spezifische Configs und Dependencies entfernen
  - Installations-Script vereinfachen

- [ ] **Kitty Terminal für Niri unabhängig von Hyprland**
  - Kitty-Konfiguration aus Hyprland-Setup extrahieren
  - Alle Kitty-Settings direkt für Niri implementieren
  - Kitty sollte auch ohne Hyprland-Installation voll funktionsfähig sein
  - Config-Dateien, Themes, Shortcuts eigenständig einrichten

- [ ] **Foot Terminal: zsh als Standard-Shell**
  - foot soll zsh statt bash verwenden
  - Eigene zsh-Konfiguration für foot erstellen
  - Datei: `~/.config/foot/foot.ini` - shell anpassen
  - Separate zsh-Config: `~/.config/foot/zshrc` oder ähnlich
  - Unterscheidung zwischen verschiedenen Terminal-Prompts möglich

- [ ] **Terminal-basiertes Bluetooth-Menü hinzufügen**
  - TUI (Text User Interface) für Bluetooth-Verwaltung
  - Integration mit bluetoothctl oder blueman-cli
  - Tastenkombination definieren (z.B. Super+Shift+B)

- [ ] **Terminal-basiertes WLAN-Menü hinzufügen**
  - TUI für WLAN-Verwaltung (nmtui oder nmcli wrapper)
  - Netzwerk-Auswahl, Passwort-Eingabe
  - Tastenkombination definieren (z.B. Super+Shift+W)

- [ ] **Flatpak Installation: Auswahlmöglichkeit während Installation**
  - Installer-Menü: Flatpak-Pakete auswählen
  - Optionen: "Alle installieren" / "Keine installieren" / "Auswahl treffen"
  - Bei "Auswahl treffen": Checkboxen für einzelne Apps (Firefox, Chrome, LibreOffice, etc.)
  - Kategorien: Browser, Office, Media, Development, etc.
  - Installation kann viel Zeit sparen wenn nicht benötigt

- [ ] **Update-Script überarbeiten**
  - Datei: `apollo-os-update.sh` (oder ähnlich)
  - Bessere Fehlerbehandlung bei Änderungen
  - Backup vor Updates erstellen
  - Rollback-Funktion bei fehlgeschlagenen Updates
  - Changelog anzeigen vor Update
  - Konflikte in Config-Dateien erkennen und melden
  - Interaktiver Modus vs. automatischer Modus

- [ ] **Apollo OS Version konsistent aktualisieren**
  - Aktuell: v3.1.0 (aber möglicherweise nicht überall eingetragen)
  - Version überall konsistent verwenden:
    - `apollo-os-install.sh` Header
    - README.md
    - Waybar (Version-Anzeige)
    - SDDM Theme
    - TTS Welcome-Ansage
    - About-Dialog / Info-Script
  - Versionsverwaltung: Semantic Versioning (Major.Minor.Patch)
  - VERSION-Datei erstellen für zentrale Verwaltung

### Benachrichtigungen & Audio Control
- [ ] **Quick Menu komplett überarbeiten**
  - Aktuelles Quick Menu modernisieren und erweitern
  - Neues Design im Apollo OS Stil (Dark Grayscale wie Rofi/Mako)
  - Shortcut zum Aufrufen überdenken (aktuell: ?)
  - Bessere Kategorisierung der Optionen
  - Schnellzugriff auf häufig genutzte Funktionen
  - Visuelles Feedback bei Toggle-Aktionen
  - Keyboard-Navigation verbessern

- [ ] **Quick Menu: Animationen deaktivieren**
  - Toggle-Funktion zum Ein/Ausschalten aller Animationen im aktuellen Design
  - Betrifft: Waybar-Animationen, Fenster-Animationen, Transitions in Niri
  - Status soll persistent gespeichert werden (pro Visual Mode)
  - Hilfreich für Performance auf schwächerer Hardware
  - Für "cleane" Screenshots ohne ablenkende Animationen

- [ ] **Quick Menu: Mako Benachrichtigungen stumm schalten**
  - Toggle-Funktion im Quick Menu hinzufügen
  - Mako-Benachrichtigungen können ein/ausgeschaltet werden
  - Status soll persistent gespeichert werden

- [ ] **Quick Menu: TTS-Ansagen stumm schalten**
  - Toggle-Funktion im Quick Menu hinzufügen
  - TTS-Ansagen können ein/ausgeschaltet werden
  - Status soll persistent gespeichert werden
  - Betrifft: Welcome TTS, Voice Input TTS, etc.

- [ ] **Waybar: Status-Icon für Benachrichtigungen/TTS**
  - Icon in Waybar einfügen (rechts in der Bar)
  - Zeigt an ob Mako Benachrichtigungen stumm sind (z.B. 🔕/🔔)
  - Zeigt an ob TTS-Ansagen stumm sind (z.B. 🔇/🔊)
  - Click öffnet Quick Menu für Toggle
  - Tooltip zeigt aktuellen Status

### Zwischenablage & Productivity
- [ ] **Clipboard History Manager implementieren**
  - Zwischenablage-Verlauf speichern (letzte X Einträge)
  - Tastenkombination definieren (z.B. Super+Shift+V oder Super+C)
  
- [ ] **Clipboard Manager UI erstellen**
  - Floating Fenster im Terminal-Stil (wie Rofi/Mako Design)
  - Dark Grayscale Theme (#1a1a1a Hintergrund)
  - Liste aller gespeicherten Clipboard-Einträge
  - Pfeiltasten (↑/↓) zum Durchschalten der Einträge
  - Enter: Kopiert Auswahl in Zwischenablage ODER fügt direkt ein
  - ESC: Schließt das Fenster ohne Aktion
  - Vorschau des Inhalts (erste paar Zeilen)
  - Zeitstempel wann kopiert wurde
  
- [ ] **Clipboard Backend wählen**
  - Optionen: wl-clipboard, clipman, cliphist
  - Integration mit Wayland clipboard
  - Persistent über Neustarts (optional)

---

## Übersicht
Dieses Dokument beschreibt alle Änderungen und Verbesserungen die am 23. Januar 2026 an Apollo OS vorgenommen wurden, sowohl am lokalen Rechner (aiqhpex13) als auch am Remote-Rechner (aiqhpex12 - 192.168.0.45).

---

## 1. SDDM Display Manager Setup (Remote)

### Hintergrund
Der Remote-Rechner (aiqhpex12) nutzte bisher GDM (GNOME Display Manager). Für ein konsistentes Apollo OS Erlebnis wurde auf SDDM mit Wayland umgestellt.

### Installation und Konfiguration

#### Paket-Installation
```bash
sudo dnf install -y sddm sddm-wayland-sway
```

**Wichtig:** Das Paket `sddm-wayland-plasma` verursacht Crashes (exit code 11)! Stattdessen muss `sddm-wayland-sway` verwendet werden.

#### SDDM Konfiguration
Datei: `/etc/sddm.conf.d/apollo-os.conf`

```ini
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Wayland]
CompositorCommand=/usr/libexec/sddm-compositor-sway
SessionCommand=/usr/bin/sddm-greeter-qt6 --socket /tmp/sddm-%1

[Theme]
Current=apollo-os
ThemeDir=/usr/share/sddm/themes

[Session]
DefaultSession=apollo-os-orbit.desktop
RememberLastSession=false
```

**Wichtig:** Der Compositor-Pfad ist `/usr/libexec/sddm-compositor-sway` (nicht `/usr/bin/sddm-wayland-sway`).

#### SDDM aktivieren
```bash
sudo systemctl disable gdm
sudo systemctl enable sddm
sudo systemctl start sddm
```

### Custom Apollo OS SDDM Theme

#### Theme-Struktur
```
/usr/share/sddm/themes/apollo-os/
├── Main.qml           # Hauptdatei mit UI-Logik
├── theme.conf         # Theme-Konfiguration
└── background.jpg     # Hintergrundbild (optional)
```

#### Wallpaper-Lösung
Problem: SDDM hat keinen Zugriff auf `~/System/Wallpaper/current.jpg` (User-Verzeichnis)

Lösung: Wallpaper nach `/usr/share/backgrounds/apollo-os/login.jpg` kopieren

```bash
sudo mkdir -p /usr/share/backgrounds/apollo-os
sudo cp ~/System/Wallpaper/current.jpg /usr/share/backgrounds/apollo-os/login.jpg
```

#### Theme-Anpassungen
- **Willkommenstext:** "APOLLO OS" (statt "Willkommen auf hostname")
- **Prompt entfernt:** Kein "Bitte Benutzernamen und Passwort eingeben"
- **Session-Label:** "Interface" (statt "Sitzung")
- **Layout-Dropdown:** Entfernt
- **Uhr:** Entfernt
- **Schriftart:** JetBrains Mono (wie in Niri/Waybar)
- **Hintergrund:** Dunkles Grau (#1a1a1a) mit 33% Transparenz (opacity 0.67)
- **Rahmen:** 8px border-radius
- **Textfarbe:** Weiß für besseren Kontrast
- **Button-Abstand:** 40px Spacer zwischen Interface-Dropdown und Buttons
- **Default Interface:** Orbit

#### Desktop Entry
Datei: `/usr/share/wayland-sessions/apollo-os-orbit.desktop`

```ini
[Desktop Entry]
Name=Apollo OS (Orbit)
Comment=Apollo OS with Orbit visual interface
Exec=/usr/bin/niri-session
Type=Application
DesktopNames=niri
```

### Status
✅ SDDM läuft stabil mit Wayland + Sway Compositor  
✅ Custom Apollo OS Theme installiert und konfiguriert  
✅ Orbit als Default-Interface eingestellt  
❌ Niri-Session startet nach Login nicht (schwarzer Bildschirm) - noch nicht gelöst

---

## 2. Rechte Strg-Taste für Voice Input (Lokal + Remote)

### Hintergrund
Voice Input war bisher nur über Super+V verfügbar. Der User wünschte zusätzlich die rechte Strg-Taste als Toggle (Start/Stop) für Voice Input.

### Lösung

#### Python evdev Library installieren
```bash
sudo dnf install -y python3-evdev
```

#### Python-Script für Tastenerkennung
Datei: `~/.local/bin/apollo-os-rightctrl-voice.py`

```python
#!/usr/bin/env python3
"""
Apollo OS - Right Control Key Voice Input Trigger
Maps Right Ctrl key to toggle voice input
"""

import evdev
import subprocess
import sys
import os
import time

VOICE_SCRIPT = os.path.expanduser("~/.local/bin/voice-input")

def find_keyboards():
    """Find all keyboard devices with Right Ctrl key"""
    devices = []
    for path in evdev.list_devices():
        device = evdev.InputDevice(path)
        caps = device.capabilities()
        if evdev.ecodes.EV_KEY in caps and evdev.ecodes.KEY_RIGHTCTRL in caps[evdev.ecodes.EV_KEY]:
            devices.append(device)
    return devices

def main():
    devices = find_keyboards()
    if not devices:
        print("No keyboard with Right Ctrl found", file=sys.stderr)
        return 1
    
    print(f"Listening on {len(devices)} keyboard(s)")
    for dev in devices:
        print(f"  - {dev.name}")
    
    try:
        while True:
            for device in devices:
                try:
                    for event in device.read():
                        if event.type == evdev.ecodes.EV_KEY and event.code == evdev.ecodes.KEY_RIGHTCTRL:
                            if event.value == 1:  # Key press (not release)
                                print("Right Ctrl pressed - toggling voice input", flush=True)
                                subprocess.Popen([VOICE_SCRIPT])
                except BlockingIOError:
                    pass
            time.sleep(0.01)
    except KeyboardInterrupt:
        pass
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
```

**Wichtig:** Das Script heißt `voice-input`, nicht `apollo-os-voice-input.sh`!

#### Systemd User Service
Datei: `~/.config/systemd/user/apollo-rightctrl-voice.service`

```ini
[Unit]
Description=Apollo OS Right Ctrl Voice Input Trigger
After=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 %h/.local/bin/apollo-os-rightctrl-voice.py
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
```

#### Service aktivieren
```bash
chmod +x ~/.local/bin/apollo-os-rightctrl-voice.py
systemctl --user daemon-reload
systemctl --user enable apollo-rightctrl-voice.service
systemctl --user start apollo-rightctrl-voice.service
```

### Status
✅ Python-Script erstellt und funktionsfähig  
✅ Systemd Service läuft stabil  
✅ Rechte Strg-Taste wird erkannt und löst Voice Input aus  
✅ Funktioniert wie Super+V: 1x drücken = Start, 2x drücken = Stop + Transkription

### Verwendung
1. **Rechte Strg-Taste** drücken → Aufnahme startet (animierte Benachrichtigung)
2. Auf Deutsch sprechen
3. **Rechte Strg-Taste** erneut drücken → Aufnahme stoppt, Text wird transkribiert und eingefügt

---

## 3. Benachrichtigungen vereinfachen (Lokal + Remote)

### Hintergrund
Die Visual Mode Benachrichtigungen zeigten bisher lange Texte wie:
- "Apollo OS - Visual Mode: I3 Contrast"
- "Apollo OS - Orbit Mode engaged. Welcome to the cosmos."
- etc.

Gewünscht war eine einheitliche, kurze Benachrichtigung: **"Interface geladen"**

### Änderungen

#### Visual Mode Switcher Script
Datei: `~/.local/bin/apollo-os-visual-mode.sh`

**Vorher:**
```bash
notify-send "Apollo OS" "Visual Mode: ${new_mode^}"
```

**Nachher:**
```bash
notify-send "Interface geladen"
```

#### Niri Config Files - Startup Notifications
Alle Niri Config-Dateien (`~/.config/niri/config-*.kdl`) wurden angepasst:

**Vorher (Beispiele):**
```kdl
spawn-at-startup "sh" "-c" "sleep 4 && notify-send 'APOLLO OS' 'i3 Contrast Mode activated. High visibility enabled.'"
spawn-at-startup "sh" "-c" "sleep 4 && notify-send 'APOLLO OS' 'Orbit Mode engaged. Welcome to the cosmos.'"
spawn-at-startup "sh" "-c" "sleep 4 && notify-send 'APOLLO OS' 'Developer Mode activated. Happy coding!'"
```

**Nachher (alle):**
```kdl
spawn-at-startup "sh" "-c" "sleep 4 && notify-send 'Interface geladen'"
```

#### Betroffene Dateien
- `~/.config/niri/config.kdl` (aktive Config)
- `~/.config/niri/config-classic.kdl`
- `~/.config/niri/config-developer.kdl`
- `~/.config/niri/config-enterprise.kdl`
- `~/.config/niri/config-i3.kdl`
- `~/.config/niri/config-i3-retro.kdl`
- `~/.config/niri/config-i3-contrast.kdl`
- `~/.config/niri/config-minimal.kdl`
- `~/.config/niri/config-modern.kdl`
- `~/.config/niri/config-nova.kdl`
- `~/.config/niri/config-orbit.kdl`
- `~/.config/niri/config-professional.kdl`
- `~/.config/niri/config-sgi.kdl`
- `~/.config/niri/config-tech-blue.kdl`

### Status
✅ Alle Visual Mode Configs zeigen jetzt "Interface geladen" beim Start  
✅ Visual Mode Switcher (Super+M) zeigt "Interface geladen" beim Wechsel  
✅ Einheitliche, kurze Benachrichtigung in allen Modi

---

## 4. TTS Welcome Script - Weißes Fenster beheben (Lokal + Remote)

### Problem
Das Welcome TTS Script (`~/.local/bin/apollo-os-welcome-tts.sh`) öffnete beim Start ein weißes Fenster für ca. 5 Sekunden, während edge-tts lief.

### Lösung
Das gesamte TTS-Processing wurde in einen Background-Subshell verschoben, und das Hauptscript beendet sich sofort.

#### Script-Änderungen
Datei: `~/.local/bin/apollo-os-welcome-tts.sh`

**Vorher:**
```bash
sleep 5
# TTS Code hier...
pw-play "$TMPFILE" 2>/dev/null
```

**Nachher:**
```bash
# Run in background immediately
{
    sleep 5
    # ... TTS Code ...
    pw-play "$TMPFILE" >/dev/null 2>&1
    rm -f "$TMPFILE"
} &

# Exit immediately, don't wait for TTS
exit 0
```

**Wichtig:** Alle Outputs werden nach `/dev/null` umgeleitet (`>/dev/null 2>&1`)

### Status
✅ Kein weißes Fenster mehr beim Login  
✅ TTS läuft komplett im Hintergrund  
✅ Script beendet sich sofort, Audio wird trotzdem abgespielt

---

## 5. Waybar Notification Area Styling (Remote)

### Änderung
Die Notification Area in der i3-contrast Waybar zeigt jetzt eine größere rote Fläche wenn eine App Aufmerksamkeit fordert.

#### CSS-Änderungen
Datei: `~/.config/waybar/style-i3-contrast.css`

```css
/* Notification area */
#tray {
    background-color: #1c1c1c;
    padding: 4px 8px;
    margin: 4px 0;
    border-radius: 3px;
}

#tray > .needs-attention {
    background-color: #cc241d;
    padding: 6px 12px;
    margin: 2px;
    border-radius: 3px;
}
```

**Hinweis:** Der `:has()` CSS-Pseudo-Selector wird in GTK CSS nicht unterstützt. Stattdessen wird direkt das `.needs-attention` Element mit größerem Padding/Margin gestylt.

### Status
✅ Größere rote Fläche bei Benachrichtigungen  
✅ Bessere Sichtbarkeit im i3-contrast Mode

---

## Installation / Integration

### Remote-Rechner (aiqhpex12 - 192.168.0.45)
Alle Änderungen wurden direkt auf dem System durchgeführt:
- ✅ SDDM installiert und konfiguriert
- ✅ Custom Apollo OS Theme installiert
- ✅ Right Ctrl Voice Input aktiviert
- ✅ Benachrichtigungen vereinfacht
- ✅ TTS optimiert
- ✅ Waybar Styling angepasst

### Lokaler Rechner (aiqhpex13)
Folgende Features wurden installiert:
- ✅ Right Ctrl Voice Input aktiviert
- ✅ Benachrichtigungen vereinfacht
- ✅ TTS optimiert
- ⏳ SDDM noch nicht installiert (noch auf GDM)

---

## Offene Punkte

### Remote-Rechner
1. **Niri Session startet nicht über SDDM**
   - Nach Login über SDDM erscheint nur schwarzer Bildschirm mit Maus
   - Session 68 startet und beendet sich sofort wieder
   - Alte GDM Session auf tty2 funktioniert weiterhin
   - Mögliche Ursachen:
     - Fehlende Environment-Variablen (XDG_SESSION_TYPE, WAYLAND_DISPLAY)
     - niri-session Script benötigt spezielle Initialisierung
     - PAM Session wird sofort wieder geschlossen
   
   **Debugging-Schritte:**
   - `journalctl -b | grep -E "session|niri|tty3"` für Session-Logs
   - Environment von funktionierender vs. nicht-funktionierender Session vergleichen
   - `/usr/bin/niri-session` Script auf Abhängigkeiten prüfen

2. **Wallpaper Persistenz**
   - Aktuell muss Wallpaper manuell nach `/usr/share/backgrounds/apollo-os/` kopiert werden
   - Automatische Synchronisation wäre wünschenswert

### Lokaler Rechner
1. **SDDM Installation**
   - Noch nicht durchgeführt, da Remote-Rechner erst getestet werden soll
   - Nach erfolgreicher Lösung des Session-Problems kann lokal umgestellt werden

---

## Testing

### Right Ctrl Voice Input
**Test-Schritte:**
1. Rechte Strg-Taste drücken → Benachrichtigung erscheint (Mikrofon-Icon animiert)
2. Sprechen (z.B. "Hallo dies ist ein Test")
3. Rechte Strg-Taste erneut drücken → Transkription läuft
4. Text wird am Cursor eingefügt

**Service-Status prüfen:**
```bash
systemctl --user status apollo-rightctrl-voice.service
journalctl --user -u apollo-rightctrl-voice.service -f
```

### Visual Mode Benachrichtigungen
**Test-Schritte:**
1. Login → "Interface geladen" erscheint (nach 4 Sekunden)
2. Super+M drücken (Mode wechseln) → "Interface geladen" erscheint
3. Verschiedene Modes testen (Classic, Developer, i3, Orbit, etc.)

### TTS Welcome
**Test-Schritte:**
1. Ausloggen und neu einloggen
2. Kein weißes Fenster sollte erscheinen
3. Nach ~5 Sekunden sollte TTS-Ansage hörbar sein
4. System sollte sofort verwendbar sein (kein Warten)

---

## Technische Details

### Verwendete Pakete
- `sddm` - Display Manager
- `sddm-wayland-sway` - Wayland Support für SDDM
- `python3-evdev` - Python Library für Input Device Events
- `qt6-qtdeclarative` - QML Runtime (bereits installiert)

### Script-Pfade
- `~/.local/bin/voice-input` - Voice Input Haupt-Script
- `~/.local/bin/voice-input-notification` - Animations-Script
- `~/.local/bin/apollo-os-rightctrl-voice.py` - Right Ctrl Listener
- `~/.local/bin/apollo-os-visual-mode.sh` - Visual Mode Switcher
- `~/.local/bin/apollo-os-welcome-tts.sh` - TTS Welcome Script

### Config-Pfade
- `/etc/sddm.conf.d/apollo-os.conf` - SDDM Konfiguration
- `/usr/share/sddm/themes/apollo-os/` - Custom Theme
- `~/.config/systemd/user/apollo-rightctrl-voice.service` - Service für Right Ctrl
- `~/.config/niri/config*.kdl` - Niri Window Manager Configs
- `~/.config/waybar/` - Waybar Configs und Styles

### Log-Dateien
```bash
# SDDM Logs
journalctl -u sddm
journalctl -b | grep sddm

# User Session Logs
journalctl --user -b

# Right Ctrl Service
journalctl --user -u apollo-rightctrl-voice.service

# Login Sessions
loginctl list-sessions
loginctl show-session <ID>
```

---

## Version
- **Datum:** 2026-01-23
- **Apollo OS Version:** v3.1.0
- **System:** Fedora 43
- **Kernel:** Linux 6.x
- **Desktop:** Niri (Wayland Compositor)

---

## Kontakt
Bei Fragen oder Problemen: Manuel Kraibacher

---

*Dokumentation erstellt am 2026-01-23*


---

## 6. Mako Benachrichtigungs-Design an Rofi angepasst (Lokal)

### Hintergrund
Die Mako-Benachrichtigungen nutzten ein altes Design mit runden Ecken, weißem Border und zentrierter Position. Für ein konsistentes Erscheinungsbild sollte das Design an das Rofi-Menü angepasst werden.

### Rofi Design-Eigenschaften
- **Farbschema:** Dark Grayscale (#1a1a1a Hintergrund, #d0d0d0 Text)
- **Stil:** Minimalistisch, eckig, keine Rundungen
- **Border:** 3px in hellem Grau (#4a4a4a)
- **Schriftart:** JetBrainsMono Nerd Font 11

### Neue Mako-Konfiguration
Datei: `~/.config/mako/config`

```ini
# Mako Configuration - Apollo OS Style (matched to Rofi)
# Dark Grayscale Theme - Minimalist monochrome aesthetic

# Schriftart
font=JetBrainsMono Nerd Font 11

# Farben (wie Rofi)
background-color=#1a1a1a
text-color=#d0d0d0
border-color=#4a4a4a

# Dimensionen
width=400
height=120
margin=10
padding=14,16
border-size=3
border-radius=0

# Position: Rechts oben
anchor=top-right
layer=overlay

# Timeouts
default-timeout=5000
ignore-timeout=0

# Icons
icons=1
max-icon-size=48
icon-location=left

# Maximal 5 Benachrichtigungen gleichzeitig
max-visible=5
group-by=none

# Format
format=<b>%s</b>\n%b

# Urgency Levels
[urgency=low]
background-color=#242424
border-color=#3a3a3a
text-color=#808080

[urgency=normal]
background-color=#1a1a1a
border-color=#4a4a4a
text-color=#d0d0d0

[urgency=high]
background-color=#2a1a1a
border-color=#a05050
text-color=#ffffff
border-size=3
default-timeout=0

# Grouped notifications
[grouped]
format=<b>%s</b> (%g)\n%b
```

### Änderungen im Detail

#### Vorher
- Position: `anchor=top-center` (oben mittig)
- Design: Runde Ecken (`border-radius=12`)
- Farben: Schwarz/Weiß (`#000000`, `#ffffff`)
- Schrift: Cantarell 12
- Max. Benachrichtigungen: 1

#### Nachher
- Position: `anchor=top-right` (rechts oben) ✅
- Design: Eckig (`border-radius=0`) - passend zu Rofi ✅
- Farben: Graustufenschema (#1a1a1a, #d0d0d0, #4a4a4a) ✅
- Schrift: JetBrainsMono Nerd Font 11 - passend zu Rofi ✅
- Max. Benachrichtigungen: 5 ✅
- Border: 3px (wie Rofi) ✅

#### Urgency-Farben
- **Low:** Dunkleres Grau (#242424) für weniger wichtige Meldungen
- **Normal:** Standard Grau (#1a1a1a) für normale Benachrichtigungen
- **High:** Rötlicher Hintergrund (#2a1a1a) mit rotem Border (#a05050) für wichtige Meldungen

### Mako neu laden
```bash
makoctl reload
```

Oder bei Problemen Mako komplett neu starten - PID mit pgrep finden und dann beenden.

### Status
✅ Design perfekt an Rofi angepasst  
✅ Position rechts oben  
✅ Eckige Form ohne Rundungen  
✅ Graustufenschema konsistent  
✅ JetBrainsMono Schriftart  
✅ Maximal 5 Benachrichtigungen gleichzeitig  
✅ Urgency-Levels mit unterschiedlichen Farben

### Visuelle Konsistenz
- Rofi-Menü und Mako-Benachrichtigungen nutzen jetzt identisches Farbschema
- Beide verwenden JetBrainsMono Nerd Font
- Beide haben eckige, kantige Formen (border-radius: 0)
- Beide nutzen 3px Border
- Einheitliches, minimalistisches Erscheinungsbild


---

## 7. Kitty Terminal Shortcut hinzugefügt (Lokal)

### Änderung
Super+K startet jetzt Kitty Terminal in allen Visual Modes.

### Implementation
Alle Niri Config-Dateien wurden erweitert:

```kdl
Mod+K { spawn "kitty"; }
```

### Betroffene Dateien
- `~/.config/niri/config.kdl` (aktive Config)
- `~/.config/niri/config-classic.kdl`
- `~/.config/niri/config-developer.kdl`
- `~/.config/niri/config-enterprise.kdl`
- `~/.config/niri/config-i3.kdl`
- `~/.config/niri/config-i3-retro.kdl`
- `~/.config/niri/config-i3-contrast.kdl`
- `~/.config/niri/config-minimal.kdl`
- `~/.config/niri/config-modern.kdl`
- `~/.config/niri/config-nova.kdl`
- `~/.config/niri/config-orbit.kdl`
- `~/.config/niri/config-professional.kdl`
- `~/.config/niri/config-sgi.kdl`
- `~/.config/niri/config-tech-blue.kdl`

### Terminal Shortcuts Übersicht
- **Super+Return:** Alacritty (Standard Terminal)
- **Super+T:** Ptyxis (GNOME Terminal)
- **Super+K:** Kitty ✅ NEU

### Config reload
```bash
niri msg action load-config-file
```

### Status
✅ Kitty Shortcut in allen 14 Niri Configs hinzugefügt  
✅ Config neu geladen  
✅ Super+K öffnet Kitty Terminal


---

## 8. Rechte Strg-Taste: Push-to-Talk + Auto-Enter (Lokal)

### Hintergrund
Die rechte Strg-Taste funktionierte bisher als Toggle (1x drücken = Start, 2x drücken = Stop). Für eine intuitivere Bedienung wurde dies auf Push-to-Talk umgestellt.

### Neue Funktionsweise

#### Push-to-Talk Modus
- **Taste gedrückt halten:** Aufnahme läuft
- **Taste loslassen:** Aufnahme stoppt, Transkription beginnt
- **Nach Transkription:** Text wird eingefügt + **Enter automatisch gedrückt** ✅

#### Vorteile
- Intuitivere Bedienung (wie bei Walkie-Talkies)
- Perfekt für schnelle Terminal-Befehle per Sprache
- Auto-Enter ermöglicht sofortige Ausführung
- Keine versehentlich lange laufende Aufnahmen

### Implementation Details

#### Python Script Änderungen
Datei: `~/.local/bin/apollo-os-rightctrl-voice.py`

**Vorher:**
```python
if event.value == 1:  # Key press
    print("Right Ctrl pressed - toggling voice input", flush=True)
    subprocess.Popen([VOICE_SCRIPT])
```

**Nachher:**
```python
if event.value == 1:  # Key press - START recording
    if not is_recording():
        print("Right Ctrl pressed - START recording", flush=True)
        subprocess.Popen([VOICE_SCRIPT])
        recording = True
elif event.value == 0:  # Key release - STOP recording
    if is_recording():
        print("Right Ctrl released - STOP recording", flush=True)
        subprocess.Popen([VOICE_SCRIPT])
        recording = False
```

**Wichtig:** Das Script reagiert jetzt auf `event.value == 0` (Taste losgelassen) zusätzlich zu `event.value == 1` (Taste gedrückt).

#### Voice Input Script Änderungen
Datei: `~/.local/bin/voice-input`

**Vorher:**
```bash
if [ -n "$TEXT" ]; then
    # Füge Text ein
    echo -n "$TEXT" | wtype -
    notify-send "✅ Spracheingabe" "Text eingefügt" -t 1500
fi
```

**Nachher:**
```bash
if [ -n "$TEXT" ]; then
    # Füge Text ein + Enter drücken
    printf "%s" "$TEXT" | wtype -
    sleep 0.1
    wtype -k Return
    notify-send "✅ Spracheingabe" "Text eingefügt" -t 1500
fi
```

**Wichtig:** 
- `printf "%s"` statt `echo -n` - Sicherer, keine ungewollten Zeichen
- `sleep 0.1` - Kleine Pause zwischen Text und Enter für sichere Verarbeitung
- `wtype -k Return` - Simuliert Enter-Taste

#### Bugfix: Leerzeile vor Text entfernt
**Problem:** Nach Push-to-Talk wurde eine Leerzeile vor dem transkribierten Text eingefügt.

**Lösung in Zeile 36:**
```bash
# Alt:
TEXT=$("$WHISPER_BIN" -m "$WHISPER_MODEL" -l "$LANGUAGE" -nt -f "$AUDIO_FILE" 2>/dev/null | grep -v "^whisper_" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

# Neu:
TEXT=$("$WHISPER_BIN" -m "$WHISPER_MODEL" -l "$LANGUAGE" -nt -f "$AUDIO_FILE" 2>/dev/null | grep -v "^whisper_" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -d '\n')
```

**Wichtig:** `| tr -d '\n'` entfernt alle Newline-Zeichen aus dem transkribierten Text.
    notify-send "✅ Spracheingabe" "Text eingefügt" -t 1500
fi
```

**Wichtig:** `wtype -k Return` simuliert das Drücken der Enter-Taste nach dem Text.

### Service Neustart
```bash
systemctl --user restart apollo-rightctrl-voice.service
```

### Verwendung

#### Beispiel: Terminal-Befehl per Sprache
1. Terminal öffnen (Super+Return)
2. **Rechte Strg-Taste gedrückt halten**
3. Sprechen: "ls minus la"
4. **Rechte Strg-Taste loslassen**
5. → Text wird eingefügt: `ls -la`
6. → Enter wird automatisch gedrückt
7. → Befehl wird sofort ausgeführt ✅

#### Beispiel: Schnelle Befehle
- "cd Downloads" → Wechselt ins Downloads-Verzeichnis
- "git status" → Zeigt Git-Status
- "npm install" → Installiert npm-Pakete

### Status
✅ Push-to-Talk Modus implementiert  
✅ Auto-Enter nach Transkription  
✅ Service läuft stabil  
✅ Perfekt für Vibe Coding und schnelle Terminal-Bedienung

### Vergleich: Toggle vs. Push-to-Talk

| Feature | Toggle-Modus (Alt) | Push-to-Talk (Neu) |
|---------|-------------------|-------------------|
| **Start** | 1x drücken | Taste halten |
| **Stop** | Nochmal drücken | Taste loslassen |
| **Auto-Enter** | Nein | ✅ Ja |
| **Intuitivität** | Mittel | Hoch |
| **Versehentliche Aufnahmen** | Möglich | Unwahrscheinlich |
| **Terminal-Befehle** | Manuell Enter | Automatisch |


---

## 📁 Changelog Files Ordner

Alle in diesem Changelog erwähnten Scripts und Konfigurationsdateien befinden sich im Ordner:

**`changelog-files/`**

### Inhalt:
- `apollo-os-rightctrl-voice.py` - Push-to-Talk Python Script
- `voice-input` - Spracheingabe Haupt-Script (mit Auto-Enter)
- `apollo-rightctrl-voice.service` - systemd User Service
- `apollo-os-visual-mode.sh` - Visual Mode Switcher
- `apollo-os-welcome-tts.sh` - TTS Welcome Script
- `mako-config` - Mako Benachrichtigungs-Konfiguration
- `README.md` - Detaillierte Dokumentation aller Files

### Verwendung:
```bash
cd changelog-files/
cat README.md  # Ausführliche Dokumentation lesen
```

Die README.md im Ordner enthält:
- ✅ Zweck jedes einzelnen Files
- ✅ Installationsanweisungen
- ✅ Abhängigkeiten
- ✅ Verwendungsbeispiele
- ✅ Code-Änderungen im Detail
- ✅ Komplette Installation aller Files in einem Durchgang

**Tipp:** Nutze die Files als Referenz für zukünftige Installationen oder Updates!


---

## 9. Rofi Quick Menu: Höhe halbiert (Lokal)

### Änderung
Das Rofi Quick Menu wurde von 12 auf 6 sichtbare Zeilen reduziert - die Hälfte der ursprünglichen Höhe.

### Grund
- Kompakteres Interface
- Weniger Bildschirmfläche blockiert
- Schnellere Übersicht über Optionen
- Scrollbar funktioniert weiterhin für mehr Einträge

### Implementation
Datei: `~/.config/rofi/config.rasi`

**Vorher:**
```css
listview {
    enabled:          true;
    columns:          1;
    lines:            12;
    cycle:            true;
    /* ... */
}
```

**Nachher:**
```css
listview {
    enabled:          true;
    columns:          1;
    lines:            6;
    cycle:            true;
    /* ... */
}
```

### Eigenschaften
- **Sichtbare Zeilen:** 6 (statt 12)
- **Scrollbar:** Aktiv bei mehr als 6 Einträgen
- **Breite:** Unverändert (700px)
- **Design:** Unverändert (Dark Grayscale)

### Vorteile
- ✅ Kompakteres Menu
- ✅ Weniger ablenkend
- ✅ Schnellerer Überblick
- ✅ Scrollbar bei Bedarf vorhanden

### Status
✅ Höhe auf 50% reduziert (12 → 6 Zeilen)  
✅ Config aktualisiert  
✅ In changelog-files/rofi-config.rasi gesichert


### Quick Menu Höhe angepasst

Zusätzlich zur normalen Rofi-Config wurde auch das Quick Menu Script angepasst:

**Datei:** `~/.local/bin/apollo-os-quickmenu.sh`  
**Zeile 45:**

**Vorher:**
```bash
selected=$(printf '%s\n' "${actions[@]}" | rofi -dmenu -p "> Quick Menu" -i \
    -theme-str 'window {width: 750px;} listview {lines: 18; scrollbar: true;} element {padding: 8px 12px;}')
```

**Nachher:**
```bash
selected=$(printf '%s\n' "${actions[@]}" | rofi -dmenu -p "> Quick Menu" -i \
    -theme-str 'window {width: 750px;} listview {lines: 6; scrollbar: true;} element {padding: 8px 12px;}')
```

**Änderung:** 18 → 6 Zeilen (gleiche Höhe wie normales Rofi Menu)

**Shortcut:** Super+Shift+Space


### Nerd Font Icons statt Emojis

Alle Emojis im Quick Menu wurden durch Nerd Font Icons ersetzt und führende Leerzeichen entfernt.

**Icon-Mapping:**
- `` - Next Wallpaper (Bildrahmen)
- `` - Visual Mode (Pinsel/Palette)
- `` - Display Scaling (Suche/Zoom)
- `` - External Monitor Scaling (Monitor)
- `` - Power Profiles (Blitz)
- `` - TTS Voice (Mikrofon)
- `` - Edit Configs (Zahnrad)
- `` - Keyboard Shortcuts (Tastatur)
- `` - Update (Sync/Reload)
- `` - Winboat (Windows Logo)
- `` - Reload Infobar (Chart)
- `` - Reload Notifications (Glocke)
- `` - Reload Orbit (Kreis/Orbit)
- `` - Lock Screen (Schloss)
- `` - Logout (Pfeil raus)
- `` - Reboot (Reload)
- `` - Shutdown (Power)

**Vorteile:**
- ✅ Konsistente Darstellung in allen Schriftarten
- ✅ Keine Emoji-Rendering-Probleme
- ✅ Saubere Ausrichtung (keine extra Leerzeichen)
- ✅ Professioneller Look


---

## 9. HeartMuLa AI Music Generation (EXPERIMENTELL) ✅

**Datum:** 2026-01-24  
**Status:** Installiert und getestet (CPU-only)

### Was ist HeartMuLa?

HeartMuLa ist eine Familie von Open-Source Music Foundation Models von HeartMuLa Team:
- **HeartMuLa-oss-3B**: Music Language Model (3 Milliarden Parameter)
- **HeartCodec-oss**: 12.5 Hz Music Codec mit hoher Rekonstruktionsgenauigkeit
- Unterstützt mehrsprachige Lyrics (EN, CN, JP, KR, ES)
- Generiert Musik basierend auf Lyrics + Tags

**GitHub:** https://github.com/HeartMuLa/heartlib  
**Paper:** https://arxiv.org/abs/2601.10547

### Installation

```bash
# 1. Python 3.10 installiert (HeartMuLa benötigt 3.9-3.10)
sudo dnf install -y python3.10 python3.10-devel

# 2. Virtual Environment erstellen
mkdir -p ~/HeartMuLa
cd ~/HeartMuLa
python3.10 -m venv venv
source venv/bin/activate

# 3. PyTorch (CPU-only) installieren
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# 4. HeartMuLa Repository klonen und installieren
git clone https://github.com/HeartMuLa/heartlib.git
cd heartlib
pip install -e .

# 5. Modelle herunterladen (ca. 15 GB!)
mkdir -p ckpt
huggingface-cli download HeartMuLa/HeartMuLa-RL-oss-3B-20260123 --local-dir ./ckpt/HeartMuLa-oss-3B
huggingface-cli download HeartMuLa/HeartCodec-oss-20260123 --local-dir ./ckpt/HeartCodec-oss
huggingface-cli download HeartMuLa/HeartMuLaGen tokenizer.json gen_config.json --local-dir ./ckpt
```

### Performance auf Intel i5-1135G7 (CPU-only)

- **CPU:** Intel Core i5-1135G7 (11th Gen, 4C/8T, 2.40 GHz)
- **RAM:** 64 GB
- **GPU:** Keine NVIDIA GPU (nur Intel Iris Xe - kein CUDA)

**Test-Ergebnis:**
- Song-Länge: 10 Sekunden
- Generierungszeit: ~397 Sekunden (6,5 Minuten)
- **RTF (Real-Time Factor): 40x** (40 Sekunden Rechenzeit pro 1 Sekunde Audio)
- Model-Ladezeit: 0.2 Sekunden (mit `lazy_load=True`)

**Interpretation:**
- Für einen 3-Minuten-Song: ~2 Stunden Generierungszeit
- CPU-Inferenz ist sehr langsam (für Produktion nicht praktikabel)
- Mit NVIDIA GPU wäre RTF ~1-2x (nahezu Echtzeit)

### Beispiel: Apollo AI Song

Lyrics erstellt:
```
[Verse]
Apollo AI, digital mind so bright
Coding through the day and night
Helping users find their way
Making tech dreams come alive today

[Outro]
```

Tags: `pop,upbeat,electronic,energetic`

**Output:** `apollo_song.mp3` (168 KB, 48 kHz, 128 kbps, Stereo)

Kopiert nach: `~/Schreibtisch/apollo_song.mp3`

### Python Script für Song-Generierung

```python
#!/usr/bin/env python3
from heartlib import HeartMuLaGenPipeline
import torch

pipe = HeartMuLaGenPipeline.from_pretrained(
    "./ckpt",
    device={
        "mula": torch.device("cpu"),
        "codec": torch.device("cpu"),
    },
    dtype={
        "mula": torch.float32,
        "codec": torch.float32,
    },
    version="3B",
    lazy_load=True,  # Wichtig für CPU!
)

with torch.no_grad():
    pipe(
        {
            "lyrics": "./assets/apollo_lyrics.txt",
            "tags": "./assets/apollo_tags.txt",
        },
        max_audio_length_ms=10_000,  # 10 Sekunden
        save_path="./apollo_song.mp3",
        topk=50,
        temperature=1.0,
        cfg_scale=1.5,
    )
```

### Empfehlungen

**Für Apollo OS:**
- ❌ **Nicht für Produktiv-Nutzung empfohlen** (zu langsam auf CPU)
- ✅ **Experimentell interessant** für AI/ML-Enthusiasten
- 💡 **Alternative:** Cloud-basierte Inferenz (Hugging Face Spaces, Replicate)
- 🎯 **Mit NVIDIA GPU:** Deutlich schneller (RTF 1-2x statt 40x)

**Use Cases:**
- Experimentieren mit AI Music Generation
- Erstellen von Demo-Songs für Projekte
- Lernen über Music Foundation Models
- Nicht für Live-Performance oder schnelle Iteration

### Dateien

Installationsort: `~/HeartMuLa/heartlib/`
- Modelle: `~/HeartMuLa/heartlib/ckpt/` (~15 GB)
- Scripts: `~/HeartMuLa/heartlib/quick_apollo_song.py`
- Test-Log: `~/HeartMuLa/heartlib/cpu_test.log`
- Output: `~/Schreibtisch/apollo_song.mp3`


---

## 10. Hyprlock Integration und Mauszeiger-Konsistenz

**Anforderung:** Hyprlock (Hyprland's Lockscreen) soll auch unter Niri mit Shortcut Ctrl+Super+L verfügbar sein. Zusätzlich soll der Mauszeiger von Hyprland (Bibata-Modern-Classic) auch in Niri verwendet werden für ein konsistentes Look & Feel.

### 1. Hyprlock-Shortcut für Niri

#### Neues Script erstellt
Datei: `~/.local/bin/apollo-os-lock-hypr.sh`

```bash
#!/bin/bash
#####################################################################
# Apollo OS - Lock Screen with TTS (Hyprlock Version)
# Copyright © 2025 by Manuel Kraibacher
#####################################################################

TTS_SCRIPT="$HOME/.local/bin/apollo-os-tts-notify.sh"

# Play lock sound (synchronous to ensure it completes before screen locks)
[ -x "$TTS_SCRIPT" ] && "$TTS_SCRIPT" lock

# Lock screen with hyprlock
hyprlock

# After unlock, play unlock sound
[ -x "$TTS_SCRIPT" ] && "$TTS_SCRIPT" unlock
```

**Eigenschaften:**
- Basiert auf bestehendem `apollo-os-lock.sh`
- Verwendet hyprlock statt swaylock
- TTS-Ansagen vor Lock und nach Unlock
- Ausführbar gemacht mit `chmod +x`

#### Shortcut hinzugefügt
In allen 14 Niri Config-Dateien wurde der neue Shortcut eingefügt:

```kdl
Mod+L { spawn "sh" "-c" "$HOME/.local/bin/apollo-os-lock.sh"; }
Ctrl+Mod+L { spawn "sh" "-c" "$HOME/.local/bin/apollo-os-lock-hypr.sh"; }
```

**Shortcuts:**
- **Super+L** → swaylock (klassisch, wie bisher)
- **Ctrl+Super+L** → hyprlock (neu, modern)

### 2. Hyprlock-Config angepasst

Die hyprlock-Konfiguration wurde optimiert für bessere Konsistenz mit Niri:

#### Wallpaper-Integration
Datei: `~/.config/hypr/hyprlock.conf`

**Vorher:**
```kdl
background {
    color = rgba(181818FF)
}
```

**Nachher:**
```kdl
background {
    monitor =
    path = ~/System/Wallpaper/current.jpg
    blur_passes = 3
    blur_size = 7
    contrast = 0.9
    brightness = 0.8
    vibrancy = 0.2
}
```

**Vorteil:** Hyprlock verwendet automatisch das gleiche Wallpaper wie Niri (`~/System/Wallpaper/current.jpg`)

#### Farb- und Schrift-Anpassung
Datei: `~/.config/hypr/hyprlock/colors.conf`

**Vorher:**
```conf
$text_color = rgba(5e5e5eFF)
$entry_color = rgba(5e5e5eFF)
$font_family = Google Sans Flex Medium
$font_family_clock = Google Sans Flex Medium
```

**Nachher:**
```conf
$text_color = rgba(ffffffff)
$entry_color = rgba(ffffffff)
$font_family = JetBrains Mono
$font_family_clock = JetBrains Mono
```

**Änderungen:**
- ✅ Weiße Schrift (statt grau) für besseren Kontrast
- ✅ JetBrains Mono (wie in Waybar/Niri) statt Google Sans Flex Medium
- ✅ Konsistente Typografie im gesamten System

### 3. Mauszeiger-Konsistenz

Der Mauszeiger wurde von Hyprland zu Niri übertragen:

#### Hyprland Mauszeiger identifiziert
```bash
gsettings get org.gnome.desktop.interface cursor-theme
# Ergebnis: 'Bibata-Modern-Classic'
```

#### Niri Configs aktualisiert
Alle 14 Niri Config-Dateien wurden angepasst:

**Vorher:**
```kdl
cursor {
    xcursor-theme "breeze_cursors"
}
```

**Nachher:**
```kdl
cursor {
    xcursor-theme "Bibata-Modern-Classic"
}
```

**Implementierung:**
```bash
for file in /home/apollo/.config/niri/config*.kdl; do
  sed -i 's/xcursor-theme "breeze_cursors"/xcursor-theme "Bibata-Modern-Classic"/' "$file"
done
```

### 4. Betroffene Dateien

**Niri Configs (alle aktualisiert):**
- `~/.config/niri/config.kdl` (Haupt-Config)
- `~/.config/niri/config-classic.kdl`
- `~/.config/niri/config-developer.kdl`
- `~/.config/niri/config-enterprise.kdl`
- `~/.config/niri/config-i3.kdl`
- `~/.config/niri/config-i3-retro.kdl`
- `~/.config/niri/config-i3-contrast.kdl`
- `~/.config/niri/config-minimal.kdl`
- `~/.config/niri/config-modern.kdl`
- `~/.config/niri/config-nova.kdl`
- `~/.config/niri/config-orbit.kdl`
- `~/.config/niri/config-professional.kdl`
- `~/.config/niri/config-sgi.kdl`
- `~/.config/niri/config-tech-blue.kdl`

**Scripts:**
- `~/.local/bin/apollo-os-lock-hypr.sh` (neu erstellt)

**Hyprlock Configs:**
- `~/.config/hypr/hyprlock.conf` (Wallpaper, Blur)
- `~/.config/hypr/hyprlock/colors.conf` (Farben, Schriftart)

### Erwartetes Ergebnis nach Implementierung

#### Lockscreen Shortcuts
- **Super+L** → Swaylock (Standard, mit apollo-login.jpg)
- **Ctrl+Super+L** → Hyprlock (Modern, mit aktuellem Wallpaper)

#### Vorteile der Dual-Lockscreen-Lösung
- Swaylock: Schnell, leichtgewichtig, immer gleicher Hintergrund
- Hyprlock: Modern, aktuelles Wallpaper, Blur-Effekte
- Beide mit TTS-Ansagen (Lock/Unlock) über apollo-os-tts-notify.sh
- Flexibilität je nach Situation

### Visuelle Konsistenz nach Umsetzung

**Systemweit einheitlich:**
- Mauszeiger: Bibata-Modern-Classic (Hyprland ↔ Niri)
- Schriftart: JetBrains Mono (Waybar, Hyprlock, Mako, Rofi)
- Farbschema: Dark Grayscale (#1a1a1a Basis)
- Wallpaper: Automatische Synchronisation zwischen Niri und Hyprlock via `~/System/Wallpaper/current.jpg`


---

## 🔴 WICHTIG: Umstrukturierung erforderlich

### Namensgebung und Struktur

**Problem:** Die aktuelle Namensgebung und Strukturierung von Scripts und Visual Modes ist inkonsistent und nicht intuitiv.

**Erforderliche Maßnahmen:**

#### 1. Visual Mode Namen überarbeiten
**Aktuell:**
- classic, developer, enterprise, i3, i3-retro, i3-contrast, minimal, modern, nova, orbit, professional, sgi, tech-blue

**Probleme:**
- Namen beschreiben oft nicht die Funktion
- "i3" hat keine direkte Bedeutung für neue User
- Keine klare Kategorisierung oder Hierarchie
- Uneinheitliche Benennungskonventionen

**Vorschläge für neue Namen:**
- `i3-contrast` → `high-contrast` oder `accessibility`
- `i3-retro` → `terminal-retro` oder `vintage`
- `sgi` → `corporate-blue` oder `workstation`
- `tech-blue` → `professional-blue` oder `modern-tech`

**Ziel:**
- Intuitive, selbsterklärende Namen
- Konsistente Namenskonvention (z.B. `adjective-noun` Schema)
- Namen sollten Funktion/Zweck/Zielgruppe widerspiegeln

#### 2. Script-Namen strukturieren

**Aktuell:**
- `apollo-os-lock.sh`
- `apollo-os-lock-hypr.sh`
- `apollo-os-visual-mode.sh`
- `apollo-os-quickmenu.sh`
- `apollo-os-rightctrl-voice.py`
- `voice-input` (inkonsistent!)

**Probleme:**
- Mischung aus `apollo-os-*` und anderen Präfixen
- Inkonsistente Verwendung von `.sh` Extension
- Keine klare Kategorisierung (UI, System, Audio, etc.)

**Vorschlag für neue Struktur:**
```
~/.local/bin/apollo/
├── system/
│   ├── lock-swaylock
│   ├── lock-hyprlock
│   ├── visual-mode-switcher
│   └── power-monitor
├── ui/
│   ├── quickmenu
│   ├── launcher-rofi
│   └── wallpaper-cycle
├── audio/
│   ├── voice-input
│   ├── voice-notification
│   └── tts-notify
└── monitors/
    ├── network-monitor
    └── sleep-monitor
```

**Vorteile:**
- Klare Kategorisierung nach Funktion
- Einfacheres Auffinden von Scripts
- Bessere Wartbarkeit
- Konsistente Namensgebung ohne Präfix-Chaos

#### 3. Config-Dateien strukturieren

**Aktuell:**
```
~/.config/niri/
├── config.kdl
├── config-classic.kdl
├── config-developer.kdl
├── config-enterprise.kdl
└── ... (11 weitere)
```

**Vorschlag:**
```
~/.config/apollo-os/
├── niri/
│   ├── modes/
│   │   ├── high-contrast.kdl
│   │   ├── terminal-retro.kdl
│   │   ├── modern-professional.kdl
│   │   └── ...
│   └── current -> modes/high-contrast.kdl (symlink)
├── waybar/
│   ├── themes/
│   │   ├── high-contrast/
│   │   │   ├── config
│   │   │   └── style.css
│   │   └── ...
│   └── current -> themes/high-contrast/ (symlink)
└── scripts/
    └── [siehe Script-Struktur oben]
```

**Vorteile:**
- Alle Apollo OS Configs zentral an einem Ort
- Modes in eigenen Unterordnern
- Symlinks für aktuelle Config (einfacher Modus-Wechsel)
- Zusammengehörige Configs gruppiert

#### 4. Dokumentation erstellen

**Fehlend:**
- README.md für jeden Visual Mode (Beschreibung, Screenshots, Shortcuts)
- SHORTCUTS.md mit allen Tastenkombinationen
- SCRIPTS.md mit Dokumentation aller Scripts
- VISUAL-MODES.md mit Übersicht und Vergleich

**Erforderlich:**
- Zentrale Dokumentation in `~/apollo-os-dev/v3.1.0/docs/`
- Auto-generierte Shortcut-Übersicht aus Niri-Configs
- Installationsanleitung für jeden Mode
- Migration Guide für Update von alter zu neuer Struktur

### Roadmap für Umstrukturierung

**Phase 1: Planung (1-2 Tage)**
- [ ] Neue Namenskonventionen definieren
- [ ] Ordnerstruktur festlegen
- [ ] Migration-Script schreiben
- [ ] Dokumentations-Template erstellen

**Phase 2: Migration (2-3 Tage)**
- [ ] Alle Scripts umbenennen und verschieben
- [ ] Alle Config-Dateien umbenennen
- [ ] Symlinks erstellen
- [ ] Dependencies in Scripts aktualisieren
- [ ] Niri Configs auf neue Pfade anpassen

**Phase 3: Testing (1 Tag)**
- [ ] Alle Visual Modes testen
- [ ] Alle Scripts auf Funktionalität prüfen
- [ ] Shortcuts verifizieren
- [ ] Services neu starten (systemd)

**Phase 4: Dokumentation (1 Tag)**
- [ ] README für jeden Mode schreiben
- [ ] SHORTCUTS.md generieren
- [ ] Migration Guide schreiben
- [ ] CHANGELOG aktualisieren

**Phase 5: Backup & Rollout (0.5 Tage)**
- [ ] Backup der alten Struktur erstellen
- [ ] Neue Struktur aktivieren
- [ ] Update-Script für andere Systeme (aiqhpex12, etc.)

**Geschätzte Gesamtdauer:** 5-7 Tage

### Wichtigkeit

🔴 **HOCH** - Die aktuelle Namensgebung und Struktur wird zunehmend unübersichtlich und schwer wartbar. Eine Umstrukturierung ist für die Langzeit-Wartbarkeit von Apollo OS essentiell.

**Empfehlung:** Umstrukturierung vor nächstem Major Release (v4.0.0) durchführen.


---

## 11. Spracheingabe: Akustisches Feedback

**Anforderung:** Die Spracheingabe soll vor dem Start ein kurzes akustisches Audio-Signal abspielen (zwei moderne Töne im Star Trek Enterprise Stil), damit man auch akustisch hört dass die Spracheingabe jetzt aktiv ist. Ein etwas anderes akustisches Signal soll abgespielt werden wenn die Spracheingabe abgeschlossen ist.

### Ziel

User-Feedback verbessern durch akustische Signale - der User hört sofort wenn die Aufnahme startet oder stoppt, ohne auf den Bildschirm schauen zu müssen. Perfekt für Vibe Coding und Hands-free Terminal-Bedienung.

### Implementierungsdetails

#### 1. Audio-Files generieren

**Zielverzeichnis:** `~/.local/share/apollo-os/sounds/`

Zuerst Verzeichnis erstellen:
```bash
mkdir -p ~/.local/share/apollo-os/sounds
cd ~/.local/share/apollo-os/sounds
```

**Start-Sound (voice-start.wav) - Zwei aufsteigende Töne:**

Charakteristik:
- Erster Ton: 800 Hz, Dauer 80ms
- Zweiter Ton: 1000 Hz, Dauer 80ms
- Fade-in: 10ms, Fade-out: 20ms (für sanften Klang)
- Stil: Star Trek Enterprise Communicator "chirp"

Generierungs-Befehle mit ffmpeg:
```bash
# Ersten Ton (800 Hz) generieren
ffmpeg -f lavfi -i "sine=frequency=800:duration=0.08" \
  -af "afade=t=in:d=0.01,afade=t=out:d=0.02" \
  tone1.wav -y 2>/dev/null

# Zweiten Ton (1000 Hz) generieren
ffmpeg -f lavfi -i "sine=frequency=1000:duration=0.08" \
  -af "afade=t=in:d=0.01,afade=t=out:d=0.02" \
  tone2.wav -y 2>/dev/null

# Beide Töne zusammenfügen
ffmpeg -i tone1.wav -i tone2.wav \
  -filter_complex "[0][1]concat=n=2:v=0:a=1" \
  voice-start.wav -y 2>/dev/null

# Temporäre Dateien löschen
rm tone1.wav tone2.wav
```

Oder als Einzeiler:
```bash
cd ~/.local/share/apollo-os/sounds && ffmpeg -f lavfi -i "sine=frequency=800:duration=0.08" -af "afade=t=in:d=0.01,afade=t=out:d=0.02" tone1.wav -y 2>/dev/null && ffmpeg -f lavfi -i "sine=frequency=1000:duration=0.08" -af "afade=t=in:d=0.01,afade=t=out:d=0.02" tone2.wav -y 2>/dev/null && ffmpeg -i tone1.wav -i tone2.wav -filter_complex "[0][1]concat=n=2:v=0:a=1" voice-start.wav -y 2>/dev/null && rm tone1.wav tone2.wav
```

**Ende-Sound (voice-end.wav) - Zwei absteigende Töne:**

Charakteristik:
- Erster Ton: 1000 Hz, Dauer 80ms (umgekehrt zum Start)
- Zweiter Ton: 800 Hz, Dauer 80ms
- Fade-in: 10ms, Fade-out: 20ms
- Stil: Umgekehrter "chirp" für klare Unterscheidung

Generierungs-Befehle mit ffmpeg:
```bash
# Ersten Ton (1000 Hz) generieren
ffmpeg -f lavfi -i "sine=frequency=1000:duration=0.08" \
  -af "afade=t=in:d=0.01,afade=t=out:d=0.02" \
  tone1.wav -y 2>/dev/null

# Zweiten Ton (800 Hz) generieren
ffmpeg -f lavfi -i "sine=frequency=800:duration=0.08" \
  -af "afade=t=in:d=0.01,afade=t=out:d=0.02" \
  tone2.wav -y 2>/dev/null

# Beide Töne zusammenfügen
ffmpeg -i tone1.wav -i tone2.wav \
  -filter_complex "[0][1]concat=n=2:v=0:a=1" \
  voice-end.wav -y 2>/dev/null

# Temporäre Dateien löschen
rm tone1.wav tone2.wav
```

Oder als Einzeiler:
```bash
cd ~/.local/share/apollo-os/sounds && ffmpeg -f lavfi -i "sine=frequency=1000:duration=0.08" -af "afade=t=in:d=0.01,afade=t=out:d=0.02" tone1.wav -y 2>/dev/null && ffmpeg -f lavfi -i "sine=frequency=800:duration=0.08" -af "afade=t=in:d=0.01,afade=t=out:d=0.02" tone2.wav -y 2>/dev/null && ffmpeg -i tone1.wav -i tone2.wav -filter_complex "[0][1]concat=n=2:v=0:a=1" voice-end.wav -y 2>/dev/null && rm tone1.wav tone2.wav
```

**Ergebnis:**
- `voice-start.wav` - ca. 14 KB
- `voice-end.wav` - ca. 14 KB

**Technische Parameter:**
- Format: WAV (PCM)
- Sample Rate: 44100 Hz (Standard)
- Channels: Mono
- Bit Depth: 16-bit
- Gesamtdauer: ~160ms pro Sound (2x 80ms)

#### 2. voice-input Script anpassen

**Datei:** `~/.local/bin/voice-input`

**Änderung 1: Start-Sound beim Beginn der Aufnahme**

Position: Im `else`-Block, wo die neue Aufnahme gestartet wird (ca. Zeile 60-62)

**Vorher:**
```bash
else
    # Starte neue Aufnahme mit animierter Benachrichtigung

    # Starte Animation
    "$HOME/.local/bin/voice-input-notification" &

    # Kurze Pause damit Animation startet
    sleep 0.2

    # Starte Aufnahme im Hintergrund
    parecord --channels=1 --rate=16000 --format=s16le "$AUDIO_FILE" &
    echo $! > "$PID_FILE"
fi
```

**Nachher:**
```bash
else
    # Starte neue Aufnahme mit animierter Benachrichtigung

    # Spiele Start-Sound ab (Star Trek Stil - aufsteigend)
    pw-play "$HOME/.local/share/apollo-os/sounds/voice-start.wav" >/dev/null 2>&1 &

    # Starte Animation
    "$HOME/.local/bin/voice-input-notification" &

    # Kurze Pause damit Animation startet
    sleep 0.2

    # Starte Aufnahme im Hintergrund
    parecord --channels=1 --rate=16000 --format=s16le "$AUDIO_FILE" &
    echo $! > "$PID_FILE"
fi
```

**Änderung 2: Ende-Sound beim Stoppen der Aufnahme**

Position: Im `if [ -f "$PID_FILE" ]`-Block, wo die Aufnahme gestoppt wird (ca. Zeile 15-22)

**Vorher:**
```bash
if [ -f "$PID_FILE" ]; then
    # Stoppe die Aufnahme
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        rm "$PID_FILE"

        # Stoppe Animation
        "$HOME/.local/bin/voice-input-notification" stop

        # Warte kurz, damit die Datei fertig geschrieben wird
        sleep 0.5

        # ... (Rest des Scripts)
```

**Nachher:**
```bash
if [ -f "$PID_FILE" ]; then
    # Stoppe die Aufnahme
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        rm "$PID_FILE"

        # Spiele Ende-Sound ab (Star Trek Stil - absteigend)
        pw-play "$HOME/.local/share/apollo-os/sounds/voice-end.wav" >/dev/null 2>&1 &

        # Stoppe Animation
        "$HOME/.local/bin/voice-input-notification" stop

        # Warte kurz, damit die Datei fertig geschrieben wird
        sleep 0.5

        # ... (Rest des Scripts)
```

**Wichtige Details:**
- `pw-play` nutzt PipeWire für Audio-Playback (funktioniert auf Fedora/Wayland)
- `>/dev/null 2>&1` leitet alle Outputs um (kein Spam in Terminal)
- `&` am Ende startet Playback im Hintergrund (nicht-blockierend)
- Sound spielt während die restlichen Aktionen (Animation, Transkription) laufen

#### 3. Testing

Nach der Implementierung sollten die Sounds getestet werden:

```bash
# Start-Sound testen
pw-play ~/.local/share/apollo-os/sounds/voice-start.wav

# Ende-Sound testen
pw-play ~/.local/share/apollo-os/sounds/voice-end.wav
```

### Erwartetes Verhalten nach Implementierung

#### Mit Push-to-Talk (Rechte Strg-Taste):
1. **Taste gedrückt halten**
   - Sound: "Chirp-Chirp" (aufsteigend: 800Hz → 1000Hz)
   - Benachrichtigung mit Animation erscheint
   - Aufnahme läuft

2. **Sprechen** (z.B. "git status")

3. **Taste loslassen**
   - Sound: "Chirp-Chirp" (absteigend: 1000Hz → 800Hz)
   - Transkription beginnt
   - Text wird eingefügt + Enter automatisch gedrückt

#### Mit Toggle (Super+V):
1. **Super+V drücken**
   - Sound: "Chirp-Chirp" (aufsteigend)
   - Aufnahme startet

2. **Sprechen**

3. **Super+V nochmal drücken**
   - Sound: "Chirp-Chirp" (absteigend)
   - Transkription und Text-Einfügung

### Vorteile dieser Lösung

- **Akustische Bestätigung:** Keine Notwendigkeit auf Bildschirm zu schauen
- **Intuitive Signale:** Aufsteigend = Start, Absteigend = Ende
- **Sci-Fi Ästhetik:** Star Trek Enterprise Stil passt zum Apollo OS Konzept
- **Nicht-blockierend:** Sounds spielen im Hintergrund (`&`)
- **Konsistent:** Gleiche Sounds für beide Input-Methoden (Super+V und Rechte Strg)
- **Vibe Coding:** Perfekt für Hands-free Terminal-Bedienung
- **Minimale Latenz:** Sounds sind nur 160ms lang (kaum merkbar)

### Betroffene Dateien

**Neu erstellt:**
- `~/.local/share/apollo-os/sounds/voice-start.wav` (ca. 14 KB)
- `~/.local/share/apollo-os/sounds/voice-end.wav` (ca. 14 KB)

**Zu ändern:**
- `~/.local/bin/voice-input` (2 Zeilen hinzufügen)

### Technische Details

**Audio-Charakteristik:**
- Format: WAV PCM, 16-bit, Mono, 44.1 kHz
- Frequenzen: 800 Hz und 1000 Hz (harmonische Töne)
- Dauer: 80ms pro Ton, insgesamt ~160ms
- Stil: Star Trek Enterprise Communicator "chirp"
- Inspiration: Apollo-Raumschiff-Computer, moderne Sci-Fi UI

**Warum genau diese Frequenzen?**
- 800 Hz: Tief genug für warmen Klang, nicht zu aufdringlich
- 1000 Hz: Hoch genug für klare Unterscheidung
- Intervall: Große Terz (~200 Hz) klingt angenehm und professionell
- Umkehrung (1000→800) macht Ende-Signal eindeutig unterscheidbar

**Alternative falls pw-play nicht verfügbar:**
```bash
# Mit paplay (PulseAudio)
paplay "$HOME/.local/share/apollo-os/sounds/voice-start.wav" &

# Mit aplay (ALSA)
aplay "$HOME/.local/share/apollo-os/sounds/voice-start.wav" &

# Mit mpv
mpv --no-video "$HOME/.local/share/apollo-os/sounds/voice-start.wav" &
```

### Resultat

Ein modernes, professionelles Audio-Feedback-System für Spracheingabe im Star Trek Stil, das perfekt zur Apollo OS Sci-Fi Ästhetik passt und Hands-free Terminal-Bedienung unterstützt. 🚀


---

## 12. Wake Word Detection "Apollo" - System reparieren

**Problem:** Das Apollo Wake Word System existiert bereits (`apollo-wake-listener.py`), funktioniert aber nicht weil Python-Module fehlen. Zusätzlich sollen Star Trek Sounds zur Bestätigung abgespielt werden.

**Anforderung:**
1. Wake Word System reparieren
2. Nach "Apollo" Wake Word → Star Trek Sound (voice-start.wav) abspielen
3. Nach Befehl-Ausführung → Star Trek Sound (voice-end.wav) abspielen

### Aktueller Zustand

**Existierende Dateien:**
- Script: `/home/apollo/.local/bin/apollo-wake-listener.py`
- Service: `~/.config/systemd/user/apollo-wake.service`
- Vosk-Modell: `~/.local/share/vosk-models/vosk-model-small-de-0.15/`
- Sprachausgabe: `/home/apollo/.local/bin/apollo-speak.sh`

**Service-Status:**
```bash
systemctl --user status apollo-wake.service
# Fehler: ModuleNotFoundError: No module named 'vosk'
# Service crasht wegen fehlender Python-Module
```

**Wake Word:** `"apollo"` (Zeile 7 in apollo-wake-listener.py)

**Verfügbare Sprachbefehle (nach Wake Word):**
- "Apollo, wie spät ist es?" → Sagt die Uhrzeit
- "Apollo, welcher Tag ist heute?" → Sagt das Datum
- "Apollo, öffne Terminal" → Startet Alacritty
- "Apollo, starte Browser" → Öffnet Microsoft Edge
- "Apollo, sperren" → Sperrt Bildschirm (swaylock)
- "Apollo, ausschalten" → Suspend/Sleep
- "Apollo, Neustart" → System reboot

### Reparatur-Schritte

#### 1. Python-Module installieren

**Problem:** `vosk` und `sounddevice` fehlen

**Lösung:**
```bash
# Schritt 1: pip installieren (falls noch nicht vorhanden)
python3 -m ensurepip --user --default-pip

# Schritt 2: Vosk und SoundDevice installieren
python3 -m pip install --user vosk sounddevice
```

**Erwartete Module nach Installation:**
- `vosk` (Version 0.3.45+) - Speech Recognition
- `sounddevice` (Version 0.5.5+) - Audio Input
- `tqdm` (Dependency)
- `srt` (Dependency)
- `websockets` (Dependency)

**Verifizierung:**
```bash
python3 -c "import vosk; import sounddevice; print('OK')"
# Sollte "OK" ausgeben ohne Fehler
```

#### 2. Star Trek Sounds zum Wake Word System hinzufügen

**Datei:** `/home/apollo/.local/bin/apollo-wake-listener.py`

**Änderung 1: Sound-Playback-Funktion hinzufügen**

Position: Nach der `get_german_month()` Funktion (ca. Zeile 42)

```python
def play_sound(sound_file):
    """Play audio feedback sound"""
    sound_path = os.path.expanduser(f"~/.local/share/apollo-os/sounds/{sound_file}")
    if os.path.exists(sound_path):
        subprocess.Popen(["pw-play", sound_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
```

**Änderung 2: Sound nach Wake Word Detection**

Position: In der Wake Word Detection Logic (ca. Zeile 124-132)

**Vorher:**
```python
if WAKE_WORD in text:
    log(f"*** WAKE WORD DETECTED ***")
    wake_word_detected = True
    wake_word_time = time.time()

    if len(text.split()) > 1:
        execute_command(text)
        wake_word_detected = False
```

**Nachher:**
```python
if WAKE_WORD in text:
    log(f"*** WAKE WORD DETECTED ***")
    # Play Star Trek sound - Apollo is listening
    play_sound("voice-start.wav")
    wake_word_detected = True
    wake_word_time = time.time()

    if len(text.split()) > 1:
        execute_command(text)
        # Play end sound after command execution
        play_sound("voice-end.wav")
        wake_word_detected = False
```

**Änderung 3: Sound nach Command Execution (Follow-up Befehle)**

Position: Im `elif wake_word_detected:` Block (ca. Zeile 133-138)

**Vorher:**
```python
elif wake_word_detected:
    if time.time() - wake_word_time <= COMMAND_TIMEOUT:
        execute_command(text)
    else:
        log("Command timeout - ignoring")
    wake_word_detected = False
```

**Nachher:**
```python
elif wake_word_detected:
    if time.time() - wake_word_time <= COMMAND_TIMEOUT:
        execute_command(text)
        # Play end sound after command execution
        play_sound("voice-end.wav")
    else:
        log("Command timeout - ignoring")
    wake_word_detected = False
```

**Wichtig:**
- Die Sounds `voice-start.wav` und `voice-end.wav` müssen bereits existieren (siehe Abschnitt 11)
- Playback via `pw-play` (PipeWire) im Hintergrund
- `stdout` und `stderr` nach `DEVNULL` für saubere Logs

#### 3. Service neu starten

Nach den Änderungen Service neu starten:

```bash
systemctl --user restart apollo-wake.service

# Status prüfen
systemctl --user status apollo-wake.service

# Sollte "active (running)" zeigen
```

**Logs überwachen:**
```bash
journalctl --user -u apollo-wake.service -f
```

**Erwartete Log-Ausgaben:**
```
✓ Vosk model loaded
Starting audio stream...
✓ Listening for 'apollo'...
```

#### 4. Testing

**Test 1: Wake Word Detection**
1. Sage laut: **"Apollo"**
2. → Sollte Star Trek Sound (voice-start.wav) abspielen
3. → Log sollte zeigen: "*** WAKE WORD DETECTED ***"

**Test 2: Einfacher Befehl**
1. Sage: **"Apollo, wie spät ist es?"**
2. → Start-Sound abgespielt
3. → System sagt die Uhrzeit (via apollo-speak.sh)
4. → Ende-Sound (voice-end.wav) abgespielt

**Test 3: Zwei-Schritt-Befehl**
1. Sage: **"Apollo"**
2. → Start-Sound
3. Warte kurz (System hört zu)
4. Sage: **"öffne Terminal"**
5. → Terminal öffnet sich
6. → Ende-Sound

**Timeout:** 5 Sekunden nach "Apollo" (siehe `COMMAND_TIMEOUT` in Zeile 10)

### Erwartetes Verhalten nach Reparatur

#### Workflow:
1. **User sagt:** "Apollo"
   - 🔊 **Star Trek Sound** (voice-start.wav - aufsteigend)
   - System hört zu für 5 Sekunden

2. **User sagt:** "wie spät ist es"
   - System führt Befehl aus
   - Sprachausgabe: "Es ist 14 Uhr 30"
   - 🔊 **Star Trek Sound** (voice-end.wav - absteigend)

#### Oder als Ein-Schritt-Befehl:
1. **User sagt:** "Apollo, öffne Terminal"
   - 🔊 Start-Sound (voice-start.wav)
   - Terminal öffnet sich
   - TTS: "Terminal wird geöffnet"
   - 🔊 Ende-Sound (voice-end.wav)

### Vorteile

- **Hands-free Bedienung:** Keine Tastatur/Maus nötig
- **Akustisches Feedback:** Man hört sofort wenn Apollo lauscht
- **Sci-Fi Ästhetik:** Star Trek Sounds passen zum Apollo-Konzept
- **Kontinuierliches Listening:** System läuft im Hintergrund
- **Deutsche Spracherkennung:** Vosk-Modell für Deutsch optimiert
- **Erweiterbar:** Neue Befehle können einfach hinzugefügt werden

### Technische Details

**Vosk Speech Recognition:**
- Modell: `vosk-model-small-de-0.15` (Deutsch)
- Offline-Erkennung (keine Cloud)
- Sample Rate: 16000 Hz
- Echtzeit-Transkription

**Wake Word Detection:**
- Kontinuierliches Audio-Streaming
- Pattern Matching auf "apollo" im erkannten Text
- Timeout-basiertes Command-Listening (5 Sekunden)

**Audio-Pipeline:**
```
Mikrofon → sounddevice → Vosk → Text → Command Parser → Action + TTS + Sound
```

### Troubleshooting

**Problem: Service crasht weiterhin**
```bash
# Prüfe ob Module wirklich installiert sind
python3 -c "import vosk, sounddevice"

# Falls Fehler: Module neu installieren
python3 -m pip install --user --upgrade vosk sounddevice
```

**Problem: Kein Audio-Input**
```bash
# Prüfe verfügbare Audio-Geräte
python3 -c "import sounddevice; print(sounddevice.query_devices())"

# Teste Mikrofon
parecord --channels=1 test.wav
# Sprechen, dann Ctrl+C
paplay test.wav
```

**Problem: Wake Word wird nicht erkannt**
```bash
# Logs live ansehen
journalctl --user -u apollo-wake.service -f

# Spreche "Apollo" laut und deutlich
# Log sollte zeigen: "Recognized: 'apollo'"
```

**Problem: Sounds werden nicht abgespielt**
```bash
# Teste Sounds manuell
pw-play ~/.local/share/apollo-os/sounds/voice-start.wav
pw-play ~/.local/share/apollo-os/sounds/voice-end.wav

# Prüfe ob PipeWire läuft
systemctl --user status pipewire pipewire-pulse
```

### Betroffene Dateien

**Zu ändern:**
- `/home/apollo/.local/bin/apollo-wake-listener.py` (3 Änderungen)

**Neu zu installieren:**
- Python-Module: `vosk`, `sounddevice`

**Bereits vorhanden:**
- `~/.local/share/apollo-os/sounds/voice-start.wav`
- `~/.local/share/apollo-os/sounds/voice-end.wav`
- `~/.config/systemd/user/apollo-wake.service`
- `~/.local/share/vosk-models/vosk-model-small-de-0.15/`

### Resource-Verbrauch

**CPU:** ~1-2% im Idle (nur Listening)
**RAM:** ~200 MB (Vosk-Modell im Speicher)
**Disk:** ~150 MB (Vosk-Modell)

**Empfehlung:** Für Laptops/Low-Power-Systeme kann der Service bei Bedarf gestoppt werden:
```bash
systemctl --user stop apollo-wake.service
```

### Resultat

Ein vollständig funktionsfähiges Wake Word Detection System mit Star Trek Audio-Feedback, das Hands-free Sprachbefehle ermöglicht und perfekt zur Apollo OS Sci-Fi Ästhetik passt. 🚀🎙️

### Einheitliche Benennung: apollo-os Präfix

**Problem:** Aktuell sind Apollo OS Anpassungen über verschiedene Ordner und Dateien verteilt, ohne einheitliches Benennungsschema. Manche Files haben `apollo-os-` Präfix, andere nicht. Das macht es schwer, alle Apollo OS spezifischen Änderungen zu identifizieren.

**Beispiele für inkonsistente Benennung:**
- `voice-input` ❌ (kein apollo-os Präfix)
- `toggle-gaps.sh` ❌ (kein apollo-os Präfix)
- `wallpaper-cycle.sh` ❌ (kein apollo-os Präfix)
- `apollo-os-lock.sh` ✅ (korrektes Präfix)
- `apollo-os-quickmenu.sh` ✅ (korrektes Präfix)

**Ziel:**
Alle Apollo OS spezifischen Dateien, Scripts, Configs und Services müssen mit `apollo-os-` beginnen, damit:
- Man mit `ls apollo-os-*` alle Anpassungen sofort findet
- Unterscheidung zwischen System-Standard und Apollo OS klar ist
- Deinstallation/Migration einfacher wird
- Eindeutige Zuordnung möglich ist

**Neue Benennungskonvention:**

#### Scripts in ~/.local/bin/
```
VORHER                           NACHHER
-------------------------------  ------------------------------------
voice-input                   →  apollo-os-voice-input
voice-input-notification      →  apollo-os-voice-notification
toggle-gaps.sh                →  apollo-os-toggle-gaps
toggle-waybar.sh              →  apollo-os-toggle-waybar
toggle-center.sh              →  apollo-os-toggle-center
wallpaper-cycle.sh            →  apollo-os-wallpaper-cycle
```

#### Configs in ~/.config/
```
VORHER                           NACHHER
-------------------------------  ------------------------------------
~/.config/niri/config.kdl     →  ~/.config/apollo-os/niri/current.kdl
~/.config/waybar/config       →  ~/.config/apollo-os/waybar/current/config
~/.config/mako/config         →  ~/.config/apollo-os/mako/config
~/.config/rofi/config.rasi    →  ~/.config/apollo-os/rofi/config.rasi
```

#### Systemd Services in ~/.config/systemd/user/
```
VORHER                           NACHHER
-------------------------------  ------------------------------------
apollo-rightctrl-voice.service → apollo-os-rightctrl-voice.service
```

**Vorteile:**
- ✅ Alle Apollo OS Files mit einem Befehl finden: `find ~ -name "apollo-os-*"`
- ✅ Klare Trennung zwischen System-Standard und Apollo OS Anpassungen
- ✅ Einfaches Backup: `tar czf apollo-os-backup.tar.gz ~/.local/bin/apollo-os-* ~/.config/apollo-os/`
- ✅ Deinstallation wird trivial: Alle `apollo-os-*` Files entfernen
- ✅ Keine Verwechslung mit anderen Anwendungen
- ✅ Professionelles, konsistentes Branding

**Migrations-Script erforderlich:**
```bash
#!/bin/bash
# apollo-os-migrate-naming.sh
# Benennt alle Files nach neuer Konvention um und aktualisiert alle Referenzen

# 1. Scripts umbenennen
mv ~/.local/bin/voice-input ~/.local/bin/apollo-os-voice-input
mv ~/.local/bin/toggle-gaps.sh ~/.local/bin/apollo-os-toggle-gaps
# ... etc.

# 2. Symlinks für Rückwärts-Kompatibilität (temporär)
ln -s ~/.local/bin/apollo-os-voice-input ~/.local/bin/voice-input

# 3. Alle Referenzen in Configs aktualisieren
sed -i 's|voice-input|apollo-os-voice-input|g' ~/.config/niri/config*.kdl
sed -i 's|toggle-gaps.sh|apollo-os-toggle-gaps|g' ~/.config/niri/config*.kdl
# ... etc.

# 4. Systemd Services aktualisieren
systemctl --user stop apollo-rightctrl-voice.service
mv ~/.config/systemd/user/apollo-rightctrl-voice.service \
   ~/.config/systemd/user/apollo-os-rightctrl-voice.service
systemctl --user daemon-reload
systemctl --user enable --now apollo-os-rightctrl-voice.service
```

**Wichtigkeit:** 🔴 **KRITISCH** für v4.0.0 - Einheitliche Benennung ist Grundvoraussetzung für professionelles Open-Source-Projekt und erleichtert Wartung enorm.

### Zusammenfassung der Umstrukturierung

**Drei Hauptziele:**
1. ✅ **Intuitive Namen** für Visual Modes und Komponenten
2. ✅ **Klare Struktur** mit Kategorisierung in Unterordner
3. ✅ **Einheitliches Präfix** `apollo-os-` für alle spezifischen Files

**Ergebnis:** Ein professionell organisiertes System, das leicht zu warten, zu dokumentieren und zu erweitern ist.

