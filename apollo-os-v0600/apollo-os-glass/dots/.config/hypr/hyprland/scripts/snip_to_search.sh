#!/usr/bin/env bash
# Snip-to-Search: Take a screenshot region and open Google Lens for reverse image search
TMPIMG=$(mktemp /tmp/snip-XXXXXX.png)
grim -g "$(slurp)" "$TMPIMG" || { rm -f "$TMPIMG"; exit 1; }

# Copy to clipboard and open Google Lens search page
# User can paste the image directly into the Lens interface
wl-copy < "$TMPIMG" 2>/dev/null
xdg-open "https://lens.google.com/" &
notify-send -t 5000 "Snip-to-Search" "Screenshot copied to clipboard — paste into Google Lens" 2>/dev/null
rm -f "$TMPIMG"
