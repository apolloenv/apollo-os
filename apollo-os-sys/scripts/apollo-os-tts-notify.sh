#!/bin/bash
#####################################################################
# Apollo OS TTS Notification System - Amala Voice
# Copyright 2025 by Manuel Kraibacher
#
# Uses edge-tts with Amala voice (German)
#####################################################################

# Ensure PipeWire/PulseAudio can be reached
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Fixed voice: Amala (German)
VOICE_MODEL="de-DE-AmalaNeural"

# Find edge-tts
EDGE_TTS=""
for p in "$HOME/.local/bin/edge-tts" "/usr/local/bin/edge-tts" "/usr/bin/edge-tts"; do
    [ -x "$p" ] && EDGE_TTS="$p" && break
done

# TTS function - Amala only
speak() {
    local text="$1"
    local tmpfile="/tmp/apollo-tts-$$.mp3"
    
    if [ -z "$EDGE_TTS" ]; then
        return 1
    fi
    
    "$EDGE_TTS" -t "$text" -v "$VOICE_MODEL" --write-media "$tmpfile" 2>/dev/null
    
    if [ -f "$tmpfile" ]; then
        pw-play "$tmpfile" 2>/dev/null || paplay "$tmpfile" 2>/dev/null || mpg123 -q "$tmpfile" 2>/dev/null
        rm -f "$tmpfile"
    fi
}

# Event type from argument
EVENT="$1"

case "$EVENT" in
    # Network events
    wifi-connected)
        speak "Netzwerkverbindung etabliert. Apollo OS Datenlink aktiv."
        ;;
    wifi-disconnected)
        speak "Verbindung getrennt. Apollo OS im Offline-Modus."
        ;;
    vpn-connected)
        speak "Verschlüsselter Tunnel aktiv. Apollo OS Tarnmodus eingeschaltet."
        ;;
    vpn-disconnected)
        speak "VPN-Verbindung beendet. Apollo OS Standardnetzwerk aktiv."
        ;;
    
    # Power events
    power-connected)
        speak "Energieversorgung aktiv. Apollo OS Ladeprotokoll gestartet."
        ;;
    power-disconnected)
        speak "Batteriemodus aktiv. Apollo OS optimiert Ressourcen."
        ;;
    battery-low)
        speak "Warnung. Apollo OS Energiereserven kritisch. Stromversorgung erforderlich."
        ;;
    battery-full)
        speak "Apollo OS Energiespeicher vollständig aufgeladen. Maximale Kapazität erreicht."
        ;;
    
    # Performance modes
    power-saver)
        speak "Apollo OS Energiesparmodus aktiviert. Ressourcen werden optimiert."
        ;;
    balanced)
        speak "Apollo OS Balance-Modus aktiviert. Leistung und Effizienz optimiert."
        ;;
    performance)
        speak "Apollo OS Leistungsmodus aktiviert. Maximale Systemleistung freigegeben."
        ;;
    
    # Bluetooth
    bluetooth-connected)
        speak "Bluetooth-Gerät gekoppelt. Apollo OS Peripherie erweitert."
        ;;
    bluetooth-disconnected)
        speak "Bluetooth-Gerät getrennt. Verbindung deaktiviert."
        ;;
    
    # USB/Storage
    usb-connected)
        speak "Externes Modul erkannt. Apollo OS Schnittstelle aktiviert."
        ;;
    usb-removed)
        speak "Externes Modul sicher entfernt."
        ;;
    
    # System events
    screenshot)
        speak "Bildschirmaufnahme gespeichert."
        ;;
    shutdown)
        speak "Apollo OS Abschaltsequenz eingeleitet. Alle Prozesse werden gesichert. Auf Wiedersehen."
        ;;
    reboot)
        speak "Apollo OS Systemneustart initialisiert. System Core wird neu geladen."
        ;;
    lock)
        speak "Apollo OS System Core verschlüsselt und gesichert."
        ;;
    unlock)
        speak "Identität bestätigt. System freigegeben. Apollo OS Systeme online."
        ;;
    
    # Sleep/Suspend events
    sleep)
        speak "Apollo OS Kryoschlaf eingeleitet. System Core versiegelt. Datenkern ist verschlüsselt und geschützt."
        ;;
    wake)
        speak "Apollo OS Reaktivierungssequenz gestartet. System Core entsiegelt. Datenkern ist hochgefahren. Integrität aller Systeme bestätigt. System ist einsatzbereit."
        ;;
    
    # Audio
    muted)
        speak "Audio deaktiviert."
        ;;
    unmuted)
        speak "Audio reaktiviert."
        ;;
    
    # Visual modes
    visual-classic)
        speak "Interface geladen."
        ;;
    visual-developer)
        speak "Interface geladen."
        ;;
    visual-modern)
        speak "Interface geladen."
        ;;
    visual-orbit)
        speak "Interface geladen."
        ;;
    visual-professional)
        speak "Interface geladen."
        ;;
    visual-tech-blue)
        speak "Interface geladen."
        ;;
    
    *)
        # Unknown event - speak as-is if not empty
        [ -n "$EVENT" ] && speak "$EVENT"
        ;;
esac
