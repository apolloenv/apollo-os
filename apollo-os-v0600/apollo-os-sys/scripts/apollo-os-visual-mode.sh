#!/bin/bash

#####################################################################
# Apollo OS - Visual Mode Switcher v2.0.0
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Switch between visual modes with creative design names
#####################################################################

CONFIG_FILE="$HOME/.config/apollo-os/visual-mode"
NIRI_CONFIG="$HOME/.config/niri/config.kdl"
WAYBAR_CONFIG="$HOME/.config/waybar/config-niri"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"

declare -A NIRI_CONFIGS=(
    ["apollo-core"]="$HOME/.config/niri/config-apollo-core.kdl"
    ["code-forge"]="$HOME/.config/niri/config-code-forge.kdl"
    ["command-center"]="$HOME/.config/niri/config-command-center.kdl"
    ["pixel-grid"]="$HOME/.config/niri/config-pixel-grid.kdl"
    ["retro-wave"]="$HOME/.config/niri/config-retro-wave.kdl"
    ["neon-edge"]="$HOME/.config/niri/config-neon-edge.kdl"
    ["zen-flow"]="$HOME/.config/niri/config-zen-flow.kdl"
    ["nova-pulse"]="$HOME/.config/niri/config-nova-pulse.kdl"
    ["star-deck"]="$HOME/.config/niri/config-star-deck.kdl"
    ["deep-space"]="$HOME/.config/niri/config-deep-space.kdl"
    ["command-deck"]="$HOME/.config/niri/config-command-deck.kdl"
    ["command-deck-clean"]="$HOME/.config/niri/config-command-deck-clean.kdl"
    ["light-bridge"]="$HOME/.config/niri/config-light-bridge.kdl"
    ["cyber-matrix"]="$HOME/.config/niri/config-cyber-matrix.kdl"
    ["quantum-flux"]="$HOME/.config/niri/config-quantum-flux.kdl"
    ["silicon-dawn"]="$HOME/.config/niri/config-silicon-dawn.kdl"
    ["frost-byte"]="$HOME/.config/niri/config-frost-byte.kdl"
    ["crystal-bay"]="$HOME/.config/niri/config-crystal-bay.kdl"
)

declare -A WAYBAR_CONFIGS=(
    ["apollo-core"]="$HOME/.config/waybar/config-niri-apollo-core"
    ["code-forge"]="$HOME/.config/waybar/config-niri-code-forge"
    ["command-center"]="$HOME/.config/waybar/config-niri-command-center"
    ["pixel-grid"]="$HOME/.config/waybar/config-niri-pixel-grid"
    ["retro-wave"]="$HOME/.config/waybar/config-niri-retro-wave"
    ["neon-edge"]="$HOME/.config/waybar/config-niri-neon-edge"
    ["zen-flow"]="$HOME/.config/waybar/config-niri-zen-flow"
    ["nova-pulse"]="$HOME/.config/waybar/config-niri-nova-pulse"
    ["star-deck"]="$HOME/.config/waybar/config-niri-star-deck"
    ["deep-space"]="$HOME/.config/waybar/config-niri-deep-space"
    ["command-deck"]="$HOME/.config/waybar/config-niri-command-deck"
    ["command-deck-clean"]="$HOME/.config/waybar/config-niri-command-deck-clean"
    ["light-bridge"]="$HOME/.config/waybar/config-niri-light-bridge"
    ["cyber-matrix"]="$HOME/.config/waybar/config-niri-cyber-matrix"
    ["quantum-flux"]="$HOME/.config/waybar/config-niri-quantum-flux"
    ["silicon-dawn"]="$HOME/.config/waybar/config-niri-silicon-dawn"
    ["frost-byte"]="$HOME/.config/waybar/config-niri-frost-byte"
    ["crystal-bay"]="$HOME/.config/waybar/config-niri-crystal-bay"
)

