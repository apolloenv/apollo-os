#!/bin/bash

#####################################################################
# Apollo OS - Color Picker
# Inspired by Omarchy, adapted for Fedora + Niri
#
# Description: Pick a color from anywhere on screen.
#              Copies hex color to clipboard and shows notification.
# Keybinding: Super+Print
# Requires: hyprpicker, wl-copy
#####################################################################

# Check if hyprpicker is installed
if ! command -v hyprpicker &>/dev/null; then
    notify-send "Apollo OS" "❌ hyprpicker nicht installiert!\nInstalliere mit: sudo dnf install hyprpicker" -u critical
    exit 1
fi

# Cancel if already running
if pgrep -x hyprpicker >/dev/null 2>&1; then
    exit 0
fi

# Pick color (auto-copies to clipboard with -a)
COLOR=$(hyprpicker -a --no-fancy 2>/dev/null) || exit 0

if [ -n "$COLOR" ]; then
    notify-send "🎨 Color Picker" "Farbe: $COLOR\n→ In Zwischenablage kopiert" -t 3000
fi
