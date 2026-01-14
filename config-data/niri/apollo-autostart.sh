#!/bin/bash
# Apollo OS Autostart for Niri v0.5.0
# Copyright © 2026 by Manuel Kraibacher
# Starts services after WM-Start

# Wait until WM is ready
sleep 2

# Load environment from config
if [[ -f ~/.config/apollo-os/config.env ]]; then
    source ~/.config/apollo-os/config.env
fi

# Theme from Environment (defaults for v0.5.0)
THEME=${APOLLO_THEME:-dark}

# Config paths (simplified for v0.5.0 - single config)
WAYBAR_CONFIG="$HOME/.config/waybar/config-niri"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
MAKO_CONFIG="$HOME/.config/mako/config"
WALLPAPER_PATH="$HOME/System/Wallpaper/current.jpg"

# Set GTK Theme
if [[ "$THEME" == "dark" ]]; then
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null
else
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null
    gsettings set org.gnome.desktop.interface color-scheme 'default' 2>/dev/null
fi

# Ensure PulseAudio/Pipewire is ready for TTS
sleep 1

# Waybar (only if not already running)
if ! pgrep -x waybar >/dev/null && [ -f "$WAYBAR_CONFIG" ]; then
    waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &
fi

# Mako Notification Daemon (only if not already running)
if ! pgrep -x mako >/dev/null && [ -f "$MAKO_CONFIG" ]; then
    mako --config "$MAKO_CONFIG" &
fi

# Wait for Mako to be ready
sleep 1

# Wallpaper (only if not already running)
if ! pgrep -x swaybg >/dev/null && [ -f "$WALLPAPER_PATH" ]; then
    swaybg -i "$WALLPAPER_PATH" -m fill &
fi

# Idle management with swaylock (only if not already running)
if ! pgrep -x swayidle >/dev/null && command -v swayidle &>/dev/null; then
    swayidle -w \
        timeout 300 'swaylock -f -c 000000' \
        timeout 600 'niri msg action power-off-monitors' \
        resume 'niri msg action power-on-monitors' \
        before-sleep 'swaylock -f -c 000000' &
fi

# Network Manager Applet (only if not already running)
if ! pgrep -f nm-applet >/dev/null && command -v nm-applet &>/dev/null; then
    nm-applet --indicator &
fi

# Bluetooth Applet (only if not already running)
if ! pgrep -f blueman-applet >/dev/null && command -v blueman-applet &>/dev/null; then
    blueman-applet &
fi

# Wait for audio system to be fully ready
sleep 2

# Login Greeting (with TTS - now starts after audio is ready)
if [ -f "$HOME/.local/bin/apollo-os-greeting.sh" ]; then
    "$HOME/.local/bin/apollo-os-greeting.sh" &
fi

# Start System Event Monitor (for battery/network notifications with TTS)
if [ -f "$HOME/.local/bin/apollo-os-event-monitor.sh" ]; then
    "$HOME/.local/bin/apollo-os-event-monitor.sh" &
fi
