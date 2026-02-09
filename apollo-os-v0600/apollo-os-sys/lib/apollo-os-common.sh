#!/bin/bash
#####################################################################
# Apollo OS - Common Library
# Copyright © 2025 by Manuel Kraibacher
#
# Zentrale Funktionen und Konstanten für alle Apollo OS Scripts
# Usage: source "$HOME/.local/lib/apollo-os-common.sh"
#####################################################################

# ═══════════════════════════════════════════════════════════════════
# KONSTANTEN
# ═══════════════════════════════════════════════════════════════════

# Pfade
APOLLO_HOME="${APOLLO_HOME:-$HOME}"
APOLLO_CONFIG="${APOLLO_CONFIG:-$HOME/.config/apollo-os}"
APOLLO_SCRIPTS="${APOLLO_SCRIPTS:-$HOME/.local/bin}"
APOLLO_LIB="${APOLLO_LIB:-$HOME/.local/lib}"
APOLLO_DATA="${APOLLO_DATA:-$HOME/.local/share/apollo-os}"
APOLLO_CACHE="${APOLLO_CACHE:-$HOME/.cache/apollo-os}"
APOLLO_RUNTIME="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Konfigurationsdateien
APOLLO_CONFIG_ENV="$APOLLO_CONFIG/config.env"
APOLLO_VISUAL_MODE_FILE="$APOLLO_CONFIG/visual-mode"
APOLLO_VOICE_COMMANDS="$APOLLO_CONFIG/voice-commands.conf"

# Scripts
TTS_SCRIPT="$APOLLO_SCRIPTS/apollo-os-tts-notify.sh"
VISUAL_MODE_SCRIPT="$APOLLO_SCRIPTS/apollo-os-visual-mode.sh"

# Timing (optimierte Werte)
STARTUP_DELAY=2
POLL_INTERVAL=2
UI_TRANSITION_DELAY=0.3

# ═══════════════════════════════════════════════════════════════════
# LOGGING
# ═══════════════════════════════════════════════════════════════════

apollo_log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >&2
}

log_info() { apollo_log "INFO" "$@"; }
log_warn() { apollo_log "WARN" "$@"; }
log_error() { apollo_log "ERROR" "$@"; }
log_debug() { [[ "${APOLLO_DEBUG:-0}" == "1" ]] && apollo_log "DEBUG" "$@"; }

# ═══════════════════════════════════════════════════════════════════
# FEHLERBEHANDLUNG
# ═══════════════════════════════════════════════════════════════════

apollo_error() {
    log_error "$@"
    exit 1
}

apollo_warn() {
    log_warn "$@"
}

# Führe Befehl aus mit Fehlerbehandlung
apollo_exec() {
    "$@" || {
        log_error "Command failed: $*"
        return 1
    }
}

# Führe Befehl aus mit Retry
apollo_retry() {
    local max_attempts="${1:-3}"
    shift
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        if "$@"; then
            return 0
        fi
        log_warn "Attempt $attempt/$max_attempts failed: $*"
        ((attempt++))
        sleep 1
    done

    log_error "All $max_attempts attempts failed: $*"
    return 1
}

# ═══════════════════════════════════════════════════════════════════
# LOCKFILE-HANDLING (sicher)
# ═══════════════════════════════════════════════════════════════════

apollo_acquire_lock() {
    local lockfile="$1"
    local lockdir="${lockfile%/*}"

    # Erstelle Lock-Verzeichnis falls nötig
    mkdir -p "$lockdir" 2>/dev/null

    # Atomic lock via mkdir (cannot race)
    local lockmark="${lockfile}.lk"
    if mkdir "$lockmark" 2>/dev/null; then
        # Got lock atomically — check for stale PID
        echo $$ > "$lockfile"
        chmod 600 "$lockfile" 2>/dev/null
        rmdir "$lockmark" 2>/dev/null
        trap "rm -f '$lockfile'" EXIT INT TERM
        return 0
    fi

    # Lock dir exists — check if holder is still alive
    if [[ -f "$lockfile" ]]; then
        local pid
        pid=$(cat "$lockfile" 2>/dev/null)
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            log_debug "Lock held by PID $pid"
            rmdir "$lockmark" 2>/dev/null
            return 1
        fi
        # Stale lock — reclaim
        rm -f "$lockfile"
        echo $$ > "$lockfile"
        chmod 600 "$lockfile" 2>/dev/null
        rmdir "$lockmark" 2>/dev/null
        trap "rm -f '$lockfile'" EXIT INT TERM
        return 0
    fi

    rmdir "$lockmark" 2>/dev/null
    return 1
}

