#!/bin/bash

#####################################################################
# Apollo OS - Screenshot Tool
# Inspired by Omarchy, adapted for Fedora + Niri
#
# Description: Advanced screenshot tool with region/window/fullscreen
#              selection, annotation via satty, and clipboard support.
# Keybinding: Print        → Smart select + edit
#             Shift+Print  → Smart select → clipboard
#             Ctrl+Print   → Fullscreen
# Requires: grim, slurp, satty, wl-copy, wayfreeze (optional)
#####################################################################

set -euo pipefail

[[ -f ~/.config/user-dirs.dirs ]] && source ~/.config/user-dirs.dirs
OUTPUT_DIR="${APOLLO_SCREENSHOT_DIR:-$HOME/Screenshots}"

if [[ ! -d "$OUTPUT_DIR" ]]; then
    mkdir -p "$OUTPUT_DIR"
fi

# Cancel if slurp is already running
if pgrep -x slurp >/dev/null 2>&1; then
    exit 0
fi

MODE="${1:-smart}"
PROCESSING="${2:-edit}"

# Get geometry of focused output via niri
get_focused_output() {
    # Try niri msg outputs
    local output_info
    output_info=$(niri msg outputs 2>/dev/null || true)

    if [ -n "$output_info" ]; then
        # Fallback: capture entire screen
        local resolution
        resolution=$(niri msg outputs 2>/dev/null | grep -oP '\d+x\d+' | head -1 || echo "1920x1080")
        echo "0,0 $resolution"
    fi
}

freeze_screen() {
    if command -v wayfreeze &>/dev/null; then
        wayfreeze &
        FREEZE_PID=$!
        sleep 0.1
    fi
}

unfreeze_screen() {
    if [ -n "${FREEZE_PID:-}" ]; then
        kill "$FREEZE_PID" 2>/dev/null || true
    fi
}

case "$MODE" in
    region)
        freeze_screen
        SELECTION=$(slurp 2>/dev/null) || true
        unfreeze_screen
        ;;
    fullscreen)
        # Use niri's built-in screenshot or grim full screen
        SELECTION=""
        ;;
    smart|*)
        freeze_screen
        SELECTION=$(slurp 2>/dev/null) || true
        unfreeze_screen
        ;;
esac

# Fullscreen mode: no geometry flag
if [ "$MODE" = "fullscreen" ]; then
    FILENAME="$OUTPUT_DIR/screenshot-$(date +'%Y%m%d-%H%M%S').png"
    grim "$FILENAME"

    if [ "$PROCESSING" = "clipboard" ]; then
        wl-copy < "$FILENAME"
        notify-send "📸 Screenshot" "Fullscreen → Zwischenablage" -t 2000
    else
        if command -v satty &>/dev/null; then
            satty --filename "$FILENAME" \
                --output-filename "$FILENAME" \
                --early-exit \
                --actions-on-enter save-to-clipboard \
                --save-after-copy \
                --copy-command 'wl-copy' &
        else
            wl-copy < "$FILENAME"
            notify-send "📸 Screenshot" "Gespeichert: $FILENAME" -t 2000
        fi
    fi
    exit 0
fi

# Region/smart mode
[ -z "${SELECTION:-}" ] && exit 0

FILENAME="$OUTPUT_DIR/screenshot-$(date +'%Y%m%d-%H%M%S').png"

if [ "$PROCESSING" = "clipboard" ]; then
    grim -g "$SELECTION" - | wl-copy
    notify-send "📸 Screenshot" "Region → Zwischenablage" -t 2000
elif [ "$PROCESSING" = "edit" ] && command -v satty &>/dev/null; then
    grim -g "$SELECTION" - | \
        satty --filename - \
            --output-filename "$FILENAME" \
            --early-exit \
            --actions-on-enter save-to-clipboard \
            --save-after-copy \
            --copy-command 'wl-copy'
else
    grim -g "$SELECTION" "$FILENAME"
    wl-copy < "$FILENAME"
    notify-send "📸 Screenshot" "Gespeichert: $FILENAME" -t 2000
fi
