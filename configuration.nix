{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot configuration
  boot = {
    loader = {
      grub = {
        enable = true;
        device = "/dev/sda";
        useOSProber = true;
      };
      timeout = 2;
    };
  
    # Stille Boot-Konfiguration
    kernelParams = [ "quiet" "loglevel=0" "splash" ];
    loader.grub.extraConfig = ''
    set timeout=2
    set gfxmode=auto
    insmod all_video
    terminal_output gfxterm
    '';
  }

  # Hostname wird durch flake.nix gesetzt
  networking = {
    networkmanager.enable = true;
    networkmanager.wifi.enable = true;
    firewall.enable = true;
    firewall.allowedTCPPorts = [ 22 ];
    networkmanager.wifi.networks = {
      "FLN" = {
        psk = "fablabnbg";
      };
    };
  };

  # Zeit und Lokalisierung
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = "de";

  # X11 und Desktop Environment
  services.xserver = {
    enable = true;
    desktopManager.cinnamon.enable = true;
    displayManager.lightdm.enable = true;
    xkb.layout = "de";
    xkb.variant = "";
  };

  # Sound mit PipeWire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Touchpad-Konfiguration
  services.libinput.enable = true;
  services.libinput.touchpad.middleEmulation = false;

  # SSH-Service
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # Docker für Entwicklung
  virtualisation.docker.enable = true;

  # Benutzer-Konfiguration
  users.users.fablab = {
    isNormalUser = true;
    extraGroups = [ "dialout" "netdev" "audio" "plugdev" "networkmanager" "docker" ];
    hashedPassword = "$6$rounds=4096$YourSaltHere$YourHashedPasswordHere"; # Generiere mit: mkpasswd -m sha-512 "fablab"
    shell = pkgs.zsh;
  };

  users.users.fabtop = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    hashedPassword = "$6$rounds=4096$YourSaltHere$YourHashedPasswordHere"; # Generiere mit: mkpasswd -m sha-512 "fab90763top"
    openssh.authorizedKeys.keys = [
      # SSH-Keys für Admin-Zugang hier einfügen
      # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExample admin@fablab.de"
    ];
  };

  # Sudo ohne Passwort für Wheel-Gruppe
  security.sudo.wheelNeedsPassword = false;

  # Fonts für Fablab
  fonts.packages = with pkgs; [
    dejavu_fonts
    liberation_ttf
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    font-awesome
  ];

  # Makerspace-spezifische Pakete
  environment.systemPackages = with pkgs; [
    # Entwicklungstools
    git
    vim
    vscode
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.poetry
    python3Packages.numpy
    python3Packages.requests
    python3Packages.pillow
    python3Packages.pyusb
    nodejs
    yarn
    java

    # CAD und 3D-Druck
    freecad
    blender
    prusa-slicer
    cura
    openscad

    # Elektronik
    kicad
    arduino-ide
    platformio
    
    # Grafikbearbeitung
    inkscape
    gimp
    
    # Inkstitch Inkscape-Extension
    inkscape-extensions.inkstitch

    # Lasercutting und CNC
    # visicut wird als AppImage geladen
    
    # Browser
    firefox
    chromium

    # Systemtools
    htop
    nvtop
    tree
    curl
    wget
    rsync
    screen
    tmux
    gparted
    stress
    smartmontools
    lm_sensors
    
    # Netzwerk-Tools
    wireshark
    iperf3
    nmap
    minicom
    
    # Hardware-Tools
    openocd
    stlink
    
    # Archiv-Tools
    unzip
    p7zip
    
    # Multimedia
    vlc
    audacity
    
    # Kommunikation
    mumble
    
    # Sicherheit
    keepassxc
    
    # Virtualisierung
    virtualbox
    
    # Shell-Verbesserungen
    zsh
    fzf
    zsh-syntax-highlighting
    zsh-autosuggestions
    
    # Office (falls benötigt)
    libreoffice
    
    # Entwicklung
    docker-compose
    
    # Maker-Tools
    gtkterm
    remmina
    
    # AppImage-Launcher
    appimage-run
  ];

  # Programme aktivieren
  programs.zsh.enable = true;
  programs.firefox.enable = true;
  programs.wireshark.enable = true;

  # Umgebungsvariablen
  environment.variables = {
    EDITOR = "code";
    BROWSER = "firefox";
  };

  # Systemd-Services
  systemd.services = {
    # Auto-Update vom Git-Repository
    autoUpdate = {
      description = "Auto update fablab laptop configuration";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        WorkingDirectory = "/etc/nixos";
        ExecStart = pkgs.writeShellScript "auto-update" ''
          set -e
          echo "Starting auto-update for $(hostname)"
          cd /etc/nixos
          
          # Git-Repository aktualisieren
          ${pkgs.git}/bin/git fetch origin main
          ${pkgs.git}/bin/git reset --hard origin/main
          
          # System neu bauen
          ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake .#$(hostname)
          
          echo "Auto-update completed for $(hostname)"
        '';
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    # Home-Verzeichnis Backup
    homeBackup = {
      description = "Create backup of fablab home directory";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = pkgs.writeShellScript "home-backup" ''
          echo "Creating backup of /home/fablab"
          mkdir -p /var/backups/fablab-home
          ${pkgs.rsync}/bin/rsync -av --delete /home/fablab/ /var/backups/fablab-home/
          echo "Backup completed"
        '';
      };
    };

    # Home-Verzeichnis Wiederherstellung
    homeRestore = {
      description = "Restore fablab home directory from backup";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = pkgs.writeShellScript "home-restore" ''
          if [ -d "/var/backups/fablab-home" ]; then
            echo "Restoring /home/fablab from backup"
            ${pkgs.rsync}/bin/rsync -av --delete /var/backups/fablab-home/ /home/fablab/
            chown -R fablab:fablab /home/fablab
            echo "Restore completed"
          else
            echo "No backup found at /var/backups/fablab-home"
            exit 1
          fi
        '';
      };
    };

    # AppImage-Downloads
    appimageDownload = {
      description = "Download required AppImages for fablab";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = pkgs.writeShellScript "appimage-download" ''
          mkdir -p /home/fablab/Applications
          
          # VisiCut für Lasercutting
          echo "Downloading VisiCut..."
          ${pkgs.curl}/bin/curl -L -o /home/fablab/Applications/VisiCut.AppImage \
            "https://github.com/fablabnbg/VisiCut/releases/latest/download/VisiCut-Linux.AppImage"
          
          # MQTT Explorer
          echo "Downloading MQTT Explorer..."
          ${pkgs.curl}/bin/curl -L -o /home/fablab/Applications/MQTT-Explorer.AppImage \
            "https://github.com/thomasnordquist/MQTT-Explorer/releases/download/v0.4.0-beta.6/MQTT-Explorer-0.4.0-beta.6.AppImage"
          
          # Arduino IDE (neueste Version)
          echo "Downloading Arduino IDE..."
          ${pkgs.curl}/bin/curl -L -o /home/fablab/Applications/Arduino-IDE.AppImage \
            "https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.4_Linux_64bit.AppImage"
          
          # Berechtigungen setzen
          chmod +x /home/fablab/Applications/*.AppImage
          chown -R fablab:fablab /home/fablab/Applications
          
          echo "AppImage download completed"
        '';
      };
      wantedBy = [ "multi-user.target" ];
    };

    # Laptop-Identifikation
    laptopInfo = {
      description = "Display laptop information on login";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = pkgs.writeShellScript "laptop-info" ''
          cat > /etc/motd << EOF
          
          ╔══════════════════════════════════════════════════════════════════════════════╗
          ║                            FABLAB NÜRNBERG                                  ║
          ║                            Makerspace Laptop                                ║
          ║                                                                              ║
          ║  Hostname: $(hostname)                                                      ║
          ║  System:   NixOS Fablab Configuration                                       ║
          ║  User:     fablab / fabtop                                                  ║
          ║                                                                              ║
          ║  Wichtige Anwendungen:                                                       ║
          ║  - Arduino IDE, KiCad, FreeCAD, Blender                                     ║
          ║  - Inkscape, GIMP, VisiCut (Lasercutter)                                    ║
          ║  - VS Code, Firefox, Wireshark                                              ║
          ║                                                                              ║
          ║  Support: fablab-admin@fablab-nuernberg.de                                  ║
          ╚══════════════════════════════════════════════════════════════════════════════╝
          
          EOF
        '';
      };
      wantedBy = [ "multi-user.target" ];
    };
  };

  # Timer für Auto-Updates
  systemd.timers = {
    autoUpdateTimer = {
      description = "Timer for automatic updates";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5min";
        OnUnitActiveSec = "6h";  # Alle 6 Stunden
        Persistent = true;
      };
    };
  };

  # Touchpad-Konfiguration (ThinkPad-optimiert)
  environment.etc."X11/xorg.conf.d/40-libinput.conf".text = ''
    Section "InputClass"
      Identifier "libinput touchpad catchall"
      MatchIsTouchpad "on"
      MatchDevicePath "/dev/input/event*"
      Driver "libinput"
      Option "Tapping" "on"
      Option "TappingButtonMap" "lrm"
      Option "DisableWhileTyping" "on"
      Option "MiddleEmulation" "off"
      Option "ButtonMapping" "1 1 3 4 5 6 7"
    EndSection
  '';

  # Inkscape-Konfiguration für Fablab
  environment.etc."home/fablab/.config/inkscape/templates/default.svg".source = ./configurations/inkscape/default.svg;
  
  # VisiCut-Inkscape-Extension
  environment.etc."home/fablab/.config/inkscape/extensions/visicut_export.py" = {
    source = ./configurations/visicut_export.py;
    mode = "0755";
  };

  # Desktop-Hintergrund für Fablab
  services.xserver.desktopManager.cinnamon.extraGSettingsOverrides = ''
    [org.cinnamon.desktop.background]
    picture-uri='file:///usr/share/pixmaps/fablab-background.png'
  '';

  # Automatic cleanup
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # System-Version (wichtig für Upgrades)
  system.stateVersion = "24.11";
}