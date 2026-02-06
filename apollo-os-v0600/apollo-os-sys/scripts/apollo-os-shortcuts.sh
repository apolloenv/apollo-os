#!/bin/bash

#####################################################################
# Apollo OS - Keyboard Shortcuts Display
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Display Niri keyboard shortcuts in Rofi
# Usage: apollo-os-shortcuts.sh
#####################################################################

# Set environment
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Shortcuts as individual items for scrollable display
shortcuts=(
    ""
    "╔════════════════════════════════════════════════════════╗"
    "║              ⌨️   APOLLO OS KEYBOARD SHORTCUTS          ║"
    "╚════════════════════════════════════════════════════════╝"
    ""
    "╔════════════════════════════════════════════════════════╗"
    "║                    📱  APPLICATIONS                     ║"
    "╚════════════════════════════════════════════════════════╝"
    ""
    "  Super + Return                    Terminal (Alacritty)"
    "  Super + Space                     App Launcher (Rofi)"
    "  Super + Shift + Space             Quick Menu"
    "  Super + E                         File Manager"
    "  Super + W                         Web Browser"
    ""
    "╔════════════════════════════════════════════════════════╗"
    "║                  🪟  WINDOW MANAGEMENT                  ║"
    "╚════════════════════════════════════════════════════════╝"
    ""
    "  Super + Q                         Close Window"
    "  Super + F                         Toggle Fullscreen"
    "  Super + C                         Center Window"
    "  Super + Left/Right                Move Focus"
    "  Super + Shift + Left/Right        Move Window"
    "  Super + H/L                       Resize Width"
    "  Super + J/K                       Resize Height"
    ""
    "╔════════════════════════════════════════════════════════╗"
    "║                    🖥️   WORKSPACES                      ║"
    "╚════════════════════════════════════════════════════════╝"
    ""
    "  Super + 1-9                       Switch Workspace"
    "  Super + Shift + 1-9               Move to Workspace"
    "  Super + Tab                       Next Workspace"
    "  Super + Shift + Tab               Previous Workspace"
    ""
    "╔════════════════════════════════════════════════════════╗"
    "║                 📸  SCREENSHOT & MEDIA                  ║"
    "╚════════════════════════════════════════════════════════╝"
    ""
    "  Print                             Screenshot Area"
    "  Super + Print                     Screenshot Window"
    "  Shift + Print                     Screenshot Full"
    "  Volume Up/Down                    Audio Control"
    "  Brightness Up/Down                Screen Brightness"
    "  XF86AudioPlay                     Play/Pause Media"
    ""
    "╔════════════════════════════════════════════════════════╗"
    "║                      🔒  SYSTEM                         ║"
    "╚════════════════════════════════════════════════════════╝"
    ""
    "  Super + L                         Lock Screen"
    "  Super + Shift + E                 Logout"
    "  Super + X                         Power Menu"
    ""
    "╔════════════════════════════════════════════════════════╗"
    "║  💡  TIP: Press Super (Windows key) for more options!  ║"
    "╚════════════════════════════════════════════════════════╝"
    ""
)

# Display in Rofi as scrollable list
printf '%s\n' "${shortcuts[@]}" | rofi -dmenu -p "⌨️  Apollo OS Keyboard Shortcuts" -i \
    -theme-str 'window {width: 1000px; height: 700px;} listview {lines: 22; scrollbar: true;} element {padding: 6px 10px;}'
