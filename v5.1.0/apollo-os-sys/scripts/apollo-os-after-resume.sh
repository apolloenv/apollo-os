#!/bin/bash
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
sleep 1
~/.local/bin/apollo-os-sleep-tts.sh wake
