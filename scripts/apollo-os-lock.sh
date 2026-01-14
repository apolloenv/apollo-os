#!/bin/bash
#####################################################################
# Apollo OS - Lock Screen with TTS
# Copyright © 2026 by Manuel Kraibacher
#####################################################################

# Play lock sound
~/.local/bin/apollo-os-lock-tts.sh lock &

# Wait briefly for TTS to start
sleep 0.5

# Lock screen
swaylock -i /usr/share/backgrounds/apollo-login.jpg

# After unlock, play unlock sound
~/.local/bin/apollo-os-lock-tts.sh unlock &
