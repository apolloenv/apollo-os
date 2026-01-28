# Apollo OS v1.0.2 Release Notes

**Release Date:** 2025-01-16  
**Type:** Feature Update & Bug Fixes

---

## 🎨 New Features

### Enhanced User Interface
- **Redesigned Quick Menu** with elegant box-style categories (╔═══╗)
  - Better visual organization
  - Improved readability with categorical grouping
  - Larger window size for better overview (750x650px)

### Keyboard Shortcuts Display
- **Fully Scrollable Layout** - No more cut-off entries
- Consistent box-style design matching Quick Menu
- Larger window (1000x700px) for complete visibility
- Better indentation and spacing

### Rofi App Launcher
- **Modern Design** with visible borders
- Improved color scheme (#4a8ae8 selection color)
- Border highlighting for selected elements
- Enhanced search field styling
- Better scrollbar visibility

---

## 🔊 Audio Feedback

### TTS Integration
- **Power Profile Switching** now includes voice feedback
  - Announces profile changes in Quick Menu
  - Announces profile changes when clicked in Waybar
  - Supports all three profiles: power-saver, balanced, performance

### New Scripts
- `apollo-os-power-profile.sh` - Power profile toggle with TTS
  - Cycles through: power-saver → balanced → performance → power-saver
  - Sends desktop notification
  - Provides voice feedback

---

## 🔧 Bug Fixes

### Quick Menu
- Fixed all case statements to match menu entries
- Corrected spacing issues between emojis and text
- Power Profiles now work correctly
- All menu items respond properly

### Synology Drive Compatibility
- Added XWayland launcher for Qt applications
- Created desktop entry with proper environment variables
- Fixed startup issues with Qt platform plugins

---

## 📦 New Files

```
scripts/apollo-os-power-profile.sh          # Power profile toggle with TTS
scripts/apollo-os-synology-drive-launcher.sh # Synology Drive XWayland wrapper
config-data/applications/synology-drive.desktop # Desktop entry for Synology Drive
```

---

## 🔄 Updated Files

```
scripts/apollo-os-quickmenu.sh              # Redesigned with box-style
scripts/apollo-os-shortcuts.sh              # Fully scrollable layout
scripts/apollo-os-update.sh                 # Version bump to v1.0.2
scripts/apollo-os-visual-mode.sh            # Version bump to v1.0.2
config-data/rofi/config.rasi                # Modern styling with borders
apollo-os-install.sh                        # Version bump to v1.0.2
```

---

## 🎯 Testing Recommendations

1. **Quick Menu** (Super+Shift+Space)
   - Test all menu items for responsiveness
   - Try Power Profiles with TTS feedback

2. **Keyboard Shortcuts**
   - Open from Quick Menu
   - Verify all entries are visible and scrollable

3. **App Launcher** (Super+Space)
   - Check new visual styling
   - Test scrolling with many applications

4. **Power Profiles**
   - Click Waybar power icon to cycle profiles
   - Verify TTS announcements

5. **Synology Drive**
   - Launch from App Launcher
   - Verify it opens without Qt errors

---

## 📋 Known Issues

- Synology Drive requires first-time setup configuration
- Some debug messages visible during Synology Drive startup (cosmetic only)

---

## 🔗 Upgrade Instructions

### From v1.0.1 to v1.0.2

**Option 1: Update Script**
```bash
~/.local/bin/apollo-os-update.sh
```

**Option 2: Manual Installation**
```bash
cd ~/apollo-os-v1.0.2
./apollo-os-install.sh
```

---

## 🙏 Acknowledgments

Special thanks to all testers who provided feedback on menu usability and TTS features.

---

**Previous Release:** [v1.0.1 Release Notes](RELEASE_NOTES_v1.0.1.md)
