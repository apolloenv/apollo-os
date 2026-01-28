#!/bin/bash
# Apollo OS Shutdown with TTS
# Copyright 2025 by Manuel Kraibacher

TTS_SCRIPT="$HOME/.local/bin/apollo-os-tts-notify.sh"

# Play TTS announcement
[ -x "$TTS_SCRIPT" ] && "$TTS_SCRIPT" shutdown

# Small delay to ensure audio completes
sleep 1

# Shutdown
systemctl poweroff
