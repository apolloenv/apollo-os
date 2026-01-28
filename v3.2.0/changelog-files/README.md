# Changelog Files - 2026-01-23

Dieser Ordner enthält alle Scripts und Konfigurationsdateien die am 23. Januar 2026 erstellt oder modifiziert wurden.

## 📁 Übersicht

### Voice Input & Push-to-Talk

#### `apollo-os-rightctrl-voice.py`
**Zweck:** Python-Script für Push-to-Talk mit rechter Strg-Taste  
**Installation:** `~/.local/bin/apollo-os-rightctrl-voice.py`  
**Funktion:**
- Erkennt rechte Strg-Taste über evdev (python3-evdev)
- Push-to-Talk Modus: Taste halten = aufnehmen, loslassen = stoppen
- Startet/stoppt `voice-input` Script automatisch
- Läuft als systemd User Service

**Abhängigkeiten:**
- `python3-evdev` Paket
- `voice-input` Script muss vorhanden sein

**Verwendung:**
```bash
chmod +x apollo-os-rightctrl-voice.py
cp apollo-os-rightctrl-voice.py ~/.local/bin/
```

---

#### `voice-input`
**Zweck:** Haupt-Script für Spracheingabe mit whisper.cpp  
**Installation:** `~/.local/bin/voice-input`  
**Funktion:**
- Toggle-basierte Aufnahme mit parecord
- Transkription mit whisper.cpp
- Text-Eingabe mit wtype
- **Auto-Enter:** Drückt automatisch Return nach Transkription
- **Newline-Bereinigung:** `tr -d '\n'` entfernt Leerzeilen

**Änderungen (2026-01-23):**
```bash
# Alt:
echo -n "$TEXT" | wtype -
# Neu:
printf "%s" "$TEXT" | wtype -
sleep 0.1
wtype -k Return
```

**Abhängigkeiten:**
- whisper.cpp (`~/.local/bin/whisper-cpp`)
- Whisper Modell (`~/.local/share/whisper/ggml-base.bin`)
- parecord (PulseAudio/PipeWire)
- wtype (Wayland text input)
- ffmpeg (Audio-Konvertierung)

---

#### `apollo-rightctrl-voice.service`
**Zweck:** systemd User Service für Push-to-Talk Script  
**Installation:** `~/.config/systemd/user/apollo-rightctrl-voice.service`  
**Funktion:**
- Startet `apollo-os-rightctrl-voice.py` automatisch beim Login
- Restart bei Crashes (Restart=always)
- Läuft als User-Service (nicht root)

**Installation:**
```bash
cp apollo-rightctrl-voice.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable apollo-rightctrl-voice.service
systemctl --user start apollo-rightctrl-voice.service
```

**Status prüfen:**
```bash
systemctl --user status apollo-rightctrl-voice.service
journalctl --user -u apollo-rightctrl-voice.service -f
```

---

### Visual Modes & Benachrichtigungen

#### `apollo-os-visual-mode.sh`
**Zweck:** Switcher für visuelle Modi (Classic, Developer, i3, Orbit, etc.)  
**Installation:** `~/.local/bin/apollo-os-visual-mode.sh`  
**Funktion:**
- Wechselt zwischen 14 verschiedenen Visual Modes
- Kopiert entsprechende Niri/Waybar Configs
- Lädt Niri neu
- Verwaltet screen-corners (ein/aus je nach Mode)

**Änderungen (2026-01-23):**
```bash
# Alt:
notify-send "Apollo OS" "Visual Mode: ${new_mode^}"
# Neu:
notify-send "Interface geladen"
```

**Verwendung:**
```bash
apollo-os-visual-mode.sh          # Toggle durch Modi
apollo-os-visual-mode.sh orbit    # Direkt zu Orbit Mode
apollo-os-visual-mode.sh status   # Aktuellen Mode anzeigen
```

---

#### `apollo-os-welcome-tts.sh`
**Zweck:** TTS-Begrüßung beim System-Start  
**Installation:** `~/.local/bin/apollo-os-welcome-tts.sh`  
**Funktion:**
- Spricht Willkommensnachricht mit edge-tts (Amala Stimme)
- Zeigt Netzwerkstatus an
- Läuft komplett im Hintergrund (keine sichtbaren Fenster)

**Änderungen (2026-01-23):**
```bash
# Gesamtes TTS-Processing in Background-Subshell:
{
    # ... TTS Code ...
    pw-play "$TMPFILE" >/dev/null 2>&1
} &
exit 0  # Script beendet sich sofort
```

**Zweck der Änderung:** Verhindert weißes Fenster beim Start

---

### Mako Benachrichtigungen

#### `mako-config`
**Zweck:** Mako Notification Daemon Konfiguration  
**Installation:** `~/.config/mako/config`  
**Funktion:**
- Dark Grayscale Design (passend zu Rofi)
- Position: Rechts oben (anchor=top-right)
- Maximal 5 Benachrichtigungen gleichzeitig
- Eckiges Design ohne Rundungen (border-radius=0)
- JetBrainsMono Schriftart

