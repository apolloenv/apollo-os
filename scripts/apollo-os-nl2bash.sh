#!/bin/bash

#####################################################################
# Apollo OS - Natural Language to Bash Converter
# Copyright © 2026 by Manuel Kraibacher
#
# Description: Converts natural language questions to bash commands
# Usage: ?? "how do I find large files?"
#####################################################################

set -e

# Configuration
APOLLO_CONFIG="$HOME/.config/apollo-os/config.env"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Check if query provided
if [[ $# -eq 0 ]]; then
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}        ${BLUE}Apollo OS - Natural Language Helper${NC}          ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}\n"
    echo -e "${YELLOW}Usage:${NC} ?? <your question>"
    echo -e "\n${CYAN}Examples:${NC}"
    echo -e "  ?? how do I find large files?"
    echo -e "  ?? show me system resource usage"
    echo -e "  ?? how to check disk space"
    echo -e "  ?? list all running processes"
    echo ""
    exit 1
fi

# Load configuration
if [[ -f "$APOLLO_CONFIG" ]]; then
    source "$APOLLO_CONFIG"
else
    echo -e "${RED}ERROR: Apollo OS configuration not found${NC}"
    exit 1
fi

# Get the user query
QUERY="$*"

# Create AI prompt
PROMPT="You are a helpful Linux command-line assistant.
The user asked: $QUERY

Provide:
1. The exact bash command to accomplish this (just the command, no explanation before it)
2. A brief explanation of what the command does (on a new line, starting with 'Explanation:')
3. Any important warnings or notes (optional, starting with 'Note:')

Format your response exactly like this:
COMMAND: <the actual command>
Explanation: <brief explanation>
Note: <any warnings (optional)>

Be concise and accurate. Only provide safe, commonly used commands."

echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}           ${BLUE}Apollo OS - Command Helper${NC}                ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}\n"
echo -e "${YELLOW}Query:${NC} $QUERY\n"
echo -e "${CYAN}Thinking...${NC}\n"

# Try Gemini first
AI_RESPONSE=""

if [[ -n "$GEMINI_API_KEY" ]]; then
    AI_RESPONSE=$(python3 << EOF
import google.generativeai as genai

genai.configure(api_key="$GEMINI_API_KEY")
model = genai.GenerativeModel("${GEMINI_MODEL:-gemini-2.0-flash}")

try:
    response = model.generate_content("""$PROMPT""")
    print(response.text)
except Exception as e:
    print("")
    exit(1)
EOF
)
fi

# Fallback to Ollama if Gemini failed
if [[ -z "$AI_RESPONSE" ]] && command -v ollama &>/dev/null; then
    AI_RESPONSE=$(echo "$PROMPT" | ollama run "${OLLAMA_MODEL:-llama3.2:1b}" 2>/dev/null)
fi

# Check if we got a response
if [[ -z "$AI_RESPONSE" ]]; then
    echo -e "${RED}ERROR: No AI engine available${NC}"
    exit 1
fi

# Parse the response
COMMAND=$(echo "$AI_RESPONSE" | grep -i "^COMMAND:" | sed 's/^COMMAND://i' | xargs)
EXPLANATION=$(echo "$AI_RESPONSE" | grep -i "^Explanation:" | sed 's/^Explanation://i' | xargs)
NOTE=$(echo "$AI_RESPONSE" | grep -i "^Note:" | sed 's/^Note://i' | xargs)

# Display results
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                    ${MAGENTA}Suggested Command${NC}                  ${GREEN}║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}\n"

if [[ -n "$COMMAND" ]]; then
    echo -e "${CYAN}$COMMAND${NC}\n"
else
    # If parsing failed, show full response
    echo -e "${CYAN}$AI_RESPONSE${NC}\n"
fi

if [[ -n "$EXPLANATION" ]]; then
    echo -e "${YELLOW}Explanation:${NC}"
    echo -e "  $EXPLANATION\n"
fi

if [[ -n "$NOTE" ]]; then
    echo -e "${RED}⚠ Note:${NC}"
    echo -e "  $NOTE\n"
fi

# Ask if user wants to execute
if [[ -n "$COMMAND" ]]; then
    echo -e "${YELLOW}Execute this command? [y/N]${NC} "
    read -r CONFIRM

    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo -e "\n${GREEN}Executing...${NC}\n"
        echo "─────────────────────────────────────────────────────────"
        eval "$COMMAND"
        echo "─────────────────────────────────────────────────────────"
        echo -e "\n${GREEN}✓ Command executed${NC}\n"
    else
        echo -e "\n${BLUE}Command not executed.${NC}"
        echo -e "You can copy and run it manually.\n"
    fi
fi
