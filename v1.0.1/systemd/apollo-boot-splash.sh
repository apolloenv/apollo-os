#!/bin/bash
# Apollo OS Boot Splash
# Copyright 2025 by Manuel Kraibacher
# Displays Apollo ASCII logo during boot sequence

# Show splash in background and exit immediately
(
    clear
    cat << 'EOF'

     █████╗ ██████╗  ██████╗ ██╗     ██╗      ██████╗ 
    ██╔══██╗██╔══██╗██╔═══██╗██║     ██║     ██╔═══██╗
    ███████║██████╔╝██║   ██║██║     ██║     ██║   ██║
    ██╔══██║██╔═══╝ ██║   ██║██║     ██║     ██║   ██║
    ██║  ██║██║     ╚██████╔╝███████╗███████╗╚██████╔╝
    ╚═╝  ╚═╝╚═╝      ╚═════╝ ╚══════╝╚══════╝ ╚═════╝ 
    
    ╔═══════════════════════════════════════════════════╗
    ║          Apollo OS v0.4.1 - Booting...          ║
    ║     Advanced Intelligence Quantum System         ║
    ╚═══════════════════════════════════════════════════╝

EOF
    sleep 2
) &

# Exit immediately, let splash run in background
exit 0
