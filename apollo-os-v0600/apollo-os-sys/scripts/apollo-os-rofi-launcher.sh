#!/bin/bash

#####################################################################
# Apollo OS - Smart Rofi Launcher
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Rofi with web search integration
# Usage: Super+Space - Launch apps or Alt+Enter to search web
#####################################################################

# Set environment
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Launch rofi with custom keybinding for web search
# Alt+Enter (kb-custom-1) will trigger web search
rofi -show drun \
     -kb-custom-1 "Alt+Return" \
     -display-drun "Apps (Alt+Enter for Web Search)"

EXIT_CODE=$?

# Exit code 10 means custom-1 keybinding (Alt+Enter) was pressed
if [ $EXIT_CODE -eq 10 ]; then
    # Prompt for web search
    search_query=$(rofi -dmenu -p "Web Search" -theme-str 'window {width: 600px;}')
    
    if [ -n "$search_query" ]; then
        "$HOME/.local/bin/apollo-os-web-search.sh" "$search_query" &
    fi
fi

exit 0
