# Gemini AI Integration (Optional Local Extension)

**Status:** Optional - Not included in standard installation  
**Type:** Local customization only  
**Security:** API keys and implementation remain on local system only

---

## ⚠️ Important Notice

**This feature is NOT part of the default Apollo OS installation.**

- Gemini AI integration is a **local-only enhancement**
- No API keys or Gemini-related code are stored in the repository
- This is documentation only for future reference
- Users must implement this themselves if desired

---

## 📋 Overview

Gemini AI Voice integration allows natural language voice commands through Google's Gemini API instead of just predefined commands.

### Standard System (Default)
- Uses Vosk for offline wake word detection
- Predefined commands only (see below)
- No API calls, fully offline
- Included in standard installation

### Optional Gemini Enhancement (Local Only)
- Extends voice commands with AI understanding
- Natural language processing
- Requires Google Gemini API key
- Must be implemented locally by user

---

## 🎤 Standard Voice Commands (Included)

Wake word: **"apollo"**

1. **🕐 Uhrzeit**: "apollo wie spät ist es" / "apollo uhrzeit"
2. **📅 Datum**: "apollo welcher tag ist heute" / "apollo datum"
3. **💻 Terminal**: "apollo terminal öffnen"
4. **🌐 Browser**: "apollo browser starten" / "apollo web starten"
5. **🔒 Sperren**: "apollo sperren" / "apollo sperre"
6. **💤 Ruhemodus**: "apollo ausschalten" / "apollo herunterfahren"
7. **🔄 Neustart**: "apollo neustart" / "apollo neu starten"
8. **👋 Status**: "apollo" (responds with acknowledgment)

---

## 🤖 Gemini Toggle System (Quick Menu Integration)

### Implementation in Quick Menu

Added to `apollo-os-quickmenu.sh`:

```bash
"🤖  Gemini AI Voice")
    GEMINI_FLAG="$HOME/.config/apollo-os/gemini-enabled"
    
    if [ -f "$GEMINI_FLAG" ]; then
        current_status="🟢 Enabled"
    else
        current_status="🔴 Disabled"
    fi
    
    # Toggle menu...
    # Creates/removes flag file
    ;;
```

### Flag File System

**Location:** `~/.config/apollo-os/gemini-enabled`

- **Exists** = Gemini AI is enabled
- **Missing** = Standard commands only

### Usage in Scripts

Check if Gemini is enabled:

```bash
if [ -f "$HOME/.config/apollo-os/gemini-enabled" ]; then
    # Use Gemini AI integration
else
    # Use standard predefined commands
fi
```

---

## 🔧 Local Implementation Guide (Not Automated)

If you want to add Gemini AI support locally:

### 1. Get Gemini API Key
- Sign up at [Google AI Studio](https://makersuite.google.com/app/apikey)
- Generate API key
- **Never commit this to repository!**

### 2. Store API Key Securely
```bash
mkdir -p ~/.config/apollo-os
echo "YOUR_API_KEY" > ~/.config/apollo-os/gemini-api-key
chmod 600 ~/.config/apollo-os/gemini-api-key
```

### 3. Modify Wake Listener
Add Gemini API call in `apollo-wake-listener.py`:

```python
def execute_command_with_gemini(command_text):
    """Optional: Use Gemini AI for natural language"""
    gemini_flag = os.path.expanduser("~/.config/apollo-os/gemini-enabled")
    
    if not os.path.exists(gemini_flag):
        # Fall back to standard commands
        execute_command(command_text)
        return
    
    # Your Gemini API implementation here
    # (not included in repository)
```

### 4. Add to .gitignore
Ensure sensitive files are ignored:

```
.config/apollo-os/gemini-api-key
.config/apollo-os/gemini-enabled
*gemini*api*
```

---

## 🔒 Security Best Practices

1. **Never commit API keys** to version control
2. **Store keys locally only** in `~/.config/apollo-os/`
3. **Use file permissions** (chmod 600) for key files
4. **Keep implementation private** - don't push Gemini code
5. **Document but don't implement** in public repository

---

## 📊 Architecture

```
Standard Flow (Default):
User → Wake Word "apollo" → Vosk → Predefined Commands → Action

Optional Gemini Flow (Local Only):
User → Wake Word "apollo" → Check Flag → Gemini API → AI Response → Action
                                      ↓
                              Flag Missing? → Predefined Commands
```

---

## 🎯 Summary

- **Standard system**: Offline, secure, predefined commands
- **Gemini enhancement**: Optional, requires local setup, AI-powered
- **Toggle system**: Easy enable/disable via Quick Menu
- **Security**: No API keys or Gemini code in repository
- **Documentation**: This file explains the concept only

---

**Last Updated:** 2026-01-20  
**Apollo OS Version:** v2.1.0
