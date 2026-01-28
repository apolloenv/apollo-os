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
