Erstelle mir ein vollständiges, modular aufgebautes NixOS-Flake-Repository für die automatische Einrichtung und Wartung von Laptops im FabLab Nürnberg. Das Ziel ist ein wartbares, wiederholbares Setup, das wir auf verschiedenen Geräten einsetzen können.

### Projektstruktur & Flake:
- Verwende Nix Flakes.
- Unterstütze mehrere Hostnamen (z. B. fabtop01 bis fabtop10).
- Verwende `nixosConfigurations` für jedes Gerät mit `specialisation` falls nötig.
- Verwende `modules/` für modulare Komponenten (z. B. user.nix, gui.nix, packages.nix etc.).
- Ermögliche automatische Updates über GitHub bei jedem neustart.
- Integriere autoupdate via Systemd Timer + Service.

### Benutzer:
- Erstelle zwei Benutzer: `fablab` und `fabadm`.
  - Passwort-Hashes sollen konfigurierbar sein.
  - User sollen automatisch zu Gruppen wie `dialout`, `netdev`, etc. gehören.
  - Der fabadm nutzer ist der admin nutzer, er soll alles können.
  - Verwende ZSH mit fzf, zsh-autosuggestions, zsh-syntax-highlighting.
  - Ermögliche SSH-Zugriff für `fabadm`.

### Systemtools & Software:
- Installiere eine lange Liste an Tools, CLI-Tools, Devtools und GUI-Programmen (siehe unten).
- Verwende `environment.systemPackages` für Pakete aus dem Nixpkgs.
- Für `.deb`-Pakete wie Inkstitch, nutze `pkgs.stdenv.mkDerivation` mit `dpkg-deb -x`.
- Lade zwei `.AppImage` Dateien herunter (MQTT Explorer & Arduino IDE) und mache sie für `fablab` ausführbar.

### GUI & Design:
- Desktop Environment: Cinnamon
- Setze das FabLab-Logo als Boot-Splash (plymouth), Desktop-Hintergrund, Lockscreen.
- Entferne Cinnamon-Standardhintergründe.
- Passe Grub-Timeout und Kernel-Loglevel via `/etc/default/grub.d/*.cfg` an.
- Deaktiviere Touchpad-Mittelklick durch `X11 xorg.conf.d` Datei.

### Python & dev:
- Installiere Python 3 mit Pyenv, Poetry, Pip, venv, numpy, requests, pillow, usb, etc.
- Installiere Java 11 (standard) und java 21.
- Unterstütze virt-manager, virtualbox & guest additions ISO.
- Installiere VSCodium oder VSCode.

### Zusätzliche Tools:
- gparted, rsync, screen, atop, htop, nvtop, stress, tree, smartmontools, xrdp, git, vim, molly-guard, lm-sensors, minicom, openocd, stlink-tools, net-tools, curl, gnupg2, gnupg-agent, scdaemon, pcscd, unattended-upgrades, remmina, gimp, pdfarranger, brasero, handbrake, vlc, mumble, keepassxc, gtkterm, wireshark, iperf3, blender, cura, appimagelauncher, inkscape

### Custom Config:
- Füge Inkscape Templates und Extensions hinzu.
- Füge TabbedBoxMaker aus `downloads/TabbedBoxMaker` hinzu für inkscape.
- Nutze `downloads/default.svg` als standard datei für inkscape.
- Aktiviere fonts aus `fonts/`
- Setze Dateiberechtigungen korrekt auf `fablab`.

### Snapshots:
- Erstelle bei jedem Shutdown/Neustart ein Snapshot von `/home/fablab`.
- Halte jeweils den vorherigen Snapshot vor dem Überschreiben vor.
- Nutze `btrfs` und systemd units dafür.

### Deployment:
- Füge ein Bash-Skript zur interaktiven Installation hinzu (Hostname-Auswahl, Passwort-Hashing via `mkpasswd`, Klonen des Repos nach `/etc/nixos`, Konfig anpassen, `nixos-rebuild switch`, Dienste starten).
- Script muss interaktiv UND per Parametern aufrufbar sein.
- Ermögliche einheitlichen Test in VMs mit minimalem manuellem Aufwand.

### AppImage-Downloads:
- MQTT Explorer: https://github.com/thomasnordquist/MQTT-Explorer/releases/download/v0.4.0-beta.6/MQTT-Explorer-0.4.0-beta.6.AppImage
- Arduino IDE: https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.4_Linux_64bit.AppImage
- VisiCut: https://github.com/fablabnbg/VisiCut/releases/latest/download/VisiCut-Linux.AppImage

### Inkstitch:
- https://github.com/inkstitch/inkstitch/releases/latest/download/inkstitch_3.1.0_amd64.deb
- Installiere per dpkg-extraktion und bin-Verlinkung.

### Dateien im Repo:
- `flake.nix`, `flake.lock`, `hosts/*.nix`, `modules/*.nix`, `services/*.nix`
- `configurations/visicut_export.py`, `configurations/touchpad-disable-middle-click.conf`, `.fonts/`

Erstelle mir basierend darauf ein **vollständiges Git-Repository**, das ich direkt auf GitHub hochladen und zur NixOS-Installation verwenden kann. Modularisiere es übersichtlich. Beschreibe am Ende auch, was ich noch manuell anpassen oder verlinken muss (z. B. Font-Dateien, AppImages).
