#!/bin/bash

#####################################################################
# Apollo OS - Synology Drive Launcher with XWayland
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Launch Synology Drive with XWayland (X11 compatibility)
#####################################################################

# Set Qt to use xcb (X11) through XWayland
export QT_QPA_PLATFORM=xcb
export QT_QPA_PLATFORMTHEME=qt5ct

# Enable XWayland
export DISPLAY="${DISPLAY:-:0}"

# Ensure XDG_RUNTIME_DIR
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Launch Synology Drive
exec /usr/bin/synology-drive start "$@"
