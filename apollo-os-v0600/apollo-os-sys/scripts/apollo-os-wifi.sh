#!/bin/bash

#####################################################################
# Apollo OS - WiFi Manager (TUI)
# Inspired by Omarchy, adapted for Fedora + Niri
#
# Description: Launches impala WiFi TUI in a floating terminal.
#              Unblocks wifi if rfkill-blocked.
# Keybinding: Super+Ctrl+W
# Requires: impala, alacritty
#####################################################################

# Unblock wifi if blocked
rfkill unblock wifi 2>/dev/null

# Check if impala is installed
if ! command -v impala &>/dev/null; then
    notify-send "Apollo OS" "impala wird installiert..." -t 3000
    cargo install impala 2>/dev/null || {
        notify-send "Apollo OS" "❌ impala Installation fehlgeschlagen.\nInstalliere mit: cargo install impala" -u critical
        exit 1
    }
fi

# Check if already running, focus if so
if pgrep -f "impala" >/dev/null 2>&1; then
    niri msg action focus-window --id "$(niri msg windows 2>/dev/null | grep -i 'impala' | head -1 | awk '{print $1}')" 2>/dev/null
    exit 0
fi

# Launch in floating terminal
alacritty --class "apollo-wifi" --title "WiFi Manager" -e impala &
disown
