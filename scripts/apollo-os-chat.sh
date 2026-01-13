#!/bin/bash

#####################################################################
# Apollo OS - Interactive Chat Interface
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Rofi-based chat interface for Apollo AI
# Usage: apollo-os-chat.sh [initial-message]
#####################################################################

set -e

# Configuration
APOLLO_CONFIG="$HOME/.config/apollo-os/config.env"
CHAT_HISTORY="$HOME/.config/apollo-os/chat-history.txt"
TEMP_RESPONSE="/tmp/apollo-chat-response-$$.txt"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Load configuration
if [[ -f "$APOLLO_CONFIG" ]]; then
    source "$APOLLO_CONFIG"
else
    echo "ERROR: Apollo OS configuration not found"
    exit 1
fi

# Get current theme for Rofi
CURRENT_THEME="${DEFAULT_THEME:-dark}"
if [[ "$CURRENT_THEME" == "dark" ]]; then
    ROFI_THEME="$HOME/.config/rofi/apollo-os-theme-dark.rasi"
else
    ROFI_THEME="$HOME/.config/rofi/apollo-os-theme-light.rasi"
fi

# Function to get AI response
get_ai_response() {
    local user_message="$1"
    local context="$2"

    # Build prompt
    local prompt="You are Apollo, a friendly AI assistant integrated into the Apollo OS system.
The user said: $user_message

Previous context: $context

Respond naturally and helpfully. If the user asks about system information, provide relevant details.
Keep responses concise (2-3 sentences max)."

    # Try Gemini first
    if [[ -n "$GEMINI_API_KEY" ]]; then
        python3 << EOF 2>/dev/null
import google.generativeai as genai
genai.configure(api_key="$GEMINI_API_KEY")
model = genai.GenerativeModel("${GEMINI_MODEL:-gemini-2.0-flash}")
try:
    response = model.generate_content("""$prompt""")
    print(response.text)
except Exception as e:
    print("")
    exit(1)
EOF
        if [[ $? -eq 0 ]]; then
            return 0
        fi
    fi

    # Fallback to Ollama
    if command -v ollama &>/dev/null; then
        echo "$prompt" | ollama run "${OLLAMA_MODEL:-llama3.2:1b}" 2>/dev/null
    else
        echo "Apollo: I'm currently unable to respond. Please check the AI services."
    fi
}

# Function to get system info
get_system_info() {
    local query="$1"

    # Parse common system info queries
    case "${query,,}" in
        *battery*|*akku*)
            if command -v upower &>/dev/null; then
                upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "percentage|state" || echo "Battery info not available"
            else
                echo "Battery monitoring not available"
            fi
            ;;
        *disk*|*speicher*|*festplatte*)
            df -h / | tail -1 | awk '{print "Disk: " $3 " used of " $2 " (" $5 " full)"}'
            ;;
        *ram*|*memory*|*speicher*)
            free -h | grep Mem | awk '{print "RAM: " $3 " used of " $2}'
            ;;
        *cpu*|*prozessor*)
            top -bn1 | grep "Cpu(s)" | awk '{print "CPU: " $2 " user, " $4 " system"}'
            ;;
        *uptime*|*laufzeit*)
            uptime -p
            ;;
        *)
            echo ""
            ;;
    esac
}

# Main chat function
start_chat() {
    local initial_message="$1"
    local context=""

    # Load recent history
    if [[ -f "$CHAT_HISTORY" ]]; then
        context=$(tail -5 "$CHAT_HISTORY" | tr '\n' ' ')
    fi

    # Get user input
    if [[ -z "$initial_message" ]]; then
        USER_INPUT=$(rofi -dmenu -p "Chat with Apollo" \
            -theme "$ROFI_THEME" \
            -mesg "Ask me anything about your system or just chat!")
    else
        USER_INPUT="$initial_message"
    fi

    # Exit if cancelled
    if [[ -z "$USER_INPUT" ]]; then
        exit 0
    fi

    # Save to history
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] User: $USER_INPUT" >> "$CHAT_HISTORY"

    # Check if it's a system info query
    SYS_INFO=$(get_system_info "$USER_INPUT")

    if [[ -n "$SYS_INFO" ]]; then
        # Add system info to context
        context="$context System Information: $SYS_INFO"
    fi

    # Show processing notification
    notify-send "Apollo" "Thinking..." -t 2000 -i dialog-information

    # Get AI response
    AI_RESPONSE=$(get_ai_response "$USER_INPUT" "$context")

    # Save response to history
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Apollo: $AI_RESPONSE" >> "$CHAT_HISTORY"

    # Show response as notification
    notify-send "Apollo" "$AI_RESPONSE" -t 10000 -i face-smile

    # Send to Telegram if enabled
    if [[ -n "$TELEGRAM_BOT_TOKEN" ]] && [[ -n "$TELEGRAM_USER_ID" ]]; then
        python3 << EOF 2>/dev/null
from telegram import Bot
bot = Bot("$TELEGRAM_BOT_TOKEN")
bot.send_message(chat_id="$TELEGRAM_USER_ID", text="💬 You: $USER_INPUT\n\n🤖 Apollo: $AI_RESPONSE")
EOF
    fi

    # Offer to continue chat
    CONTINUE=$(echo -e "Yes\nNo" | rofi -dmenu -p "Continue chat?" \
        -theme "$ROFI_THEME" \
        -mesg "Apollo: $AI_RESPONSE")

    if [[ "$CONTINUE" == "Yes" ]]; then
        # Recursive call for continued conversation
        start_chat ""
    fi
}

# Cleanup function
cleanup() {
    rm -f "$TEMP_RESPONSE"
}

trap cleanup EXIT

# Main execution
start_chat "$@"
