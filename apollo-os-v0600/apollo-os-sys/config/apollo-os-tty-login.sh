
# Apollo OS - Auto-start Niri on TTY1 login
# Only start on TTY1, not on SSH or other terminals
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    if [ -x "$HOME/.local/bin/apollo-os-boot-sequence.sh" ]; then
        # exec replaces the login shell - when boot-sequence or niri exits,
        # the TTY login prompt returns automatically
        exec "$HOME/.local/bin/apollo-os-boot-sequence.sh"
    else
        echo "Apollo OS boot sequence not found. Start manually with: apollo-os-boot-sequence.sh"
    fi
fi
