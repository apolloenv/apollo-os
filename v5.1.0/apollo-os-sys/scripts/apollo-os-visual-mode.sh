#!/bin/bash

#####################################################################
# Apollo OS - Visual Mode Switcher v1.0.2
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Switch between visual modes (Classic, Developer, Modern, Orbit, Professional)
#####################################################################

CONFIG_FILE="$HOME/.config/apollo-os/visual-mode"
NIRI_CONFIG="$HOME/.config/niri/config.kdl"
WAYBAR_CONFIG="$HOME/.config/waybar/config-niri"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"

# All available mode configs
declare -A NIRI_CONFIGS=(
    ["classic"]="$HOME/.config/niri/config-classic.kdl"
    ["developer"]="$HOME/.config/niri/config-developer.kdl"
    ["modern"]="$HOME/.config/niri/config-modern.kdl"
    ["orbit"]="$HOME/.config/niri/config-orbit.kdl"
    ["professional"]="$HOME/.config/niri/config-professional.kdl"
    ["tech-blue"]="$HOME/.config/niri/config-tech-blue.kdl"
)

declare -A WAYBAR_CONFIGS=(
    ["classic"]="$HOME/.config/waybar/config-niri-classic"
    ["developer"]="$HOME/.config/waybar/config-niri-developer"
    ["modern"]="$HOME/.config/waybar/config-niri-modern"
    ["orbit"]="$HOME/.config/waybar/config-niri-orbit"
    ["professional"]="$HOME/.config/waybar/config-niri-professional"
    ["tech-blue"]="$HOME/.config/waybar/config-niri-tech-blue"
)

declare -A WAYBAR_STYLES=(
    ["classic"]="$HOME/.config/waybar/style-classic.css"
    ["developer"]="$HOME/.config/waybar/style-developer.css"
    ["modern"]="$HOME/.config/waybar/style-modern.css"
    ["orbit"]="$HOME/.config/waybar/style-orbit.css"
    ["professional"]="$HOME/.config/waybar/style-professional.css"
    ["tech-blue"]="$HOME/.config/waybar/style-tech-blue.css"
)

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

# Validate mode
is_valid_mode() {
    local mode=$1
    [[ -n "${NIRI_CONFIGS[$mode]}" ]]
}

# Switch to mode
switch_to() {
    local mode=$1

    # Validate mode
    if ! is_valid_mode "$mode"; then
        echo "Invalid mode: $mode"
        echo "Available modes: classic, developer, modern, orbit, professional"
        return 1
    fi

    # Check if config files exist
    if [ ! -f "${NIRI_CONFIGS[$mode]}" ]; then
        echo "Config not found: ${NIRI_CONFIGS[$mode]}"
        return 1
    fi

    # Copy configs
    cp "${NIRI_CONFIGS[$mode]}" "$NIRI_CONFIG"
    cp "${WAYBAR_CONFIGS[$mode]}" "$WAYBAR_CONFIG"
    cp "${WAYBAR_STYLES[$mode]}" "$WAYBAR_STYLE"

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

if [ "$1" = "status" ]; then
    echo "$current_mode"
    exit 0
fi

if [ "$1" = "toggle" ] || [ -z "$1" ]; then
    # Toggle between modes (classic -> developer -> modern -> orbit -> professional -> tech-blue -> classic)
    case "$current_mode" in
        classic)
            new_mode="developer"
            ;;
        developer)
            new_mode="modern"
            ;;
        modern)
            new_mode="orbit"
            ;;
        orbit)
            new_mode="professional"
            ;;
        professional)
            new_mode="tech-blue"
            ;;
        tech-blue)
            new_mode="classic"
            ;;
        *)
            new_mode="classic"
            ;;
    esac

    switch_to "$new_mode"
    notify-send "Apollo OS" "Visual Mode: ${new_mode^}"
    tts_notify "visual-$new_mode"
    reload_ui
    exit 0
fi

# Direct mode selection
if is_valid_mode "$1"; then
    switch_to "$1"
    notify-send "Apollo OS" "Visual Mode: ${1^}"
    tts_notify "visual-$1"
    reload_ui
else
    echo "Usage: $0 [classic|developer|modern|orbit|professional|tech-blue|toggle|status]"
    echo "Current mode: $current_mode"
    exit 1
fi