apollo_release_lock() {
    local lockfile="$1"
    rm -f "$lockfile" 2>/dev/null
}

# ═══════════════════════════════════════════════════════════════════
# INPUT-VALIDIERUNG
# ═══════════════════════════════════════════════════════════════════

# Validiere numerischen Wert
validate_number() {
    local value="$1"
    local min="${2:-0}"
    local max="${3:-999999}"

    [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]] || return 1
    (( $(echo "$value >= $min && $value <= $max" | bc -l) )) || return 1
    return 0
}

# Validiere Pfad (kein Command-Injection)
validate_path() {
    local path="$1"

    # Keine Shell-Metazeichen erlaubt
    [[ "$path" =~ [\;\|\&\$\`\(\)\{\}\<\>] ]] && return 1

    # Muss existieren wenn required
    [[ "${2:-}" == "required" ]] && [[ ! -e "$path" ]] && return 1

    return 0
}

# Validiere Visual Mode Name
validate_visual_mode() {
    local mode="$1"
    local valid_modes=(
        "apollo-core" "code-forge" "command-center" "pixel-grid"
        "retro-wave" "neon-edge" "zen-flow" "nova-pulse"
        "crystal-bay" "star-deck" "deep-space" "command-deck"
        "command-deck-clean" "light-bridge" "cyber-matrix"
        "quantum-flux" "silicon-dawn" "frost-byte"
    )

    for valid in "${valid_modes[@]}"; do
        [[ "$mode" == "$valid" ]] && return 0
    done
    return 1
}

# ═══════════════════════════════════════════════════════════════════
# BENACHRICHTIGUNGEN
# ═══════════════════════════════════════════════════════════════════

apollo_notify() {
    local urgency="${1:-normal}"  # low, normal, critical
    local title="$2"
    local message="$3"

    # Desktop-Notification
    if command -v notify-send &>/dev/null; then
        notify-send -u "$urgency" "$title" "$message"
    fi
}

apollo_notify_tts() {
    local event="$1"

    # TTS nur wenn aktiviert und Script existiert
    if [[ -x "$TTS_SCRIPT" ]]; then
        "$TTS_SCRIPT" "$event" >/dev/null 2>&1 &
    fi
}

apollo_notify_full() {
    local urgency="$1"
    local title="$2"
    local message="$3"
    local tts_event="$4"

    apollo_notify "$urgency" "$title" "$message"
    [[ -n "$tts_event" ]] && apollo_notify_tts "$tts_event"
}

# ═══════════════════════════════════════════════════════════════════
# ABHÄNGIGKEITSPRÜFUNG
# ═══════════════════════════════════════════════════════════════════

apollo_check_deps() {
    local missing=()

    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing[*]}"
        return 1
    fi
    return 0
}

apollo_check_scripts() {
    local missing=()

    for script in "$@"; do
        if [[ ! -x "$script" ]]; then
            missing+=("$script")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing scripts: ${missing[*]}"
        return 1
    fi
    return 0
}

# ═══════════════════════════════════════════════════════════════════
# KONFIGURATION LADEN
# ═══════════════════════════════════════════════════════════════════

apollo_load_config() {
    # Lade Hauptkonfiguration
    if [[ -f "$APOLLO_CONFIG_ENV" ]]; then
        source "$APOLLO_CONFIG_ENV"
    fi

    # Lade Voice-Commands
    if [[ -f "$APOLLO_VOICE_COMMANDS" ]]; then
        source "$APOLLO_VOICE_COMMANDS"
    fi
}

apollo_get_visual_mode() {
    if [[ -f "$APOLLO_VISUAL_MODE_FILE" ]]; then
        cat "$APOLLO_VISUAL_MODE_FILE"
    else
        echo "command-deck"
    fi
}

apollo_set_visual_mode() {
    local mode="$1"

    if validate_visual_mode "$mode"; then
        echo "$mode" > "$APOLLO_VISUAL_MODE_FILE"
        return 0
    else
        log_error "Invalid visual mode: $mode"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════
# INITIALISIERUNG
# ═══════════════════════════════════════════════════════════════════

# Erstelle Verzeichnisse falls nötig
apollo_init() {
    mkdir -p "$APOLLO_CONFIG" "$APOLLO_DATA" "$APOLLO_CACHE" 2>/dev/null
    apollo_load_config
}

# Auto-Init wenn gesourced
[[ "${BASH_SOURCE[0]}" != "${0}" ]] && apollo_init
