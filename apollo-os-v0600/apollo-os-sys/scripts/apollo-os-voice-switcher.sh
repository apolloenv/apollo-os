#!/bin/bash
#####################################################################
# Apollo OS Voice Switcher - Amala Only
# Copyright © 2025 by Manuel Kraibacher
#####################################################################

# Info-only - Amala is the fixed voice
notify-send "Apollo OS TTS" "Aktive Stimme: Amala (Deutsch)\nEngine: edge-tts" 2>/dev/null

# Play sample
~/.local/bin/apollo-os-voice-sample.sh 2>/dev/null
