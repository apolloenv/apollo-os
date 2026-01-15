#!/bin/bash
#####################################################################
# Apollo OS - Lock/Unlock TTS
# Copyright © 2026 by Manuel Kraibacher
# 
# This is a wrapper that calls the central TTS notify script
#####################################################################

ACTION=$1
TTS_SCRIPT="$HOME/.local/bin/apollo-os-tts-notify.sh"

case "$ACTION" in
    lock)
        [ -x "$TTS_SCRIPT" ] && "$TTS_SCRIPT" lock
        ;;
    unlock)
        [ -x "$TTS_SCRIPT" ] && "$TTS_SCRIPT" unlock
        ;;
    *)
        exit 0
        ;;
esac
