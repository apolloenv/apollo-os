#!/bin/bash
# Apollo OS Boot Splash
# Copyright 2025 by Manuel Kraibacher
# Displays Apollo ASCII logo during boot sequence

clear
cat << 'EOF'

     █████╗ ██████╗  ██████╗ ██╗     ██╗      ██████╗ 
    ██╔══██╗██╔══██╗██╔═══██╗██║     ██║     ██╔═══██╗
    ███████║██████╔╝██║   ██║██║     ██║     ██║   ██║
    ██╔══██║██╔═══╝ ██║   ██║██║     ██║     ██║   ██║
    ██║  ██║██║     ╚██████╔╝███████╗███████╗╚██████╔╝
    ╚═╝  ╚═╝╚═╝      ╚═════╝ ╚══════╝╚══════╝ ╚═════╝ 
    
    ╔═══════════════════════════════════════════════════╗
    ║          Apollo OS v0.6.0 - Booting...          ║
    ║     Advanced Intelligence Quantum System         ║
    ╚═══════════════════════════════════════════════════╝

EOF
sleep 2
exit 0
