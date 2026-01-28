#!/bin/bash
# Apollo OS Reboot with TTS
# Copyright 2025 by Manuel Kraibacher

TTS_SCRIPT="$HOME/.local/bin/apollo-os-tts-notify.sh"

# Play TTS announcement
[ -x "$TTS_SCRIPT" ] && "$TTS_SCRIPT" reboot

# Small delay to ensure audio completes
sleep 1

# Reboot
systemctl reboot
