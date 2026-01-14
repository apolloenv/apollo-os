#!/bin/bash

#####################################################################
# Apollo OS - Visual Mode Switcher
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Switch between Classic and Modern visual modes
#####################################################################

CONFIG_FILE="$HOME/.config/apollo-os/visual-mode"
NIRI_CONFIG="$HOME/.config/niri/config.kdl"
WAYBAR_CONFIG="$HOME/.config/waybar/config-niri"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"

# Backup configs
NIRI_CLASSIC="$HOME/.config/niri/config-classic.kdl"
NIRI_MODERN="$HOME/.config/niri/config-modern.kdl"
WAYBAR_CONFIG_CLASSIC="$HOME/.config/waybar/config-niri-classic"
WAYBAR_CONFIG_MODERN="$HOME/.config/waybar/config-niri-modern"
WAYBAR_STYLE_CLASSIC="$HOME/.config/waybar/style-classic.css"
WAYBAR_STYLE_MODERN="$HOME/.config/waybar/style-modern.css"

# TTS function
tts_notify() {
    local script="$HOME/.local/bin/apollo-os-tts-notify.sh"
    [ -x "$script" ] && "$script" "$@"
}

# Get current mode
get_current_mode() {
    if [ -f "$CONFIG_FILE" ]; then
        cat "$CONFIG_FILE"
    else
        echo "classic"
    fi
}

# Set mode
set_mode() {
    local mode=$1
    mkdir -p "$(dirname "$CONFIG_FILE")"
    echo "$mode" > "$CONFIG_FILE"
}

# Initialize backups if they don't exist
init_backups() {
    # If classic backups don't exist, current config is classic
    if [ ! -f "$NIRI_CLASSIC" ] && [ -f "$NIRI_CONFIG" ]; then
        cp "$NIRI_CONFIG" "$NIRI_CLASSIC"
    fi
    if [ ! -f "$WAYBAR_CONFIG_CLASSIC" ] && [ -f "$WAYBAR_CONFIG" ]; then
        cp "$WAYBAR_CONFIG" "$WAYBAR_CONFIG_CLASSIC"
    fi
    if [ ! -f "$WAYBAR_STYLE_CLASSIC" ] && [ -f "$WAYBAR_STYLE" ]; then
        cp "$WAYBAR_STYLE" "$WAYBAR_STYLE_CLASSIC"
    fi
    
    # If modern backups don't exist, copy from classic
    if [ ! -f "$NIRI_MODERN" ]; then
        cp "$NIRI_CLASSIC" "$NIRI_MODERN" 2>/dev/null || true
    fi
    if [ ! -f "$WAYBAR_CONFIG_MODERN" ]; then
        cp "$WAYBAR_CONFIG_CLASSIC" "$WAYBAR_CONFIG_MODERN" 2>/dev/null || true
    fi
    if [ ! -f "$WAYBAR_STYLE_MODERN" ]; then
        cp "$WAYBAR_STYLE_CLASSIC" "$WAYBAR_STYLE_MODERN" 2>/dev/null || true
    fi
}

# Switch to mode
switch_to() {
    local mode=$1
    
    if [ "$mode" = "modern" ]; then
        cp "$NIRI_MODERN" "$NIRI_CONFIG"
        cp "$WAYBAR_CONFIG_MODERN" "$WAYBAR_CONFIG"
        cp "$WAYBAR_STYLE_MODERN" "$WAYBAR_STYLE"
    else
        cp "$NIRI_CLASSIC" "$NIRI_CONFIG"
        cp "$WAYBAR_CONFIG_CLASSIC" "$WAYBAR_CONFIG"
        cp "$WAYBAR_STYLE_CLASSIC" "$WAYBAR_STYLE"
    fi
    
    set_mode "$mode"
}

# Reload WM and Waybar
reload_ui() {
    # Reload Waybar
    WPID=$(pgrep -x waybar)
    if [ -n "$WPID" ]; then
        kill $WPID 2>/dev/null
    fi
    sleep 0.5
    waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &
    
    # Reload Niri config
    niri msg action reload-config 2>/dev/null || true
}

# Main
current_mode=$(get_current_mode)
init_backups

if [ "$1" = "toggle" ] || [ -z "$1" ]; then
    # Toggle mode
    if [ "$current_mode" = "classic" ]; then
        switch_to "modern"
        notify-send "Apollo OS" "Visual Mode: Modern"
        tts_notify visual-modern
    else
        switch_to "classic"
        notify-send "Apollo OS" "Visual Mode: Classic"
        tts_notify visual-classic
    fi
    reload_ui
elif [ "$1" = "modern" ]; then
    switch_to "modern"
    notify-send "Apollo OS" "Visual Mode: Modern"
    tts_notify visual-modern
    reload_ui
elif [ "$1" = "classic" ]; then
    switch_to "classic"
    notify-send "Apollo OS" "Visual Mode: Classic"
    tts_notify visual-classic
    reload_ui
elif [ "$1" = "status" ]; then
    echo "$current_mode"
fi
