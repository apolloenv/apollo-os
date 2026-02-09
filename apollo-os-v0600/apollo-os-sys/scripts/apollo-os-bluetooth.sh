#!/bin/bash

#####################################################################
# Apollo OS - Bluetooth Manager (TUI)
# Inspired by Omarchy, adapted for Fedora + Niri
#
# Description: Launches bluetui in a floating terminal window.
#              Unblocks bluetooth if rfkill-blocked.
# Keybinding: Super+Ctrl+B
# Requires: bluetui, alacritty
#####################################################################

# Unblock bluetooth if blocked
rfkill unblock bluetooth 2>/dev/null

# Check if bluetui is installed
if ! command -v bluetui &>/dev/null; then
    notify-send "Apollo OS" "bluetui wird installiert..." -t 3000
    cargo install bluetui 2>/dev/null || {
        notify-send "Apollo OS" "❌ bluetui Installation fehlgeschlagen.\nInstalliere mit: cargo install bluetui" -u critical
        exit 1
    }
fi

# Check if already running, focus if so
if pgrep -f "bluetui" >/dev/null 2>&1; then
    # Try to focus existing window via niri
    niri msg action focus-window --id "$(niri msg windows 2>/dev/null | grep -i 'bluetui' | head -1 | awk '{print $1}')" 2>/dev/null
    exit 0
fi

# Launch in floating terminal
alacritty --class "apollo-bluetooth" --title "Bluetooth Manager" -e bluetui &
disown