declare -A WAYBAR_STYLES=(
    ["apollo-core"]="$HOME/.config/waybar/style-apollo-core.css"
    ["code-forge"]="$HOME/.config/waybar/style-code-forge.css"
    ["command-center"]="$HOME/.config/waybar/style-command-center.css"
    ["pixel-grid"]="$HOME/.config/waybar/style-pixel-grid.css"
    ["retro-wave"]="$HOME/.config/waybar/style-retro-wave.css"
    ["neon-edge"]="$HOME/.config/waybar/style-neon-edge.css"
    ["zen-flow"]="$HOME/.config/waybar/style-zen-flow.css"
    ["nova-pulse"]="$HOME/.config/waybar/style-nova-pulse.css"
    ["star-deck"]="$HOME/.config/waybar/style-star-deck.css"
    ["deep-space"]="$HOME/.config/waybar/style-deep-space.css"
    ["command-deck"]="$HOME/.config/waybar/style-command-deck.css"
    ["command-deck-clean"]="$HOME/.config/waybar/style-command-deck-clean.css"
    ["light-bridge"]="$HOME/.config/waybar/style-light-bridge.css"
    ["cyber-matrix"]="$HOME/.config/waybar/style-cyber-matrix.css"
    ["quantum-flux"]="$HOME/.config/waybar/style-quantum-flux.css"
    ["silicon-dawn"]="$HOME/.config/waybar/style-silicon-dawn.css"
    ["frost-byte"]="$HOME/.config/waybar/style-frost-byte.css"
    ["crystal-bay"]="$HOME/.config/waybar/style-crystal-bay.css"
)

declare -A DISPLAY_NAMES=(
    ["apollo-core"]="Apollo Core"
    ["code-forge"]="Code Forge"
    ["command-center"]="Command Center"
    ["pixel-grid"]="Pixel Grid"
    ["retro-wave"]="Retro Wave"
    ["neon-edge"]="Neon Edge"
    ["zen-flow"]="Zen Flow"
    ["nova-pulse"]="Nova Pulse"
    ["star-deck"]="Star Deck"
    ["deep-space"]="Deep Space"
    ["command-deck"]="Command Deck"
    ["command-deck-clean"]="Command Deck Clean"
    ["light-bridge"]="Light Bridge"
    ["cyber-matrix"]="Cyber Matrix"
    ["quantum-flux"]="Quantum Flux"
    ["silicon-dawn"]="Silicon Dawn"
    ["frost-byte"]="Frost Byte"
    ["crystal-bay"]="Crystal Bay"
)

tts_notify() {
    local script="$HOME/.local/bin/apollo-os-tts-notify.sh"
    [ -x "$script" ] && "$script" "$@"
}

SCREEN_CORNERS_SCRIPT="$HOME/.local/bin/screen-corners.py"
DOCK_CONFIG="$HOME/.config/waybar/config-niri-crystal-bay-dock"
DOCK_STYLE="$HOME/.config/waybar/style-crystal-bay-dock.css"
DOCK_PIDFILE="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/apollo-os-dock.pid"

manage_screen_corners() {
    local mode=$1
    case "$mode" in
        zen-flow|command-center|frost-byte|pixel-grid|retro-wave|neon-edge|light-bridge|cyber-matrix|quantum-flux|silicon-dawn)
            pids=$(pgrep -f "screen-corners.py" 2>/dev/null)
            [ -n "$pids" ] && echo "$pids" | xargs -r kill 2>/dev/null || true
            ;;
        *)
            if ! pgrep -f "screen-corners.py" >/dev/null && [ -f "$SCREEN_CORNERS_SCRIPT" ]; then
                python3 "$SCREEN_CORNERS_SCRIPT" >/dev/null 2>&1 &
                disown
            fi
            ;;
    esac
}

manage_dock() {
    local mode=$1
    if [ "$mode" = "crystal-bay" ]; then
        if [ -f "$DOCK_PIDFILE" ]; then
            local pid=$(cat "$DOCK_PIDFILE")
            if ! kill -0 "$pid" 2>/dev/null; then
                waybar -c "$DOCK_CONFIG" -s "$DOCK_STYLE" >/dev/null 2>&1 &
                echo $! > "$DOCK_PIDFILE"
                disown
            fi
        else
            waybar -c "$DOCK_CONFIG" -s "$DOCK_STYLE" >/dev/null 2>&1 &
            echo $! > "$DOCK_PIDFILE"
            disown
        fi
    else
        if [ -f "$DOCK_PIDFILE" ]; then
            local pid=$(cat "$DOCK_PIDFILE")
            kill "$pid" 2>/dev/null
            rm -f "$DOCK_PIDFILE"
        fi
    fi
}

