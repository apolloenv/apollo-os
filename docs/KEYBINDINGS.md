# Apollo OS v0.5.0 - Keybindings Reference

**Copyright © 2026 by Manuel Kraibacher**

Vollständige Übersicht aller Tastenkürzel für Niri Window Manager.

---

## 📌 Wichtigste Shortcuts

| Kürzel | Aktion |
|--------|--------|
| `Super + Space` | Rofi Launcher (Anwendungen starten) |
| `Super + Shift + Space` | Quick Menu (Schnellaktionen) |
| `Super + Return` | Terminal öffnen (Alacritty) |
| `Super + Q` | Fenster schließen |
| `Super + L` | Bildschirm sperren |
| `Super + Shift + ?` | Diese Keybindings anzeigen |

---

## 🪟 Fenster-Management

### Fokus verschieben
| Kürzel | Aktion |
|--------|--------|
| `Super + H` | Fokus nach links |
| `Super + J` | Fokus nach unten |
| `Super + K` | Fokus nach oben |
| `Super + L` | Fokus nach rechts |
| `Super + Left` | Fokus nach links (Pfeiltasten) |
| `Super + Down` | Fokus nach unten |
| `Super + Up` | Fokus nach oben |
| `Super + Right` | Fokus nach rechts |

### Fenster verschieben
| Kürzel | Aktion |
|--------|--------|
| `Super + Shift + H` | Fenster nach links verschieben |
| `Super + Shift + J` | Fenster nach unten verschieben |
| `Super + Shift + K` | Fenster nach oben verschieben |
| `Super + Shift + L` | Fenster nach rechts verschieben |
| `Super + Shift + Left` | Fenster nach links (Pfeiltasten) |
| `Super + Shift + Down` | Fenster nach unten |
| `Super + Shift + Up` | Fenster nach oben |
| `Super + Shift + Right` | Fenster nach rechts |

### Fenster-Größe
| Kürzel | Aktion |
|--------|--------|
| `Super + R` | Größe ändern (Resize Mode) |
| `Super + -` | Fenster schmaler |
| `Super + +` | Fenster breiter |
| `Super + Shift + -` | Fenster kleiner (Höhe) |
| `Super + Shift + +` | Fenster höher |
| `Super + F` | Fullscreen Toggle |

### Fenster-Optionen
| Kürzel | Aktion |
|--------|--------|
| `Super + Q` | Fenster schließen |
| `Super + Shift + Q` | Fenster sofort beenden |
| `Super + M` | Maximize Toggle |
| `Super + Shift + F` | Floating Window Toggle |

---

## 🗂️ Workspaces

### Navigation
| Kürzel | Aktion |
|--------|--------|
| `Super + 1` bis `9` | Zu Workspace 1-9 wechseln |
| `Super + Ctrl + Left` | Vorheriger Workspace |
| `Super + Ctrl + Right` | Nächster Workspace |
| `Super + Ctrl + H` | Scroll nach links |
| `Super + Ctrl + L` | Scroll nach rechts |
| `Super + Tab` | Workspace-Übersicht |
| `Super + O` | Overview (alle Workspaces) |

### Fenster verschieben
| Kürzel | Aktion |
|--------|--------|
| `Super + Shift + 1` bis `9` | Fenster zu Workspace 1-9 |
| `Super + Ctrl + Shift + Left` | Fenster zu vorherigem Workspace |
| `Super + Ctrl + Shift + Right` | Fenster zu nächstem Workspace |

---

## 🚀 Anwendungen & Launcher

| Kürzel | Aktion |
|--------|--------|
| `Super + Space` | Rofi Launcher (Apps) |
| `Super + Shift + Space` | Apollo Quick Menu |
| `Super + Return` | Terminal (Alacritty) |
| `Super + E` | Dateimanager (Nautilus) |
| `Super + W` | Webbrowser (Firefox/Edge) |

---

## 🎨 Theme & Wallpaper

| Kürzel | Aktion |
|--------|--------|
| `Super + Ctrl + Space` | Nächstes Wallpaper |
| `Super + Shift + T` | Theme Switcher (Dark/Light) |

---

## 📸 Screenshots

| Kürzel | Aktion |
|--------|--------|
| `Print` | Screenshot (gesamter Bildschirm) |
| `Super + Print` | Screenshot (Bereich auswählen) |
| `Super + Shift + S` | Screenshot Tool (Slurp + Grim) |

