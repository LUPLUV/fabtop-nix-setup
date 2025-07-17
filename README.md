# FabLab Makerspace - NixOS Laptop Setup

## Übersicht

Dieses Setup erstellt identische Laptops für den Makerspace mit eindeutigen Hostnamen (fabtop01, fabtop02, etc.).

## Schnell-Installation

### 1. Repository klonen
```bash
sudo git clone <repository-url> /etc/nixos
cd /etc/nixos
```

### 2. Hardware-Konfiguration generieren
```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

### 3. Passwörter konfigurieren
```bash
# Passwort-Hashes generieren
mkpasswd -m sha-512 "fablab"      # Für fablab-User
mkpasswd -m sha-512 "fab90763top" # Für fabtop-User

# Hashes in configuration.nix bei hashedPassword eintragen
```

### 4. Laptop installieren
```bash
# Für fabtop01
sudo nixos-rebuild switch --flake .#fabtop01

# Für fabtop02
sudo nixos-rebuild switch --flake .#fabtop02

# Für fabtop03
sudo nixos-rebuild switch --flake .#fabtop03

# ... und so weiter
```

## Laptop-Verwaltung

### Neuen Laptop hinzufügen

1. **Hostname in flake.nix hinzufügen:**
```nix
nixosConfigurations = {
  # ... bestehende Laptops ...
  fabtop11 = makeLaptopConfig "fabtop11";
  fabtop12 = makeLaptopConfig "fabtop12";
};
```

2. **Laptop konfigurieren:**
```bash
sudo nixos-rebuild switch --flake .#fabtop11
```

### Laptop-Status überprüfen
```bash
# Hostname anzeigen
hostname

# System-Info
cat /etc/hostname-info

# Laufende Services
systemctl status autoUpdate
systemctl status appimageDownload
```

## Makerspace-spezifische Features

### Automatische Updates
- Timer läuft alle 6 Stunden
- Zieht Updates aus Git-Repository
- Wendet Konfiguration automatisch an

### Backup-System
```bash
# Backup erstellen
sudo systemctl start homeBackup

# Backup wiederherstellen
sudo systemctl start homeRestore

# Backup-Status
ls -la /var/backups/fablab-home/
```

### Vorinstallierte Software

**CAD/3D-Druck:**
- FreeCAD
- Blender
- PrusaSlicer
- Cura
- OpenSCAD

**Elektronik:**
- KiCad
- Arduino IDE
- PlatformIO

**Lasercutting:**
- VisiCut (AppImage)
- Inkscape mit VisiCut-Extension

**Entwicklung:**
- VS Code
- Python 3 + Poetry
- Node.js + Yarn
- Git
- Docker

**Maker-Tools:**
- Wireshark
- OpenOCD
- STLink-Tools
- Minicom

### AppImages
Werden automatisch heruntergeladen nach:
- `/home/fablab/Applications/VisiCut.AppImage`
- `/home/fablab/Applications/MQTT-Explorer.AppImage`
- `/home/fablab/Applications/Arduino-IDE.AppImage`

## Wartung und Administration

### Updates manuell ausführen
```bash
# Einzelnen Laptop updaten
sudo systemctl start autoUpdate

# Alle Laptops im Netzwerk (mit SSH)
for i in {01..10}; do
  ssh fabtop@fabtop$i "sudo systemctl start autoUpdate"
done
```

### Logs überprüfen
```bash
# Update-Logs
journalctl -u autoUpdate -f

# AppImage-Download-Logs
journalctl -u appimageDownload -f

# System-Logs
journalctl -b
```

### Konfiguration ändern

1. **Änderungen in Repository committen:**
```bash
git add .
git commit -m "Konfiguration aktualisiert"
git push origin main
```

2. **Updates werden automatisch auf alle Laptops verteilt**

### Laptop zurücksetzen
```bash
# Home-Verzeichnis wiederherstellen
sudo systemctl start homeRestore

# Komplette Neuinstallation
sudo nixos-rebuild switch --flake .#fabtop01 --recreate-lock-file
```

## Netzwerk-Konfiguration

### WiFi-Netzwerke
Standard: "FLN" mit Passwort "fablabnbg"

Weitere Netzwerke in `configuration.nix` hinzufügen:
```nix
networking.networkmanager.wifi.networks = {
  "FLN" = { psk = "fablabnbg"; };
  "Fablab-Guest" = { psk = "guest-password"; };
};
```

### SSH-Zugang
```bash
# Als fabtop-User (Admin)
ssh fabtop@fabtop01

# Als fablab-User
ssh fablab@fabtop01
```

## Benutzer

### fablab-User
- Standard-Benutzer für Makerspace-Mitglieder
- Passwort: `fablab`
- Vollzugriff auf alle Maker-Tools
- Docker-Berechtigung

### fabtop-User
- Admin-Benutzer für Wartung
- Passwort: `fab90763top`
- SSH-Key-Authentifizierung
- Sudo-Rechte ohne Passwort

## Troubleshooting

### Häufige Probleme

1. **Auto-Update schlägt fehl:**
```bash
# Manuell ausführen
cd /etc/nixos
sudo git pull origin main
sudo nixos-rebuild switch --flake .#$(hostname)
```

2. **AppImages funktionieren nicht:**
```bash
# Neudownload
sudo systemctl start appimageDownload
```

3. **WiFi-Probleme:**
```bash
# NetworkManager neustarten
sudo systemctl restart NetworkManager
```

4. **Backup-Problem:**
```bash
# Backup-Verzeichnis prüfen
ls -la /var/backups/fablab-home/
```

### Hardware-spezifische Anpassungen

Falls ein Laptop spezielle Hardware-Anpassungen braucht:

1. **Eigene Hardware-Konfiguration:**
```bash
# Für speziellen Laptop
sudo nixos-generate-config --show-hardware-config > hardware-configuration-fabtop01.nix
```

2. **In flake.nix referenzieren:**
```nix
fabtop01 = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./hardware-configuration-fabtop01.nix  # Spezielle Hardware
    ./configuration.nix
    { networking.hostName = "fabtop01"; }
  ];
};
```

## Monitoring

### System-Überwachung
```bash
# Alle Laptops pingen
for i in {01..10}; do
  ping -c 1 fabtop$i && echo "fabtop$i ist online"
done

# Update-Status abfragen
for i in {01..10}; do
  ssh fabtop@fabtop$i "echo -n 'fabtop$i: '; systemctl is-active autoUpdate"
done
```

### Inventar-Management
```bash
# Laptop-Informationen sammeln
for i in {01..10}; do
  echo "=== fabtop$i ==="
  ssh fabtop@fabtop$i "cat /etc/hostname-info"
  echo
done
```

## Sicherheit

- Firewall ist standardmäßig aktiviert
- SSH nur für authentifizierte Benutzer
- Automatische Updates aus vertrauenswürdiger Quelle
- Regelmäßige Backups
- Keine Root-Anmeldung möglich

## Support

Bei Problemen:
1. Logs überprüfen (`journalctl`)
2. Hardware-Konfiguration prüfen
3. Git-Repository auf Konflikte prüfen
4. Fallback: Laptop komplett neu installieren