# Apollo OS Professional - Anpassungen & Konfiguration

Dieses Dokument beschreibt alle vorgenommenen Änderungen am System und wo man welche Einstellungen findet.

## Übersicht der Änderungen

### 1. Hyprland Konfiguration

#### Tastatur-Layout
- **Geändert:** US → DE (Deutsch)
- **Datei:** `dots/.config/hypr/hyprland/general.conf`
- **Zeile 121:** `kb_layout = de`

#### Bildschirmskalierung
- **Wert:** 1.0 (100%)
- **Datei:** `dots/.config/hypr/monitors.conf`
- **Zeile 6:** `monitor=eDP-1,1920x1080@60.03,0x0,1.0`

#### Fenster-Abstände (Gaps)
- **gaps_out:** 10 (verdoppelt von 5)
- **gaps_in:** 4 (unverändert)
- **Datei:** `dots/.config/hypr/hyprland/general.conf`
- **Zeilen 20-21**

#### Fenster-Transparenz
- **Aktive Fenster:** 90% Opacity
- **Inaktive Fenster:** 40% Opacity
- **Datei:** `dots/.config/hypr/hyprland/general.conf`
- **Zeilen 54-55:** 
  ```
  active_opacity = 0.90
  inactive_opacity = 0.40
  ```

#### Fenster-Borders
- **Border Size:** 0 (entfernt)
- **Datei:** `dots/.config/hypr/hyprland/general.conf`
- **Zeile 24:** `border_size = 0`

#### Fenster-Schatten
- **Aktiviert:** Ja
- **Eigenschaften:**
  - Range: 20
  - Offset: 0 8
  - Render Power: 3
  - Color: rgba(00000099)
- **Datei:** `dots/.config/hypr/hyprland/general.conf`
- **Zeilen 75-81**

#### Blur & Transparenz für Fenster
- **No-blur Regel entfernt** für alle Fenster
- **Blur aktiviert** mit bestehenden decoration-Einstellungen
- **Dateien:**
  - `dots/.config/hypr/hyprland/rules.conf` (Zeilen 7-8)
  - `dots/.config/hypr/custom/rules.conf` (Zeile 8)

#### Hintergrundfarbe
- **Farbe:** #000000 (Schwarz)
- **Datei:** `dots/.config/hypr/hyprland/colors.conf`
- **Zeile 9:** `background_color = rgba(000000FF)`

### 2. Quickshell (UI) Konfiguration

#### Bar-Anpassungen

##### "APOLLO OS" Text
- **Position:** Links in der Bar (nach AI-Logo)
- **Linksbündig ausgerichtet**
- **Datei:** `dots/.config/quickshell/ii/modules/ii/bar/BarContent.qml`
- **Zeilen 92-100**

##### Medien-Widget
- **Entfernt** aus der Bar-Mitte
- **Datei:** `dots/.config/quickshell/ii/modules/ii/bar/BarContent.qml`

##### Wetter-Widget
- **Position:** Rechts in der Bar, links von der Uhrzeit
- **Datei:** `dots/.config/quickshell/ii/modules/ii/bar/BarContent.qml`
- **Zeilen 278-286**

##### Ressourcen & Uhrzeit
- **Position:** Ganz rechts in der Bar
- **Reihenfolge:** Wetter → Uhrzeit → Ressourcen → System-Buttons
- **Datei:** `dots/.config/quickshell/ii/modules/ii/bar/BarContent.qml`

##### Uhrzeit-Format
- **Format:** hh:mm (ohne Sekunden)
- **Kein Datum** neben der Uhrzeit
- **Datei:** `dots/.config/quickshell/ii/modules/ii/bar/ClockWidget.qml`

##### Workspaces
- **Mitte der Bar** positioniert
- **Zeigt alle konfigurierten Workspaces**

#### Sidebar-Anpassungen

##### Anime-Button entfernt
- **Aus linker Sidebar entfernt**
- **Datei:** `dots/.config/quickshell/ii/modules/ii/sidebarLeft/SidebarLeftContent.qml`
- **Zeilen 19-23 und 86-91**

#### Einstellungen

##### "Über"-Tab entfernt
- **Aus Einstellungsfenster entfernt**
- **Datei:** `dots/.config/quickshell/ii/settings.qml`
- **Zeilen 55-67**

#### Appearance (Farben)

