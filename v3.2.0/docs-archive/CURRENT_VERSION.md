# Apollo OS v1.0.2

**Status:** Development Active  
**Created:** 2025-01-16  
**Based on:** v1.0.1

---

## 📍 Working Directory

```
/home/apollo/AIQSAN01/apollo/apollo-os-dev/v1.0.2
```

---

## 🎯 Version Goals

This version focuses on:
1. UI/UX improvements for menus
2. TTS integration for system feedback
3. Bug fixes from v1.0.1
4. Application compatibility (Synology Drive)

---

## 📋 Quick Start

### Development
```bash
cd /home/apollo/AIQSAN01/apollo/apollo-os-dev/v1.0.2
```

### Testing
```bash
# Local testing
./apollo-os-install.sh

# Remote testing
rsync -avz . apollo@192.168.0.150:~/apollo-os-v1.0.2/
```

### Git Operations
```bash
# Check status
git status

# Commit changes
git add -A
git commit -m "Description"

# Push to GitHub (when ready)
git push origin main
```

---

## 📂 Key Directories

- `scripts/` - All Apollo OS scripts
- `config-data/` - Configuration files (niri, waybar, rofi, etc.)
- `systemd/` - Systemd service files
- `assets/` - Images and resources

---

## 🔧 Recent Changes

See [RELEASE_NOTES_v1.0.2.md](RELEASE_NOTES_v1.0.2.md) for detailed changelog.

---

## 📚 Documentation

- [User Manual](APOLLO_OS_BENUTZERHANDBUCH.md)
- [Deployment Guide](DEPLOYMENT.md)
- [GitHub Setup](GITHUB_SETUP_GUIDE.md)

---

## 🧪 Testing Checklist

- [ ] Quick Menu functionality
- [ ] Power Profile TTS feedback
- [ ] Keyboard Shortcuts display
- [ ] Rofi launcher appearance
- [ ] Synology Drive startup
- [ ] Visual mode switching
- [ ] Remote deployment test

---

**Previous Version:** v1.0.1  
**Next Version:** TBD
