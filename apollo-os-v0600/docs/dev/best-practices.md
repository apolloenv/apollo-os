# 🛠️ 05 - BEST PRACTICES: INSTALLATION & PAKETMANAGEMENT

Dieses Dokument dient als ergänzende Richtlinie für die Erstellung des `install.sh` und aller paketbezogenen Skripte.

## 📌 Goldene Regel für die Installation
Bevor ein Installationsbefehl abgesetzt wird, muss das Skript **proaktiv validieren**, ob die Pakete verfügbar sind und ob die notwendigen Quellen (Repositories) aktiv sind.

### 1. Repository-Check & Initialisierung
- **DNF Repos:** Prüfe vorab, ob Drittanbieter-Repos (z.B. RPM Fusion, VS Code, Google Chrome) bereits hinzugefügt wurden. Falls nicht, füge sie automatisiert hinzu.
- **COPR:** Für spezifische Pakete wie `niri` muss das entsprechende COPR-Repository (`dnf copr enable ...`) aktiviert werden, bevor die Installation startet.
- **Flatpak:** Stelle sicher, dass `flathub` als Remote hinzugefügt wurde.

### 2. Paket-Validierung (Pre-Flight Check)
Führe vor der eigentlichen Installation eine Prüfung durch:
```bash
# Beispiel für eine Prüfung
if ! dnf list available <paketname> &>/dev/null; then
    echo "⚠️ Warnung: Paket <paketname> ist in den aktuellen Repos nicht findbar."
    # Logge dies in dev-logs/ERROR_LOG.md
fi
```
- Installiere Pakete niemals "blind". Wenn ein kritisches Paket fehlt, muss das Skript pausieren oder eine klare Fehlermeldung ausgeben.

### 3. Idempotenz (Mehrfache Ausführung)
- Das Skript muss mehrmals hintereinander ausgeführt werden können, ohne Fehler zu produzieren (Idempotenz).
- Prüfe: `if ! rpm -q <paketname> &>/dev/null; then dnf install ...; fi`

### 4. Error Handling & Logging
- Jeder fehlgeschlagene Installationsversuch **muss** mit Zeitstempel in `/home/apollo/AIQSAN01/apollo/apollo-os-dev/dev-logs/ERROR_LOG.md` protokolliert werden.
- Kritische Systemkomponenten (WMs, Python, Waybar) haben Priorität. Wenn diese scheitern, sollte der Installer abbrechen.

## 📦 Spezifische Paketquellen (Beispiele)
- **Niri:** COPR `yushijinhun/niri`
- **Tuigreet:** DNF oder COPR
- **VS Code:** Microsoft Repo
- **Python-Libs:** Nutze `pip install` vorzugsweise in einem VirtualEnv oder systemweit nur, wenn über DNF nicht verfügbar.