**Design-Eigenschaften:**
```ini
# Farben
background-color=#1a1a1a
text-color=#d0d0d0
border-color=#4a4a4a

# Form
border-radius=0
border-size=3

# Position
anchor=top-right

# Limits
max-visible=5
```

**Installation:**
```bash
cp mako-config ~/.config/mako/config
makoctl reload
```

---

## 🔧 Installation aller Files

### Schritt 1: Abhängigkeiten installieren
```bash
sudo dnf install -y python3-evdev
```

### Schritt 2: Scripts kopieren
```bash
chmod +x apollo-os-rightctrl-voice.py apollo-os-visual-mode.sh apollo-os-welcome-tts.sh voice-input
cp apollo-os-rightctrl-voice.py ~/.local/bin/
cp voice-input ~/.local/bin/
cp apollo-os-visual-mode.sh ~/.local/bin/
cp apollo-os-welcome-tts.sh ~/.local/bin/
```

### Schritt 3: Configs kopieren
```bash
cp mako-config ~/.config/mako/config
makoctl reload
```

### Schritt 4: systemd Service einrichten
```bash
mkdir -p ~/.config/systemd/user
cp apollo-rightctrl-voice.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable apollo-rightctrl-voice.service
systemctl --user start apollo-rightctrl-voice.service
```

### Schritt 5: Niri Config anpassen
In allen Niri Configs (`~/.config/niri/config*.kdl`) sollte Super+K für Kitty hinzugefügt sein:
```kdl
Mod+K { spawn "kitty"; }
```

Dies wurde bereits in allen 14 Configs automatisch eingefügt.

---

## 📊 Änderungsübersicht

| File | Typ | Hauptänderung |
|------|-----|---------------|
| `apollo-os-rightctrl-voice.py` | Python | Push-to-Talk statt Toggle |
| `voice-input` | Bash | Auto-Enter + Newline-Bereinigung |
| `apollo-rightctrl-voice.service` | systemd | Service für Push-to-Talk |
| `apollo-os-visual-mode.sh` | Bash | Benachrichtigung: "Interface geladen" |
| `apollo-os-welcome-tts.sh` | Bash | Background-Processing (kein Fenster) |
| `mako-config` | INI | Rofi-Design, rechts oben, max 5 |

---

## 🎯 Features

### Push-to-Talk Voice Input
- ✅ Rechte Strg-Taste halten = aufnehmen
- ✅ Loslassen = stoppen + transkribieren
- ✅ Automatisches Enter nach Transkription
- ✅ Keine Leerzeilen vor Text
- ✅ Perfekt für Terminal-Befehle

### Mako Design
- ✅ Dark Grayscale (wie Rofi)
- ✅ Position rechts oben
- ✅ Eckig, minimalistisch
- ✅ Max 5 Benachrichtigungen
- ✅ JetBrainsMono Font

### Visual Modes
- ✅ Einheitliche Benachrichtigung "Interface geladen"
- ✅ Kürzere, prägnantere Meldungen
- ✅ 14 verschiedene Modi verfügbar

---

## 📝 Weitere Informationen

Siehe **CHANGELOG-2026-01-23.md** im Hauptverzeichnis für:
- Detaillierte Änderungsbeschreibungen
- Code-Vergleiche (Vorher/Nachher)
- Verwendungsbeispiele
- Troubleshooting
- Offene To-Dos

---

**Version:** Apollo OS v3.1.0  
**Datum:** 2026-01-23  
**Autor:** Manuel Kraibacher

---

## Rofi Configuration

### `rofi-config.rasi`
**Zweck:** Rofi Application Launcher & Quick Menu Konfiguration  
**Installation:** `~/.config/rofi/config.rasi`  
**Funktion:**
- Dark Grayscale Design (minimalistisch, monochrom)
- Eckige Form ohne Rundungen (border-radius: 0)
- 3px Border in hellem Grau (#4a4a4a)
- JetBrainsMono Schriftart

**Design-Eigenschaften:**
```rasi
window {
    width:            700px;
    border:           3px solid;
    border-radius:    0px;
}

listview {
    lines:            6;      // Halbe Höhe (vorher: 12)
    scrollbar:        true;
}
```

**Änderung (2026-01-23):**
- Höhe halbiert: 12 → 6 sichtbare Zeilen
- Kompakteres Menu, weniger Bildschirmfläche
- Scrollbar bei mehr als 6 Einträgen

**Installation:**
```bash
mkdir -p ~/.config/rofi
cp rofi-config.rasi ~/.config/rofi/config.rasi
```

**Verwendung:**
```bash
rofi -show drun          # Application Launcher
rofi -show run           # Run Command
rofi -show window        # Window Switcher
```

