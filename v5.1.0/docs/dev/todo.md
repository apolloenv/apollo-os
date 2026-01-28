# ✅ 04 - PROJECT TRACKER & TODO

**Status:** Initialisierung
**Aktuelles Datum:** 2026-01-11

## Phase 1: Fundament & Struktur (Scaffolding)
- [ ] Ordnerstruktur in `~/AIQSAN01/apollo/apollo-os-dev/` anlegen (wie in `02_ARCHITEKTUR` definiert).
- [ ] Leere Platzhalter-Dateien für alle Configs erstellen (Touch files).
- [ ] `install.sh` Skeleton erstellen (Executable, Shebang, Basic Logik).

## Phase 2: Core Logic (Das Gehirn)
- [ ] `scripts/apollo-daemon.py`: Basic Loop implementieren.
- [ ] `scripts/apollo-daemon.py`: Gemini API Anbindung.
- [ ] `scripts/apollo-daemon.py`: Ollama Fallback Anbindung.
- [ ] `scripts/apollo-daemon.py`: System-Stats Collection (Context Injection).
- [ ] `scripts/apollo-daemon.py`: Telegram Bot Listener.

## Phase 3: Configs & Themes (Das Gesicht)
- [ ] **Niri:**
  - [ ] `config-niri-pro-dark.kdl` erstellen.
  - [ ] `config-niri-pro-light.kdl` erstellen.
  - [ ] `config-niri-mod-dark.kdl` erstellen.
  - [ ] `config-niri-mod-light.kdl` erstellen.
- [ ] **Sway:**
  - [ ] `config-sway-pro-*` erstellen.
  - [ ] `config-sway-mod-*` erstellen.
- [ ] **Waybar:**
  - [ ] `config.jsonc` (Modular) aufbauen.
  - [ ] `style.css` (Variablen-basiert) erstellen.
- [ ] **Mako & Rofi:**
  - [ ] Inverted Themes erstellen.

## Phase 4: Integration & Installer
- [ ] `wrapper-niri.sh` und `wrapper-sway.sh` schreiben.
- [ ] `theme-switcher.sh` schreiben.
- [ ] `systemd` Units (`apollo-daemon.service`, `apollo-boot.service`) schreiben.
- [ ] `install.sh` finalisieren (Paketinstallation, Symlinking, User-Interaktion).

## Phase 5: Testing & Polishing
- [ ] Test: Offline Mode (Kabel ziehen, Chat nutzen).
- [ ] Test: Theme Switch (Alles invertiert?).
- [ ] Test: Telegram Commands.
- [ ] Code Cleanup & Kommentare.
