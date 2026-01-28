# Apollo OS - Audio System Implementation Guide

**Version:** v0.4.1+audio  
**Status:** Optional Feature - Production Ready  
**Copyright © 2026 by Manuel Kraibacher**

---

## 📋 Übersicht

Das Apollo OS Audio-System fügt Sprachausgabe (Text-to-Speech) hinzu, um das System "lebendig" zu machen. Basierend auf **Piper TTS** mit der **LUNA Voice** (britisch, professionell, ruhig).

### Features
- 🎙️ **LUNA Voice:** Hochwertige neurale Sprachsynthese
- 🔔 **Announcement Flow:** Chime → Pause → Voice
- 💾 **TTS Caching:** Bereits generierte Sätze werden gecacht
- 🚀 **Schnelle Antworten:** Vorgeladene Phrasen für System-Events

---

## 🚀 Installation

### Voraussetzungen
- Apollo OS v0.4.1 muss bereits installiert sein
- Internetverbindung für Download des Voice Models (~100 MB)

### Installation starten

```bash
cd ~/apollo-os-dev/v0.4.1/scripts
./apollo-os-audio-installer.sh
```

Der Installer führt automatisch durch:
1. Installation von Piper TTS & Audio-Tools
2. Download des LUNA Voice Models
3. Generierung von Sound-Effekten (Chime)
4. Installation des `apollo-speak` Befehls
5. Test der Audio-Ausgabe

**Dauer:** Ca. 5-10 Minuten

---

## 🎯 Verwendung

### Basis-Befehl

```bash
apollo-speak "Hello, Apollo here. Systems operational."
```

### Vordefinierte Phrasen

Für häufig verwendete System-Messages gibt es Shortcuts:

```bash
apollo-speak boot              # "Apollo Core initialized..."
apollo-speak welcome           # "Identity confirmed. Welcome back."
apollo-speak lock              # "System secured. Standing by."
apollo-speak unlock            # "Access granted. Resuming session."
apollo-speak shutdown          # "Shutting down services..."
apollo-speak battery_low       # "Warning. Energy levels at 20 percent."
apollo-speak battery_critical  # "Critical alert. Energy reserves critical."
apollo-speak uplink_ready      # "Nexus uplink established."
apollo-speak uplink_lost       # "Connection lost. Local processing only."
```

---

## 🔗 System-Integration

### In Wrapper-Scripts

**Beispiel: apollo-os-wrapper-niri.sh**

```bash
# Nach Session-Start (am Ende des Wrappers)
apollo-speak welcome &
```

### In swayidle Config

**Beispiel: swayidle Lock/Unlock Events**

```bash
# Lock Screen
timeout 300 'apollo-speak lock && swaylock -f -C $SWAYLOCK_CONFIG'

# Unlock (nach Resume)
after-resume 'apollo-speak unlock'
```

### Im Apollo Daemon

**Beispiel: apollo-os-daemon.py**

```python
def check_battery(self) -> Optional[Dict[str, Any]]:
    # ... bestehender Code ...
    
    if not battery.power_plugged:
        if battery.percent <= 10:
            # Sprachausgabe bei kritischem Akkustand
            subprocess.run(['apollo-speak', 'battery_critical'])
        elif battery.percent <= 20:
            subprocess.run(['apollo-speak', 'battery_low'])
```

### Beim Boot/Shutdown

**Systemd Service:** `apollo-os-boot-voice.service`

```ini
[Unit]
Description=Apollo OS Boot Voice Announcement
After=sound.target

[Service]
Type=oneshot
ExecStart=/home/%u/.local/bin/apollo-speak boot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

---

## 📂 Verzeichnisstruktur

Nach Installation:

```
~/.local/share/apollo-os/
├── voices/
│   ├── luna.onnx           # LUNA Voice Model (100 MB)
│   └── luna.onnx.json      # Model Configuration
└── sounds/
    ├── chime.wav           # 2-Ton Chime (880Hz -> 660Hz)
    └── silence.wav         # Stille (für Padding)

/tmp/apollo-tts-cache/      # TTS Cache (wird bei Reboot geleert)
└── <md5-hash>.wav          # Gecachte Sprachausgaben
```

---

## ⚙️ Konfiguration

### Voice Model ändern

Falls du ein anderes Piper Voice Model verwenden möchtest:

```bash
# Neues Model downloaden
cd ~/.local/share/apollo-os/voices
wget https://github.com/rhasspy/piper/releases/download/v1.2.0/<model-name>.onnx

# apollo-speak.sh editieren
nano ~/.local/bin/apollo-speak
# Ändere VOICE_MODEL Pfad
```

### Sprechgeschwindigkeit anpassen

**In apollo-speak.sh:**

```bash
# Zeile 17
LENGTH_SCALE="1.2"  # Standard: 1.2 (langsamer)
                    # 1.0 = Normal
                    # 0.8 = Schneller
```

### Chime Sound anpassen

**Eigenen Chime erstellen:**

```bash
# Beispiel: Höhere Töne (1000Hz -> 800Hz)
ffmpeg -f lavfi -i "sine=frequency=1000:duration=0.2" \
       -f lavfi -i "sine=frequency=800:duration=0.2" \
       -filter_complex "[0][1]concat=n=2:v=0:a=1" \
       -y ~/.local/share/apollo-os/sounds/chime.wav
