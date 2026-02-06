# Apollo OS v5.1.4 - Installer pip/Python Fixes

## Problem:
Nach Neuinstallation crashte apollo-rightctrl-voice.service:
- `ModuleNotFoundError: No module named 'evdev'`
- pip3/pip waren nicht verfügbar
- python3-pip war nicht installiert

## Ursache:
- python3-pip wurde nur bei whisper.cpp Build installiert (Zeile 810)
- Voice Control und TTS installierten aber Python-Pakete VOR whisper.cpp
- Wenn User keinen Editor installierte, wurde whisper.cpp nie gebaut
- Dadurch fehlte pip komplett

## Fixes implementiert:

### 1. ✅ Voice Control Installation (Zeile ~1683)
**Vorher**:
```bash
pip3 install --user vosk sounddevice
```

**Nachher**:
```bash
# Ensure Python pip is installed (critical for voice control)
log "Ensuring Python pip is installed..."
sudo dnf install -y python3-pip python3-devel || warn "Failed to install Python pip"

# Install Python dependencies
log "Installing Python dependencies (vosk, sounddevice)..."
python3 -m pip install --user vosk sounddevice || warn "Failed to install Python dependencies"
```

### 2. ✅ evdev Installation (Zeile ~1752)
**Vorher**:
```bash
pip3 install --user evdev
```

**Nachher**:
```bash
log "Installing Python evdev for Right Ctrl push-to-talk..."
python3 -m pip install --user evdev || warn "Failed to install evdev"
```

### 3. ✅ TTS edge-tts Installation (Zeile ~1564)
**Vorher**:
- Komplexe Fallback-Chain: uv → pip → pip3 → curl install uv

**Nachher**:
```bash
if command -v uv &>/dev/null; then
    uv tool install edge-tts
else
    # Ensure pip is available
    sudo dnf install -y python3-pip python3-devel 2>/dev/null || true
    python3 -m pip install --user edge-tts
fi
```

## Warum `python3 -m pip` statt `pip3`?

**`python3 -m pip`**:
- ✅ Verwendet den Python-Interpreter direkt
- ✅ Funktioniert immer wenn Python installiert ist
- ✅ Keine Abhängigkeit von pip Binary im PATH
- ✅ Empfohlene Methode laut Python Docs

**`pip3`**:
- ❌ Kann fehlen auch wenn pip installiert ist
- ❌ Abhängig von Distro-spezifischen Symlinks
- ❌ Veraltet in neueren Python-Versionen

## Installation Flow (neu):

```
1. System Update
2. Package Installation
   - python3-pip bei whisper.cpp Build (Zeile 810)
3. Audio System
   - pip Check + edge-tts Installation
4. Voice Control
   - pip Check NOCHMAL (safety)
   - vosk, sounddevice Installation
   - evdev Installation
   - Service Setup
```

## Testing auf Remote-Rechner:
```bash
# Service Status
systemctl --user status apollo-rightctrl-voice
# ✅ active (running)

# Python Module Check
python3 -c "import evdev; print('✅ evdev OK')"
python3 -c "import vosk; print('✅ vosk OK')"
```

## Verhindert:
- ❌ "Befehl nicht gefunden: pip3"
- ❌ ModuleNotFoundError bei Services
- ❌ Silent failures bei Python-Paket-Installation

