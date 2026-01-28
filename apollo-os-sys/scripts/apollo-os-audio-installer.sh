#!/bin/bash

#####################################################################
# Apollo OS - Audio System Installer
# Copyright © 2025 by Manuel Kraibacher
#
# Description: Installs Piper TTS, LUNA voice model, and sound effects
#####################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Paths
VOICE_DIR="$HOME/.local/share/apollo-os/voices"
SOUNDS_DIR="$HOME/.local/share/apollo-os/sounds"
SCRIPTS_DIR="$HOME/.local/bin"

#####################################################################
# Helper Functions
#####################################################################

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

#####################################################################
# Installation Steps
#####################################################################

install_packages() {
    log "Installing required packages..."
    
    # Check if packages are already installed
    if command -v piper &>/dev/null; then
        log "Piper TTS already installed ✓"
    else
        log "Installing Piper TTS..."
        sudo dnf install -y piper-tts || error "Failed to install piper-tts"
    fi
    
    # Install audio utilities
    sudo dnf install -y sox ffmpeg pulseaudio-utils || warn "Some audio packages failed"
    
    log "Packages installed ✓"
}

setup_directories() {
    log "Creating directory structure..."
    
    mkdir -p "$VOICE_DIR"
    mkdir -p "$SOUNDS_DIR"
    
    log "Directories created ✓"
}

download_voice_model() {
    log "Downloading LUNA voice model..."

    # Check if already exists
    if [ -f "$VOICE_DIR/luna.onnx" ]; then
        log "LUNA voice model already exists ✓"
        return 0
    fi

    # Download LUNA model (en_GB-jenny_dioco-medium) from Huggingface
    local voice_url="https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_GB/jenny_dioco/medium"

    log "Downloading model file (~63 MB)..."
    wget -q --show-progress \
        -O "$VOICE_DIR/luna.onnx" \
        "$voice_url/en_GB-jenny_dioco-medium.onnx" || error "Failed to download voice model"

    log "Downloading model config..."
    wget -q --show-progress \
        -O "$VOICE_DIR/luna.onnx.json" \
        "$voice_url/en_GB-jenny_dioco-medium.onnx.json" || error "Failed to download model config"

    log "LUNA voice model downloaded ✓"
}

generate_sounds() {
    log "Generating sound effects..."
    
    # Check if chime already exists
    if [ -f "$SOUNDS_DIR/chime.wav" ]; then
        log "Chime sound already exists ✓"
        return 0
    fi
    
    # Generate chime sound (880Hz -> 660Hz, 0.3s each)
    log "Generating chime sound (880Hz -> 660Hz)..."
    ffmpeg -f lavfi -i "sine=frequency=880:duration=0.3" \
           -f lavfi -i "sine=frequency=660:duration=0.3" \
           -filter_complex "[0][1]concat=n=2:v=0:a=1" \
           -y "$SOUNDS_DIR/chime.wav" 2>/dev/null || warn "Failed to generate chime"
    
    # Generate silence (for testing/padding)
    log "Generating silence..."
    ffmpeg -f lavfi -i "anullsrc=r=44100:cl=stereo" \
           -t 0.5 \
           -y "$SOUNDS_DIR/silence.wav" 2>/dev/null || warn "Failed to generate silence"
    
    log "Sound effects generated ✓"
}

install_script() {
    log "Installing apollo-speak script..."
    
    local script_source="$(dirname "$0")/apollo-speak.sh"
    
    if [ ! -f "$script_source" ]; then
        error "apollo-speak.sh not found. Please run this from the scripts directory."
    fi
    
    cp "$script_source" "$SCRIPTS_DIR/apollo-speak"
    chmod +x "$SCRIPTS_DIR/apollo-speak"
    
    log "apollo-speak installed to $SCRIPTS_DIR ✓"
}

test_audio() {
    log "Testing audio system..."
    
    if [ -f "$SCRIPTS_DIR/apollo-speak" ]; then
        log "Playing test message..."
        "$SCRIPTS_DIR/apollo-speak" "Audio system test. LUNA voice active." || warn "Test playback failed"
    else
        warn "Cannot test - apollo-speak not found"
    fi
    
    log "Audio test complete ✓"
}

#####################################################################
# Main Installation
#####################################################################

main() {
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  Apollo OS - Audio System Installer"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    
    log "Starting audio system installation..."
    
    install_packages
    setup_directories
    download_voice_model
    generate_sounds
    install_script
    
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo -e "  ${GREEN}Audio System Installation Complete!${NC}"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    
    log "Voice Model: LUNA (British, Professional)"
    log "Installation Path: $VOICE_DIR"
    log "Sounds Path: $SOUNDS_DIR"
    echo ""
    
    log "Usage Examples:"
    echo "  apollo-speak \"Hello, how are you?\""
    echo "  apollo-speak welcome"
    echo "  apollo-speak battery_low"
    echo ""
    
    read -p "Test audio system now? (Y/n): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        test_audio
    fi
    
    log "Installation complete! 🎙️"
}

# Run installer
main
