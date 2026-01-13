#!/bin/bash
# Apollo OS Autostart für Niri/Sway
# Copyright © 2026 by Manuel Kraibacher
# Startet Services nach WM-Start

# Warte bis WM bereit ist
sleep 2

# Environment aus Config laden
if [[ -f ~/.config/apollo-os/config.env ]]; then
    source ~/.config/apollo-os/config.env
fi

# Profile und Theme aus Environment
PROFILE=${APOLLO_PROFILE:-pro}
THEME=${APOLLO_THEME:-dark}
WM=${APOLLO_WM:-niri}

# Config-Pfade
WAYBAR_CONFIG="$HOME/.config/waybar/apollo-os-config-$WM-$PROFILE"
WAYBAR_STYLE="$HOME/.config/waybar/apollo-os-style-$WM-$PROFILE.css"
MAKO_CONFIG="$HOME/.config/mako/apollo-os-config-$THEME"
WALLPAPER_PATH="$HOME/System/Wallpaper/current.jpg"

# GTK Theme setzen
if [[ "$THEME" == "dark" ]]; then
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
else
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
    gsettings set org.gnome.desktop.interface color-scheme 'default'
fi

# Waybar
if [ -f "$WAYBAR_CONFIG" ]; then
    waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &
fi

# Mako
if [ -f "$MAKO_CONFIG" ]; then
    mako --config "$MAKO_CONFIG" &
fi

# Wallpaper
if [ -f "$WALLPAPER_PATH" ]; then
    swaybg -i "$WALLPAPER_PATH" -m fill &
fi

# Network Manager
if command -v nm-applet &>/dev/null; then
    nm-applet --indicator &
fi

# Bluetooth
if command -v blueman-applet &>/dev/null; then
    blueman-applet &
fi