```

---

## 🎨 Erweiterte Features

### Silent Mode (DND)

Deaktiviere Sprachausgabe temporär:

```bash
# Environment Variable setzen
export APOLLO_VOICE_MUTE=1

# In .bashrc für permanent:
echo 'export APOLLO_VOICE_MUTE=0' >> ~/.bashrc
```

**In apollo-speak.sh ergänzen:**

```bash
# Am Anfang von play_announcement()
if [ "$APOLLO_VOICE_MUTE" = "1" ]; then
    return 0  # Stumm, kein Output
fi
```

### Multi-Language Support

**Deutsch Voice Model hinzufügen:**

```bash
# Download German voice
cd ~/.local/share/apollo-os/voices
wget https://github.com/rhasspy/piper/releases/download/v1.2.0/de_DE-thorsten-medium.onnx

# Erstelle apollo-speak-de.sh für deutsche Variante
```

---

## 🐛 Troubleshooting

### "Piper TTS not installed"

```bash
# Manuelle Installation
sudo dnf install -y piper-tts

# Oder von Source:
# https://github.com/rhasspy/piper/releases
```

### "LUNA voice model not found"

```bash
# Model manuell downloaden
mkdir -p ~/.local/share/apollo-os/voices
cd ~/.local/share/apollo-os/voices
wget https://github.com/rhasspy/piper/releases/download/v1.2.0/en_GB-jenny_dioco-medium.onnx
wget https://github.com/rhasspy/piper/releases/download/v1.2.0/en_GB-jenny_dioco-medium.onnx.json
mv en_GB-jenny_dioco-medium.onnx luna.onnx
mv en_GB-jenny_dioco-medium.onnx.json luna.onnx.json
```

### Kein Sound wird abgespielt

```bash
# PulseAudio Status prüfen
systemctl --user status pulseaudio

# Lautstärke prüfen
pactl get-sink-volume @DEFAULT_SINK@

# Test mit paplay
paplay /usr/share/sounds/alsa/Front_Center.wav
```

### Sprachausgabe zu langsam/schnell

```bash
# apollo-speak.sh editieren
nano ~/.local/bin/apollo-speak

# Ändere LENGTH_SCALE:
# 0.8 = Schneller
# 1.0 = Normal
# 1.2 = Langsamer (Standard)
# 1.5 = Sehr langsam
```

---

## 📊 Performance

### Cache Statistiken

```bash
# Zeige gecachte Sprachausgaben
ls -lh /tmp/apollo-tts-cache/

# Cache-Größe
du -sh /tmp/apollo-tts-cache/

# Älteste Einträge löschen (automatisch bei Reboot)
find /tmp/apollo-tts-cache/ -mtime +7 -delete
```

### Generierungs-Geschwindigkeit

| Text-Länge | Generierung | Playback |
|------------|-------------|----------|
| 10 Wörter | ~0.5s | ~3s |
| 20 Wörter | ~0.8s | ~6s |
| 50 Wörter | ~1.5s | ~15s |

**Cached:** Instant (nur Playback-Zeit)

---

## 🎤 Verfügbare Voice Models

### Englisch
- **LUNA** (jenny_dioco) - Britisch, Professionell ✅ Standard
- amy - Amerikanisch, Freundlich
- joe - Amerikanisch, Männlich

### Deutsch
- thorsten - Neutral, Klar
- eva_k - Weiblich, Professionell

### Weitere Sprachen
- Französisch, Spanisch, Italienisch, etc.
- Vollständige Liste: https://github.com/rhasspy/piper

**Installation weiterer Voices:**

```bash
cd ~/.local/share/apollo-os/voices
wget https://github.com/rhasspy/piper/releases/download/v1.2.0/<model-name>.onnx
```

---

## 📝 Beispiel-Integration

### Vollständige Boot-Sequenz

**In systemd/apollo-os-boot-voice.service:**

```ini
[Unit]
Description=Apollo OS Boot Voice
After=sound.target graphical.target

[Service]
Type=oneshot
User=%u
ExecStart=/home/%u/.local/bin/apollo-speak boot
RemainAfterExit=yes

[Install]
WantedBy=graphical.target
```

**Aktivieren:**

```bash
systemctl --user enable apollo-os-boot-voice.service
systemctl --user start apollo-os-boot-voice.service
```

---

## 🔄 Deinstallation

Falls du das Audio-System wieder entfernen möchtest:

```bash
# Voice Models löschen
rm -rf ~/.local/share/apollo-os/voices
rm -rf ~/.local/share/apollo-os/sounds

# Script entfernen
rm ~/.local/bin/apollo-speak

# Cache leeren
rm -rf /tmp/apollo-tts-cache

# Pakete deinstallieren (optional)
sudo dnf remove piper-tts
```

---

## 📞 Support

Bei Problemen mit dem Audio-System:

- **GitHub Issues:** apollo-os-dev/issues
- **Logs prüfen:** `journalctl --user -u apollo-os-daemon.service`
- **Audio-Test:** `apollo-speak "Test message"`

---

**Version:** v0.4.1+audio  
**Datum:** 2026-01-12  
**Status:** Optional Feature - Production Ready  
**Maintainer:** Manuel Kraibacher
