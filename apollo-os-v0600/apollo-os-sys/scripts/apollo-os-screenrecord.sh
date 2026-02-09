#!/bin/bash

#####################################################################
# Apollo OS - Screen Recorder
# Inspired by Omarchy, adapted for Fedora + Niri
#
# Description: Start/stop screen recording with optional audio.
#              Uses wf-recorder (Wayland native) or gpu-screen-recorder.
# Keybinding: Alt+Print     → Start/Stop recording
#             Super+Print   → Color Picker
# Requires: wf-recorder OR gpu-screen-recorder, slurp, wl-copy
#####################################################################

set -euo pipefail

[[ -f ~/.config/user-dirs.dirs ]] && source ~/.config/user-dirs.dirs
OUTPUT_DIR="${APOLLO_SCREENRECORD_DIR:-${XDG_VIDEOS_DIR:-$HOME/Videos}}"

if [[ ! -d "$OUTPUT_DIR" ]]; then
    mkdir -p "$OUTPUT_DIR"
fi

DESKTOP_AUDIO="false"
MICROPHONE_AUDIO="false"
STOP_RECORDING="false"
REGION="false"

for arg in "$@"; do
    case "$arg" in
        --with-desktop-audio) DESKTOP_AUDIO="true" ;;
        --with-microphone-audio) MICROPHONE_AUDIO="true" ;;
        --stop) STOP_RECORDING="true" ;;
        --region) REGION="true" ;;
    esac
done

PIDFILE="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/apollo-os-screenrecord.pid"
RECORDER=""

# Detect available recorder
if command -v gpu-screen-recorder &>/dev/null; then
    RECORDER="gpu-screen-recorder"
elif command -v wf-recorder &>/dev/null; then
    RECORDER="wf-recorder"
else
    notify-send "Apollo OS" "❌ Kein Screen-Recorder installiert!\nInstalliere: sudo dnf install wf-recorder" -u critical
    exit 1
fi

is_recording() {
    if [ -f "$PIDFILE" ]; then
        local pid
        pid=$(cat "$PIDFILE")
        if kill -0 "$pid" 2>/dev/null; then
            return 0
        fi
        rm -f "$PIDFILE"
    fi
    return 1
}

stop_recording() {
    if [ -f "$PIDFILE" ]; then
        local pid
        pid=$(cat "$PIDFILE")

        if [ "$RECORDER" = "gpu-screen-recorder" ]; then
            kill -SIGINT "$pid" 2>/dev/null
        else
            kill -SIGINT "$pid" 2>/dev/null
        fi

        # Wait for clean exit
        local count=0
        while kill -0 "$pid" 2>/dev/null && [ $count -lt 50 ]; do
            sleep 0.1
            count=$((count + 1))
        done

        if kill -0 "$pid" 2>/dev/null; then
            kill -9 "$pid" 2>/dev/null
            notify-send "🎬 Aufnahme" "⚠️ Aufnahme erzwungen beendet" -u critical -t 3000
        else
            notify-send "🎬 Aufnahme" "✅ Aufnahme gespeichert in $OUTPUT_DIR" -t 3000
        fi

        rm -f "$PIDFILE"
    fi
}

start_recording() {
    local filename="$OUTPUT_DIR/screenrecording-$(date +'%Y-%m-%d_%H-%M-%S').mp4"
    local geometry=""

    # Region selection
    if [ "$REGION" = "true" ]; then
        geometry=$(slurp 2>/dev/null) || exit 0
    fi

    if [ "$RECORDER" = "gpu-screen-recorder" ]; then
        local -a cmd_gpu=(-w portal -f 60 -o "$filename")
        local audio_args=""

        if [ "$DESKTOP_AUDIO" = "true" ]; then
            audio_args="default_output"
        fi
        if [ "$MICROPHONE_AUDIO" = "true" ]; then
            if [ -n "$audio_args" ]; then
                audio_args="${audio_args}|default_input"
            else
                audio_args="default_input"
            fi
        fi

        if [ -n "$audio_args" ]; then
            cmd_gpu+=(-a "$audio_args")
        fi
        gpu-screen-recorder "${cmd_gpu[@]}" -ac aac &
        echo $! > "$PIDFILE"

    elif [ "$RECORDER" = "wf-recorder" ]; then
        local cmd_args=()

        if [ -n "$geometry" ]; then
            cmd_args+=("-g" "$geometry")
        fi

        if [ "$DESKTOP_AUDIO" = "true" ] || [ "$MICROPHONE_AUDIO" = "true" ]; then
            cmd_args+=("--audio")
        fi

        wf-recorder "${cmd_args[@]}" -f "$filename" &
        echo $! > "$PIDFILE"
    fi

    disown
    notify-send "🎬 Aufnahme" "▶️ Bildschirmaufnahme gestartet\nNochmal drücken zum Stoppen" -t 3000
}

# Toggle logic
if is_recording; then
    stop_recording
elif [ "$STOP_RECORDING" = "false" ]; then
    start_recording
fi
