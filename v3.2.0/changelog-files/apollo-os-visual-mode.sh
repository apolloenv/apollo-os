#!/bin/bash

#####################################################################
# Apollo OS - Visual Mode Switcher v1.0.2
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Switch between visual modes (Classic, Developer, Enterprise, Minimal, Modern, Nova, Orbit, Professional)
#####################################################################

CONFIG_FILE="$HOME/.config/apollo-os/visual-mode"
NIRI_CONFIG="$HOME/.config/niri/config.kdl"
WAYBAR_CONFIG="$HOME/.config/waybar/config-niri"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"

# All available mode configs
declare -A NIRI_CONFIGS=(
    ["classic"]="$HOME/.config/niri/config-classic.kdl"
    ["developer"]="$HOME/.config/niri/config-developer.kdl"
    ["enterprise"]="$HOME/.config/niri/config-enterprise.kdl"
    ["i3"]="$HOME/.config/niri/config-i3.kdl"
    ["i3-retro"]="$HOME/.config/niri/config-i3-retro.kdl"
    ["i3-contrast"]="$HOME/.config/niri/config-i3-contrast.kdl"
    ["minimal"]="$HOME/.config/niri/config-minimal.kdl"
    ["modern"]="$HOME/.config/niri/config-modern.kdl"
    ["nova"]="$HOME/.config/niri/config-nova.kdl"
    ["orbit"]="$HOME/.config/niri/config-orbit.kdl"
    ["professional"]="$HOME/.config/niri/config-professional.kdl"
    ["sgi"]="$HOME/.config/niri/config-sgi.kdl"
    ["tech-blue"]="$HOME/.config/niri/config-tech-blue.kdl"
)

declare -A WAYBAR_CONFIGS=(
    ["classic"]="$HOME/.config/waybar/config-niri-classic"
    ["developer"]="$HOME/.config/waybar/config-niri-developer"
    ["enterprise"]="$HOME/.config/waybar/config-niri-enterprise"
    ["i3"]="$HOME/.config/waybar/config-niri-i3"
    ["i3-retro"]="$HOME/.config/waybar/config-niri-i3-retro"
    ["i3-contrast"]="$HOME/.config/waybar/config-niri-i3-contrast"
    ["minimal"]="$HOME/.config/waybar/config-niri-minimal"
    ["modern"]="$HOME/.config/waybar/config-niri-modern"
    ["nova"]="$HOME/.config/waybar/config-niri-nova"
    ["orbit"]="$HOME/.config/waybar/config-niri-orbit"
    ["professional"]="$HOME/.config/waybar/config-niri-professional"
    ["sgi"]="$HOME/.config/waybar/config-niri-sgi"
    ["tech-blue"]="$HOME/.config/waybar/config-niri-tech-blue"
)

declare -A WAYBAR_STYLES=(
    ["classic"]="$HOME/.config/waybar/style-classic.css"
    ["developer"]="$HOME/.config/waybar/style-developer.css"
    ["enterprise"]="$HOME/.config/waybar/style-enterprise.css"
    ["i3"]="$HOME/.config/waybar/style-i3.css"
    ["i3-retro"]="$HOME/.config/waybar/style-i3-retro.css"
    ["i3-contrast"]="$HOME/.config/waybar/style-i3-contrast.css"
    ["minimal"]="$HOME/.config/waybar/style-minimal.css"
    ["modern"]="$HOME/.config/waybar/style-modern.css"
    ["nova"]="$HOME/.config/waybar/style-nova.css"
    ["orbit"]="$HOME/.config/waybar/style-orbit.css"
    ["professional"]="$HOME/.config/waybar/style-professional.css"
    ["sgi"]="$HOME/.config/waybar/style-sgi.css"
    ["tech-blue"]="$HOME/.config/waybar/style-tech-blue.css"
)

# TTS function
tts_notify() {
    local script="$HOME/.local/bin/apollo-os-tts-notify.sh"
    [ -x "$script" ] && "$script" "$@"
}

# Screen corners control
SCREEN_CORNERS_SCRIPT="$HOME/screen-corners/screen-corners.py"

manage_screen_corners() {
    local mode=$1

    if [ "$mode" = "minimal" ] || [ "$mode" = "enterprise" ] || [ "$mode" = "tech-blue" ] || [ "$mode" = "i3" ] || [ "$mode" = "i3-retro" ] || [ "$mode" = "i3-contrast" ] || [ "$mode" = "sgi" ]; then
        # Stop screen-corners for minimal/enterprise/tech-blue/i3/sgi modes
        pkill -f "screen-corners.py" 2>/dev/null || true
    else
        # Start screen-corners for other modes (if not already running)
        if ! pgrep -f "screen-corners.py" >/dev/null && [ -f "$SCREEN_CORNERS_SCRIPT" ]; then
            python3 "$SCREEN_CORNERS_SCRIPT" &
        fi
    fi
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
        echo "Available modes: classic, developer, enterprise, i3, i3-retro, minimal, modern, nova, orbit, professional, sgi"
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
    local mode=$(get_current_mode)

    # Manage screen corners based on mode
    manage_screen_corners "$mode"

    # Reload Waybar
    WPID=$(pgrep -x waybar)
    if [ -n "$WPID" ]; then
        kill $WPID 2>/dev/null
    fi
    sleep 0.5
    waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &

    # Reload Niri config
    niri msg action load-config-file 2>/dev/null || true
}

# Main
current_mode=$(get_current_mode)

if [ "$1" = "status" ]; then
    echo "$current_mode"
    exit 0
fi

if [ "$1" = "toggle" ] || [ -z "$1" ]; then
    # Toggle between modes (classic -> developer -> enterprise -> i3 -> minimal -> modern -> nova -> orbit -> professional -> classic)
    case "$current_mode" in
        classic)
            new_mode="developer"
            ;;
        developer)
            new_mode="enterprise"
            ;;
        enterprise)
            new_mode="i3"
            ;;
        i3)
            new_mode="i3-retro"
            ;;
        i3-retro)
            new_mode="minimal"
            ;;
        minimal)
            new_mode="modern"
            ;;
        modern)
            new_mode="nova"
            ;;
        nova)
            new_mode="orbit"
            ;;
        orbit)
            new_mode="professional"
            ;;
        professional)
            new_mode="sgi"
            ;;
        sgi)
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
    echo "Usage: $0 [classic|developer|enterprise|i3|i3-retro|minimal|modern|nova|orbit|professional|sgi|toggle|status]"
    echo "Current mode: $current_mode"
    exit 1
fi
