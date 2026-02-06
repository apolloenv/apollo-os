#!/bin/bash

#####################################################################
# Apollo OS - Web Search from Rofi
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Performs web search when rofi input doesn't match apps
# Usage: Called automatically by rofi launcher
#####################################################################

query="$1"

if [ -z "$query" ]; then
    exit 0
fi

# URL encode the query
encoded_query=$(echo "$query" | sed 's/ /%20/g')

# Default browser (try to find installed browser)
if command -v google-chrome-stable &>/dev/null; then
    browser="google-chrome-stable"
elif command -v microsoft-edge-stable &>/dev/null; then
    browser="microsoft-edge-stable"
elif command -v firefox &>/dev/null; then
    browser="firefox"
elif command -v brave &>/dev/null; then
    browser="brave"
else
    # Fallback to xdg-open
    browser="xdg-open"
fi

# Perform search (using DuckDuckGo by default)
"$browser" "https://duckduckgo.com/?q=$encoded_query" &

# Show notification
notify-send "Apollo OS" "Searching: $query" -t 2000
