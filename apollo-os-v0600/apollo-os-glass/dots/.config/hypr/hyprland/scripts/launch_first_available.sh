#!/usr/bin/env bash
# Launch the first available command from the arguments
for cmd in "$@"; do
    [[ -z "$cmd" ]] && continue
    local_cmd="${cmd%% *}"
    command -v "$local_cmd" >/dev/null 2>&1 || continue
    $cmd &
    exit
done
