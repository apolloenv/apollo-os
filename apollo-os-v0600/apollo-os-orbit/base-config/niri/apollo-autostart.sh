#!/bin/bash
# Apollo OS Autostart for Niri v1.1.0
# Copyright © 2025 by Manuel Kraibacher
#
# Note: Core services (waybar, mako, swaybg, swayidle, nm-applet,
#       blueman-applet, monitors) are started via spawn-at-startup
#       in config.kdl. This script only handles environment setup
#       and tasks that need a running desktop environment.

# Wait until WM is ready
sleep 1

# Load environment from config
if [[ -f ~/.config/apollo-os/config.env ]]; then
    source ~/.config/apollo-os/config.env
fi

# Theme from Environment (defaults for v0.5.0)
THEME=${APOLLO_THEME:-dark}

# Set GTK Theme via gsettings (needs running dbus session)
if [[ "$THEME" == "dark" ]]; then
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null
    export GTK_THEME="adw-gtk3-dark"
    export ADW_DEBUG_COLOR_SCHEME="prefer-dark"
else
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' 2>/dev/null
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null
    export GTK_THEME="adw-gtk3"
    export ADW_DEBUG_COLOR_SCHEME="default"
fi

# Ensure cursor theme is applied
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic' 2>/dev/null
gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null

# Login Greeting (with TTS - starts after audio is ready)
if [ -f "$HOME/.local/bin/apollo-os-greeting.sh" ]; then
    "$HOME/.local/bin/apollo-os-greeting.sh" &
fi

# Welcome notification + TTS (delay for desktop to be ready)
(
    sleep 3
    notify-send "APOLLO OS" "Welcome to Orbit" 2>/dev/null
) &

if [ -f "$HOME/.local/bin/apollo-os-welcome-tts.sh" ]; then
    "$HOME/.local/bin/apollo-os-welcome-tts.sh" &
fi

# Start clipboard history daemon (cliphist)
if command -v cliphist &>/dev/null && command -v wl-paste &>/dev/null; then
    wl-paste --type text --watch cliphist store &
    disown $!
    wl-paste --type image --watch cliphist store &
    disown $!
fi