##### Hintergrund & Surface
- **m3background:** #000000 (Schwarz)
- **m3surface:** #000000 (Schwarz)
- **m3surfaceDim:** #000000 (Schwarz)
- **Datei:** `dots/.config/quickshell/ii/modules/common/Appearance.qml`
- **Zeilen 40-43**

#### Transparenz-Einstellungen

##### Config.json
- **extraBackgroundTint:** false
- **backgroundTransparency:** 0.15
- **Datei:** `~/.config/illogical-impulse/config.json`
- **Hinweis:** Diese Datei wird beim ersten Start erstellt

### 3. Shortcuts (Tastenkombinationen)

#### Geänderte Shortcuts
- **Super + K:** Cheatsheet/Shortcuts anzeigen (vorher: Virtuelle Tastatur)
- **Super + /:** Virtuelle Tastatur (vorher: Cheatsheet)
- **Datei:** `dots/.config/hypr/hyprland/keybinds.conf`
- **Zeilen 33-34**

### 4. System-Services

#### Mako Notifications
- **Deaktiviert:** Mako-Service gestoppt und disabled
- **Grund:** Verhindert Konflikte mit Quickshell's Notification-System
- **Befehl:** `systemctl --user disable mako.service`

## Wichtige Konfigurationsdateien

### Hyprland
```
dots/.config/hypr/
├── hyprland.conf              # Haupt-Konfiguration (lädt andere Dateien)
├── monitors.conf              # Monitor-Einstellungen & Skalierung
├── hyprland/
│   ├── general.conf          # Allgemeine Einstellungen, Gaps, Borders, Transparenz, Schatten
│   ├── colors.conf           # Farben & Hintergrund
│   ├── keybinds.conf         # Tastenkombinationen
│   └── rules.conf            # Fenster-Regeln, Blur, Opacity
└── custom/
    └── rules.conf            # Benutzerdefinierte Fenster-Regeln
```

### Quickshell
```
dots/.config/quickshell/ii/
├── settings.qml                           # Einstellungsfenster
├── modules/
│   ├── common/
│   │   └── Appearance.qml                # Farben & Theme
│   └── ii/
│       ├── bar/
│       │   ├── BarContent.qml            # Bar-Layout
│       │   ├── ClockWidget.qml           # Uhrzeit-Widget
│       │   └── Workspaces.qml            # Workspace-Anzeige
│       └── sidebarLeft/
│           └── SidebarLeftContent.qml    # Linke Sidebar
```

## Tipps zur Anpassung

### Transparenz ändern
1. **Hyprland:** `dots/.config/hypr/hyprland/general.conf` → `active_opacity` / `inactive_opacity`
2. **Quickshell:** `~/.config/illogical-impulse/config.json` → `appearance.transparency.backgroundTransparency`

### Bar-Layout ändern
- **Datei:** `dots/.config/quickshell/ii/modules/ii/bar/BarContent.qml`
- **Widgets umsortieren:** Elemente im `rightSectionRowLayout` verschieben
- **layoutDirection: Qt.RightToLeft** bedeutet: Rechts nach Links Anordnung

### Shortcuts anpassen
- **Datei:** `dots/.config/hypr/hyprland/keybinds.conf`
- **Format:** `bind = Modifier, Key, Action, Parameters # Beschreibung`
- **Modifier:** Super, Shift, Ctrl, Alt

### Farben anpassen
- **System-Hintergrund:** `dots/.config/hypr/hyprland/colors.conf` → `background_color`
- **Quickshell-Theme:** `dots/.config/quickshell/ii/modules/common/Appearance.qml` → `m3colors`

## Änderungen neu laden

```bash
# Hyprland neu laden
hyprctl reload

# Quickshell neu starten
pkill quickshell
qs -c ii &
```

## Problembehebung

### Bar wird nicht angezeigt
1. Quickshell-Logs prüfen: `journalctl --user -u quickshell -n 50`
2. Manuell starten: `qs -c ii`

### Transparenz funktioniert nicht
1. Prüfen: `hyprctl getoption decoration:active_opacity`
2. Blur aktiviert?: `hyprctl getoption decoration:blur:enabled`

### Shortcuts funktionieren nicht
1. Hyprland neu laden: `hyprctl reload`
2. Keybinds prüfen: `hyprctl binds`

---

**Erstellt:** 21.01.2026  
**Version:** Apollo OS Professional v1.0.1  
**Basierend auf:** illogical-impulse (end-4's dots-hyprland)