**Speicherort:** `~/Pictures/Screenshots/`

---

## 🔊 Audio & Media

| Kürzel | Aktion |
|--------|--------|
| `XF86AudioRaiseVolume` | Lautstärke erhöhen |
| `XF86AudioLowerVolume` | Lautstärke verringern |
| `XF86AudioMute` | Stummschalten Toggle |
| `XF86AudioPlay` | Play/Pause |
| `XF86AudioNext` | Nächster Track |
| `XF86AudioPrev` | Vorheriger Track |

---

## 🔆 Helligkeit

| Kürzel | Aktion |
|--------|--------|
| `XF86MonBrightnessUp` | Helligkeit erhöhen |
| `XF86MonBrightnessDown` | Helligkeit verringern |

---

## 🔐 System

| Kürzel | Aktion |
|--------|--------|
| `Super + L` | Bildschirm sperren |
| `Super + Shift + E` | Logout Menü |
| `Super + Shift + R` | Niri neu laden |
| `Ctrl + Alt + Backspace` | Niri beenden (Notfall) |

---

## 🎯 Quick Menu Aktionen

`Super + Shift + Space` öffnet das Quick Menu mit folgenden Optionen:

1. **Lock Screen** - Bildschirm sperren
2. **Logout** - Abmelden
3. **Reboot** - Neu starten
4. **Shutdown** - Herunterfahren
5. **Screenshot** - Screenshot erstellen
6. **Wallpaper** - Nächstes Wallpaper
7. **Theme** - Dark/Light Theme wechseln
8. **Audio** - Pavucontrol (Audio-Einstellungen)
9. **Network** - NetworkManager
10. **Bluetooth** - Blueman
11. **System Stats** - Systeminfo anzeigen

---

### Waybar-Interaktionen
| Aktion | Funktion |
|--------|----------|
| Klick auf Batterie | Power Profile wechseln (Energiesparmodus/Balanced/Performance) |
| Klick auf Audio | Pavucontrol öffnen |
| Klick auf Bluetooth | Blueman Manager öffnen |
| Klick auf btop Icon | System Monitor öffnen |

---

## 🔋 Power Profile Management

**Klick auf Batterie-Symbol in Waybar** wechselt zwischen:

1. **🔋 Power Saver** - Maximale Akkulaufzeit
   - CPU-Takt reduziert
   - Display-Helligkeit automatisch gedimmt
   - Hintergrund-Prozesse eingeschränkt

2. **⚖️ Balanced** - Standard-Einstellung
   - Ausgewogenes Verhältnis Leistung/Akku
   - Empfohlen für normale Nutzung

3. **⚡ Performance** - Maximale Leistung
   - CPU läuft mit vollem Takt
   - Für rechenintensive Aufgaben
   - Höherer Stromverbrauch

**Manuelle Steuerung:**
```bash
powerprofilesctl set power-saver
powerprofilesctl set balanced
powerprofilesctl set performance
powerprofilesctl get  # Aktuelles Profil anzeigen
```

---

## 📝 Niri-spezifische Features

### Scrolling Tiling
Niri verwendet ein **scrollbares** Layout:
- Workspaces sind horizontal angeordnet
- `Super + Mausrad` = horizontales Scrollen
- Neue Fenster werden rechts hinzugefügt

### Column Management
- Jedes Fenster ist in einer "Spalte"
- `Super + Shift + H/L` = Fenster zwischen Spalten verschieben
- `Super + -/+` = Spaltenbreite ändern

---

## 🔧 Anpassungen

### Eigene Keybindings hinzufügen

Editiere:
```bash
nano ~/.config/niri/config.kdl
```

Beispiel:
```kdl
binds {
    Mod+B { spawn "firefox"; }  // Firefox mit Super+B starten
}
```

Nach Änderungen:
```bash
niri msg action reload-config  # oder Super + Shift + R
```

---

## 📚 Niri Dokumentation

Offizielle Niri Docs: https://github.com/YaLTeR/niri/wiki

---

**Tipp:** Drücke `Super + Shift + ?` um diese Übersicht im Niri Overlay zu sehen!

---

**Made with ❤️ in Austria | Copyright © 2026 Manuel Kraibacher**
