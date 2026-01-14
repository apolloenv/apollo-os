# Apollo OS - Keybindings (Tastenkombinationen)

**Niri Window Manager Shortcuts**

Mod = Super/Windows-Taste

---

## 🚀 Schnellzugriff & Menüs

| Tastenkombination | Aktion |
|-------------------|--------|
| `Mod + Space` | **App Launcher** (Rofi) |
| `Mod + Shift + Space` | **Apollo Quick Menu** (System-Aktionen) |
| `Mod + Ctrl + Space` | **Wallpaper wechseln** |
| `Mod + Shift + /` | **Keybinding Hilfe** anzeigen |

---

## 🪟 Fenster-Management

| Tastenkombination | Aktion |
|-------------------|--------|
| `Mod + Q` | Fenster schließen |
| `Mod + W` | Fenster floating/tiling umschalten |
| `Mod + E` | Fenster in Spalte einfügen/auswerfen |
| `Mod + O` | Overview (Übersicht) anzeigen |
| `Mod + M` | Spalte maximieren |
| `Mod + F` | Vollbild umschalten |
| `Mod + C` | Zentrierung umschalten |
| `Mod + R` | Zwischen Spaltenbreiten wechseln |

---

## 🧭 Navigation (Fokus)

| Tastenkombination | Aktion |
|-------------------|--------|
| `Mod + ←` | Spalte links fokussieren |
| `Mod + →` | Spalte rechts fokussieren |
| `Mod + ↑` | Fenster/Workspace nach oben |
| `Mod + ↓` | Fenster/Workspace nach unten |
| `Mod + Tab` | Fenster nach unten/Spalte rechts |
| `Mod + Shift + Tab` | Fenster nach oben/Spalte links |

---

## 🔄 Fenster verschieben

| Tastenkombination | Aktion |
|-------------------|--------|
| `Mod + Alt + ←` | Spalte nach links verschieben |
| `Mod + Alt + →` | Spalte nach rechts verschieben |
| `Mod + Alt + ↑` | Fenster nach oben verschieben |
| `Mod + Alt + ↓` | Fenster nach unten verschieben |

---

## 📏 Fenster-Größe ändern

| Tastenkombination | Aktion |
|-------------------|--------|
| `Mod + Ctrl + ←` | Spalte schmaler (-10%) |
| `Mod + Ctrl + →` | Spalte breiter (+10%) |
| `Mod + Ctrl + ↑` | Fenster kürzer (-10%) |
| `Mod + Ctrl + ↓` | Fenster höher (+10%) |

---

## 🔢 Workspaces

| Tastenkombination | Aktion |
|-------------------|--------|
| `Mod + 1-9, 0` | Workspace 1-10 wechseln |

---

## 🎯 Anwendungen starten

| Tastenkombination | Aktion |
|-------------------|--------|
| `Mod + Return` | **Alacritty** (Terminal) |
| `Mod + T` | **Ptyxis** (Terminal in AIQSAN01) |
| `Mod + B` | **Firefox** (Browser) |
| `Mod + D` | **Nautilus** (Dateimanager) |
| `Mod + N` | **GNOME Text Editor** |

---

## 🖥️ System

| Tastenkombination | Aktion |
|-------------------|--------|
| `Mod + L` | **Bildschirm sperren** |
| `Mod + Shift + E` | **Abmelden** |
| `Mod + Shift + R` | **Waybar neu laden** |
| `Mod + S` | **Screenshot** (Bereich auswählen) |

---

## 🔊 Multimedia (funktionieren auch bei gesperrtem Bildschirm)

| Taste | Aktion |
|-------|--------|
| `XF86AudioRaiseVolume` | Lautstärke +5% |
| `XF86AudioLowerVolume` | Lautstärke -5% |
| `XF86AudioMute` | Ton stumm schalten |
| `XF86AudioMicMute` | Mikrofon stumm schalten |
| `XF86MonBrightnessUp` | Helligkeit +10% |
| `XF86MonBrightnessDown` | Helligkeit -10% |
| `XF86AudioPlay` | Play/Pause |
| `XF86AudioNext` | Nächster Track |
| `XF86AudioPrev` | Vorheriger Track |

---

## 🎨 Apollo Quick Menu (Mod + Shift + Space)

Das Quick Menu bietet folgende Optionen:

- 🔒 **Lock Screen** - Bildschirm sperren
- 🎨 **Toggle Theme** - Hell/Dunkel-Modus umschalten
- 📊 **Show Statistics** - System-Statistiken anzeigen
- 🖼️ **Next Wallpaper** - Nächstes Hintergrundbild
- 🔋 **Power Profiles** - Energiesparmodus wähseln
- 🔄 **Reload Waybar** - Statusleiste neu laden
- 🔄 **Reload Mako** - Benachrichtigungen neu laden
- 🚪 **Logout** - Abmelden
- 🔄 **Restart WM** - Window Manager neu starten
- 🔴 **Shutdown** - System herunterfahren
- 🔄 **Reboot** - System neu starten

---

## 💡 Tipps

### Keybinding Hilfe anzeigen
Drücke `Mod + Shift + /` um eine vollständige Übersicht aller Keybindings direkt in Niri anzuzeigen.

### Scripts in ~/.local/bin/
Alle Apollo OS Scripts werden nach `~/.local/bin/` installiert und sind über den PATH verfügbar.

### Zentrierung umschalten (Mod + C)
Schaltet zwischen zentrierter und nicht-zentrierter Ansicht der fokussierten Spalte um.

### Toggle-Center Script
Das Script `~/.config/niri/toggle-center.sh` verwaltet die Zentrierung dynamisch.

---

**Apollo OS v0.5.2** - Copyright 2025 by Manuel Kraibacher
