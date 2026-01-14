#!/bin/bash
CONFIG="$HOME/.config/niri/config.kdl"
if grep -q 'center-focused-column "always"' "$CONFIG"; then
    sed -i 's/center-focused-column "always"/center-focused-column "never"/' "$CONFIG"
    notify-send "APOLLO OS  Fenstermanager" "Zentrierung: AUS"
else
    sed -i 's/center-focused-column "never"/center-focused-column "always"/' "$CONFIG"
    notify-send "APOLLO OS  Fenstermanager" "Zentrierung: AN"
fi
# Niri lädt die Konfiguration automatisch neu, wenn die Datei gespeichert wird.
