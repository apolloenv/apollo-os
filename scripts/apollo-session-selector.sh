#!/bin/bash

#####################################################################
# Apollo OS - Session Selector for tuigreet
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Interactive session selector for greetd/tuigreet
# This script is called by tuigreet to present session choices
#####################################################################

# HINWEIS: Dieses Script wird von tuigreet als "greeter"-User ausgefuehrt,
# daher koennen wir $USER/$HOME nicht verwenden! Die Wrapper-Scripts
# muessen global in /usr/local/bin/ installiert sein.

# Available sessions - verwenden globale Pfade
declare -A SESSIONS=(
    ["1"]="Apollo OS - Niri PRO|/usr/local/bin/apollo-os-wrapper-niri.sh pro dark"
    ["2"]="Apollo OS - Niri MOD|/usr/local/bin/apollo-os-wrapper-niri.sh mod dark"
    ["3"]="Apollo OS - Sway PRO|/usr/local/bin/apollo-os-wrapper-sway.sh pro dark"
    ["4"]="Apollo OS - Sway MOD|/usr/local/bin/apollo-os-wrapper-sway.sh mod dark"
    ["5"]="Gnome (Default)|gnome-session"
)

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Display ASCII Art
if [[ -f "$HOME/.config/apollo-os/boot-logo.txt" ]]; then
    echo -e "${CYAN}"
    cat "$HOME/.config/apollo-os/boot-logo.txt"
    echo -e "${NC}"
fi

echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Welcome to Apollo OS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}Select your session:${NC}\n"

# Display sessions
for key in $(echo "${!SESSIONS[@]}" | tr ' ' '\n' | sort); do
    IFS='|' read -r name cmd <<< "${SESSIONS[$key]}"
    echo -e "  ${GREEN}[$key]${NC} $name"
done

echo
read -p "Choice [1-5]: " choice

# Validate choice
if [[ ! "${SESSIONS[$choice]}" ]]; then
    echo "Invalid choice. Defaulting to Niri PRO."
    choice="1"
fi

# Extract command
IFS='|' read -r name cmd <<< "${SESSIONS[$choice]}"

# Execute selected session
echo -e "\n${GREEN}Starting: $name${NC}\n"
exec $cmd
