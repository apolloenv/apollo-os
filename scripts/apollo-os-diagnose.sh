#!/bin/bash

#####################################################################
# Apollo OS - System Diagnostics Tool
# Copyright © 2026 by Manuel Kraibacher
#
# Description: AI-powered system diagnostics using journalctl
# Usage: apollo-diagnose [lines] [--service SERVICE]
#####################################################################

set -e

# Configuration
APOLLO_CONFIG="$HOME/.config/apollo-os/config.env"
TEMP_LOG="/tmp/apollo-diagnose-$$.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Parse arguments
LINES="${1:-100}"
SERVICE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --service)
            SERVICE="$2"
            shift 2
            ;;
        *)
            LINES="$1"
            shift
            ;;
    esac
done

# Load configuration
if [[ -f "$APOLLO_CONFIG" ]]; then
    source "$APOLLO_CONFIG"
else
    echo -e "${RED}ERROR: Apollo OS configuration not found${NC}"
    exit 1
fi

print_header() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}          ${BLUE}Apollo OS - System Diagnostics${NC}             ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}\n"
}

collect_logs() {
    echo -e "${YELLOW}Collecting system logs...${NC}\n"

    if [[ -n "$SERVICE" ]]; then
        echo "Analyzing service: $SERVICE"
        journalctl -u "$SERVICE" -n "$LINES" --no-pager > "$TEMP_LOG" 2>&1
    else
        echo "Analyzing last $LINES lines of system journal"
        journalctl -p err..emerg -n "$LINES" --no-pager > "$TEMP_LOG" 2>&1
    fi

    # Show preview
    echo -e "\n${CYAN}Log Preview:${NC}"
    head -20 "$TEMP_LOG" | sed 's/^/  /'
    echo "  ..."
}

analyze_with_ai() {
    echo -e "\n${YELLOW}Analyzing with AI...${NC}\n"

    # Read logs
    LOG_CONTENT=$(cat "$TEMP_LOG")

    # Create analysis prompt
    PROMPT="You are a Linux system administrator analyzing system logs.

Here are the recent system logs:

$LOG_CONTENT

Please analyze these logs and provide:
1. Summary of any errors or warnings
2. Potential causes
3. Recommended solutions
4. Severity assessment (Critical/Warning/Info)

Be concise and actionable."

    # Try Gemini first
    if [[ -n "$GEMINI_API_KEY" ]]; then
        echo "Using Gemini AI..."

        RESPONSE=$(python3 << EOF
import google.generativeai as genai
import os

genai.configure(api_key="$GEMINI_API_KEY")
model = genai.GenerativeModel("${GEMINI_MODEL:-gemini-2.0-flash}")

try:
    response = model.generate_content("""$PROMPT""")
    print(response.text)
except Exception as e:
    print(f"ERROR: {e}")
    exit(1)
EOF
)

        if [[ $? -eq 0 ]] && [[ -n "$RESPONSE" ]]; then
            echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║${NC}                  ${CYAN}AI Analysis Report${NC}                  ${GREEN}║${NC}"
            echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}\n"
            echo "$RESPONSE" | sed 's/^/  /'
            cleanup
            return 0
        fi
    fi

    # Fallback to Ollama
    if command -v ollama &>/dev/null; then
        echo "Falling back to Ollama..."

        RESPONSE=$(echo "$PROMPT" | ollama run "${OLLAMA_MODEL:-llama3.2:1b}" 2>/dev/null)

        if [[ -n "$RESPONSE" ]]; then
            echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║${NC}                  ${CYAN}AI Analysis Report${NC}                  ${GREEN}║${NC}"
            echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}\n"
            echo "$RESPONSE" | sed 's/^/  /'
            cleanup
            return 0
        fi
    fi

    echo -e "${RED}ERROR: No AI engine available${NC}"
    echo "Log file saved to: $TEMP_LOG"
    exit 1
}

cleanup() {
    rm -f "$TEMP_LOG"
}

trap cleanup EXIT

# Main execution
print_header
collect_logs
analyze_with_ai

echo -e "\n${GREEN}Analysis complete!${NC}\n"

echo -e "${CYAN}Tip: Use --service to analyze a specific systemd service${NC}"
echo -e "${CYAN}Example: apollo-diagnose 200 --service NetworkManager${NC}\n"
