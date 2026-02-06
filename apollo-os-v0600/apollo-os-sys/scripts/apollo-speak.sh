#!/bin/bash
#####################################################################
# Apollo OS - Voice System (TTS) - Amala Voice
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Text-to-Speech using edge-tts with Amala voice
#####################################################################

# Ensure environment is set for Wayland/PulseAudio
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Fixed voice: Amala (German)
VOICE_MODEL="de-DE-AmalaNeural"

# Find edge-tts
EDGE_TTS=""
for p in "$HOME/.local/bin/edge-tts" "/usr/local/bin/edge-tts" "/usr/bin/edge-tts"; do
    [ -x "$p" ] && EDGE_TTS="$p" && break
done

#####################################################################
# German Messages (Amala speaks German)
#####################################################################

declare -A MESSAGES=(
    ["boot"]="Apollo OS System Core gestartet. Alle Module initialisiert. Diagnose abgeschlossen. Bereit für Einsatz."
    ["welcome"]="Zugriff autorisiert. Apollo OS Systeme online."
    ["lock"]="Apollo OS System Core verschlüsselt und gesichert."
    ["unlock"]="Identität bestätigt. System freigegeben. Apollo OS Systeme online."
    ["shutdown"]="Apollo OS Abschaltsequenz eingeleitet. Alle Prozesse werden gesichert. Auf Wiedersehen."
    ["reboot"]="Apollo OS Systemneustart initialisiert. System Core wird neu geladen."
    ["battery_low"]="Warnung. Apollo OS Energiereserven kritisch. Stromversorgung erforderlich."
    ["battery_critical"]="Warnung. Energiereserven auf kritischem Niveau. Sofortige Aufladung erforderlich."
    ["uplink_ready"]="Netzwerkverbindung etabliert. Apollo OS Datenlink aktiv."
    ["uplink_lost"]="Verbindung getrennt. Apollo OS im Offline-Modus."
    ["error"]="Ein Systemfehler ist aufgetreten."
    ["success"]="Vorgang erfolgreich abgeschlossen."
)

#####################################################################
# TTS Function - Amala (edge-tts)
#####################################################################

speak() {
    local text="$1"
    local tmpfile="/tmp/apollo-tts-$$.mp3"
    
    # Check if edge-tts is available
    if [ -z "$EDGE_TTS" ]; then
        return 1
    fi
    
    # Generate TTS
    "$EDGE_TTS" -t "$text" -v "$VOICE_MODEL" --write-media "$tmpfile" 2>/dev/null
    
    # Play audio
    if [ -f "$tmpfile" ]; then
        pw-play "$tmpfile" 2>/dev/null || paplay "$tmpfile" 2>/dev/null || mpg123 -q "$tmpfile" 2>/dev/null
        rm -f "$tmpfile"
    fi
}

#####################################################################
# Main
#####################################################################

# Check for stdin input
if [[ "$1" == "-" ]]; then
    while IFS= read -r line; do
        speak "$line"
    done
    exit 0
fi

if [[ $# -eq 0 ]]; then
    echo "Verwendung: apollo-speak <nachricht|text>"
    echo "           echo 'text' | apollo-speak -"
    echo "Vordefiniert: boot, welcome, lock, unlock, shutdown, reboot, battery_low, battery_critical, uplink_ready, uplink_lost, error, success"
    echo ""
    echo "Stimme: Amala (Deutsch)"
    echo "Engine: edge-tts"
    exit 0
fi

MSG="$1"

# Check for predefined message
if [[ -n "${MESSAGES[$MSG]}" ]]; then
    speak "${MESSAGES[$MSG]}"
else
    speak "$MSG"
fi
