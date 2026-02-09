#!/bin/bash

#####################################################################
# Apollo OS - Boot Sequence v0.6.0
# Copyright (c) 2025 by Manuel Kraibacher
#####################################################################

# Colors
C='\033[0;36m'
W='\033[1;37m'
D='\033[0;90m'
R='\033[0;31m'
NC='\033[0m'

clear
echo

# ── Banner ──
echo -e "${D}  ──────────────────────────────────────────────────────────${NC}"
echo -e "${W}      ___                ____           ____  _____${NC}"
echo -e "${W}     /   |  ____  ____  / / /___       / __ \\/ ___/${NC}"
echo -e "${W}    / /| | / __ \\/ __ \\/ / / __ \\     / / / /\\__ \\ ${NC}"
echo -e "${W}   / ___ |/ /_/ / /_/ / / / /_/ /    / /_/ /___/ /${NC}"
echo -e "${W}  /_/  |_/ .___/\\____/_/_/\\____/     \\____//____/ ${NC}"
echo -e "${W}        /_/${NC}"
echo -e "${D}  ──────────────────────────────────────────────────────────${NC}"
echo

# ── Load configuration ──
APOLLO_CONFIG="$HOME/.config/apollo-os/config.env"
WM_TO_LAUNCH=""
if [[ -f "$APOLLO_CONFIG" ]]; then
    source "$APOLLO_CONFIG"
    WM_TO_LAUNCH="${DEFAULT_WM:-}"
fi

# ── Detect available environments ──
HAS_NIRI=false
HAS_HYPRLAND=false
[[ -x "$HOME/.local/bin/apollo-os-wrapper-niri.sh" ]] && command -v niri &>/dev/null && HAS_NIRI=true
[[ -x "$HOME/.local/bin/start-hyprland" ]] && command -v Hyprland &>/dev/null && HAS_HYPRLAND=true

# ── Environment Selection ──
if $HAS_NIRI && $HAS_HYPRLAND; then
    echo -e "  ${W}1${NC}  Apollo OS Orbit"
    echo -e "  ${W}2${NC}  Apollo OS Glass"
    echo

    # Determine default selection
    case "$WM_TO_LAUNCH" in
        Hyprland|hyprland) DEFAULT_CHOICE=2 ;;
        *) DEFAULT_CHOICE=1 ;;
    esac
    echo -ne "  ${D}Select [1-2] (default: ${DEFAULT_CHOICE}, auto in 10s): ${NC}"

    # Read with 10 second timeout
    if read -t 10 -n 1 SESSION_CHOICE; then
        echo
    else
        SESSION_CHOICE=$DEFAULT_CHOICE
        echo "${SESSION_CHOICE}"
    fi
    SESSION_CHOICE=${SESSION_CHOICE:-$DEFAULT_CHOICE}

    case "$SESSION_CHOICE" in
        2) WM_TO_LAUNCH="Hyprland" ;;
        *) WM_TO_LAUNCH="niri" ;;
    esac
    echo
elif $HAS_HYPRLAND; then
    WM_TO_LAUNCH="Hyprland"
elif $HAS_NIRI; then
    WM_TO_LAUNCH="niri"
else
    echo -e "  ${R}[FATAL]${NC} No compositor found. Dropping to shell."
    exit 1
fi

# ── Launch ──
case "$WM_TO_LAUNCH" in
    Hyprland|hyprland)
        if [[ -x "$HOME/.local/bin/start-hyprland" ]]; then
            exec "$HOME/.local/bin/start-hyprland"
        else
            echo -e "  ${R}[ERROR]${NC} start-hyprland not found."
            sleep 5
            exit 0
        fi
        ;;
    *)
        exec "$HOME/.local/bin/apollo-os-wrapper-niri.sh"
        ;;
esac