manage_mako() {
    local mode=$1
    local mako_config="$HOME/.config/mako/config"
    if [ "$mode" = "crystal-bay" ]; then
        [ -f "$HOME/.config/mako/config-crystal-bay" ] && cp "$HOME/.config/mako/config-crystal-bay" "$mako_config"
    else
        [ -f "$HOME/.config/mako/config-default" ] && cp "$HOME/.config/mako/config-default" "$mako_config"
    fi
    local mpids=$(pgrep -x mako 2>/dev/null)
    [ -n "$mpids" ] && echo "$mpids" | xargs -r kill 2>/dev/null || true
    sleep 0.2
    mako --config "$mako_config" >/dev/null 2>&1 &
    disown
}

get_current_mode() {
    [ -f "$CONFIG_FILE" ] && cat "$CONFIG_FILE" || echo "apollo-core"
}

set_mode() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    echo "$1" > "$CONFIG_FILE"
}

is_valid_mode() { [[ -n "${NIRI_CONFIGS[$1]}" ]]; }

switch_to() {
    local mode=$1
    if ! is_valid_mode "$mode"; then
        echo "Invalid mode: $mode"
        echo "Available: apollo-core, code-forge, command-center, pixel-grid, retro-wave, neon-edge, zen-flow, nova-pulse, crystal-bay, star-deck, deep-space, command-deck, command-deck-clean, light-bridge, cyber-matrix, quantum-flux, silicon-dawn, frost-byte"
        return 1
    fi
    [ ! -f "${NIRI_CONFIGS[$mode]}" ] && echo "Config not found: ${NIRI_CONFIGS[$mode]}" && return 1
    cp "${NIRI_CONFIGS[$mode]}" "$NIRI_CONFIG"
    cp "${WAYBAR_CONFIGS[$mode]}" "$WAYBAR_CONFIG"
    cp "${WAYBAR_STYLES[$mode]}" "$WAYBAR_STYLE"
    set_mode "$mode"
}

reload_ui() {
    local mode=$(get_current_mode)
    manage_screen_corners "$mode"
    local wpids=$(pgrep -x waybar 2>/dev/null)
    [ -n "$wpids" ] && echo "$wpids" | xargs -r kill 2>/dev/null || true
    rm -f "$DOCK_PIDFILE"
    sleep 0.5
    waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" >/dev/null 2>&1 &
    disown
    manage_dock "$mode"
    manage_mako "$mode"
    niri msg action load-config-file 2>/dev/null || true
}

current_mode=$(get_current_mode)

if [ "$1" = "status" ]; then
    echo "$current_mode"
    exit 0
fi

if [ "$1" = "toggle" ] || [ -z "$1" ]; then
    case "$current_mode" in
        apollo-core)        new_mode="code-forge" ;;
        code-forge)         new_mode="command-center" ;;
        command-center)     new_mode="pixel-grid" ;;
        pixel-grid)         new_mode="retro-wave" ;;
        retro-wave)         new_mode="neon-edge" ;;
        neon-edge)          new_mode="zen-flow" ;;
        zen-flow)           new_mode="nova-pulse" ;;
        nova-pulse)         new_mode="crystal-bay" ;;
        crystal-bay)        new_mode="star-deck" ;;
        star-deck)          new_mode="deep-space" ;;
        deep-space)         new_mode="command-deck" ;;
        command-deck)       new_mode="command-deck-clean" ;;
        command-deck-clean) new_mode="light-bridge" ;;
        light-bridge)       new_mode="cyber-matrix" ;;
        cyber-matrix)       new_mode="quantum-flux" ;;
        quantum-flux)       new_mode="silicon-dawn" ;;
        silicon-dawn)       new_mode="frost-byte" ;;
        frost-byte)         new_mode="apollo-core" ;;
        *)                  new_mode="apollo-core" ;;
    esac

    switch_to "$new_mode"
    display="${DISPLAY_NAMES[$new_mode]:-$new_mode}"
    notify-send "Apollo OS" "Visual Mode: $display"
    tts_notify "visual-$new_mode" &
    reload_ui
    exit 0
fi

if is_valid_mode "$1"; then
    switch_to "$1"
    display="${DISPLAY_NAMES[$1]:-$1}"
    notify-send "Apollo OS" "Visual Mode: $display"
    tts_notify "visual-$1" &
    reload_ui
else
    echo "Usage: $0 [MODE|toggle|status]"
    echo "Available: apollo-core, code-forge, command-center, pixel-grid, retro-wave, neon-edge, zen-flow, nova-pulse, crystal-bay, star-deck, deep-space, command-deck, command-deck-clean, light-bridge, cyber-matrix, quantum-flux, silicon-dawn, frost-byte"
    echo "Current: $current_mode"
    exit 1
fi
