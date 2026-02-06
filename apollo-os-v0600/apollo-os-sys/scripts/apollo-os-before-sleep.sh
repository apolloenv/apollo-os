#!/bin/bash
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
~/.local/bin/apollo-os-sleep-tts.sh sleep
hyprlock
