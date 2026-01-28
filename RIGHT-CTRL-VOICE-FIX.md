# Apollo OS v5.1.3 - Right Ctrl Voice Input Fix

## Problem:
Right Ctrl Push-to-Talk funktioniert nicht auf Remote-Rechner

## Ursache gefunden:
1. **Service File fehlte im Projekt** - Wurde nur dynamisch vom Installer erstellt
2. **Voice Sound Files fehlten** - voice-start.wav und voice-end.wav waren nicht im Projekt
3. **Installer kopierte Sounds vom falschen Ort** - Nur von apollo-os-orbit/extras/sounds/

## Fixes implementiert:

### 1. ✅ Service File hinzugefügt
**Datei**: apollo-os-sys/systemd/apollo-rightctrl-voice.service
```ini
[Unit]
Description=Apollo OS Right Ctrl Voice Input Trigger
After=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 %h/.local/bin/apollo-os-rightctrl-voice.py
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
```

### 2. ✅ Voice Sound Files hinzugefügt
**Dateien**: 
- apollo-os-sys/sounds/voice-start.wav (14 KB, Star Trek Style 800Hz→1000Hz)
- apollo-os-sys/sounds/voice-end.wav (14 KB, Star Trek Style 1000Hz→800Hz)

**Funktion**:
- voice-start.wav spielt beim Drücken der Right Ctrl Taste
- voice-end.wav spielt beim Loslassen (Transkription startet)

### 3. ✅ Installer Sound Installation gefixt
**Änderung**: Installer kopiert jetzt Sounds aus BEIDEN Verzeichnissen:
- apollo-os-sys/sounds/ (voice-*.wav, sleep.mp3, wake.mp3)
- apollo-os-orbit/extras/sounds/ (falls vorhanden)

**Code**:
```bash
# Copy from apollo-os-sys (voice-start.wav, voice-end.wav, sleep.mp3, wake.mp3)
if [ -d "$SCRIPT_DIR/apollo-os-sys/sounds" ]; then
    cp "$SCRIPT_DIR/apollo-os-sys/sounds/"*.wav "$HOME/.local/share/apollo-os/sounds/" 2>/dev/null || true
    cp "$SCRIPT_DIR/apollo-os-sys/sounds/"*.mp3 "$HOME/.local/share/apollo-os/sounds/" 2>/dev/null || true
fi
```

## So funktioniert Right Ctrl Voice:

1. **User drückt Right Ctrl** → voice-start.wav spielt
2. **Aufnahme startet** (parecord)
3. **User lässt Right Ctrl los** → voice-end.wav spielt
4. **Transkription** mit whisper.cpp
5. **Text wird eingefügt** + Enter gedrückt

## Voraussetzungen (prüfen nach Installation):

```bash
# 1. Service läuft?
systemctl --user status apollo-rightctrl-voice

# 2. User in input Gruppe?
groups | grep input

# 3. Scripts vorhanden?
ls -la ~/.local/bin/apollo-os-rightctrl-voice.py
ls -la ~/.local/bin/voice-input*

# 4. Sound Files vorhanden?
ls -la ~/.local/share/apollo-os/sounds/voice-*.wav

# 5. whisper.cpp installiert?
ls -la ~/.local/bin/whisper-cpp
```

## Debugging:

Falls nicht funktioniert:
```bash
# Live Logs anzeigen
journalctl --user -u apollo-rightctrl-voice -f

# Service neu starten
systemctl --user restart apollo-rightctrl-voice

# Manuell testen
python3 ~/.local/bin/apollo-os-rightctrl-voice.py
```

