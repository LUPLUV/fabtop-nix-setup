{ config, pkgs, ... }:

{
  imports = [ ];

  # System
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.enable = true;
  networking.networkmanager.wifi.networks = {
    "FLN" = {
      psk = "fablabnbg"; # Anpassen!
    };
  };

  # SSH
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = true;

  # Desktop Environment
  services.xserver.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

  # Fonts
  fonts.fontsDir = "/usr/share/fonts/FabLab";

  environment.systemPackages = with pkgs; [
    cinnamon inkscape google-chrome prusaslicer freecad kicad java python3 pyenv
    visual-studio-code gparted rsync screen atop htop nvtop stress tree smartmontools xrdp
    git vim molly-guard lm_sensors minicom openocd stlink-tools net-tools curl gnupg2 gnupg-agent
    scdaemon pcscd unattended-upgrades zsh fzf zsh-syntax-highlighting zsh-autosuggestions remmina
    gimp pdfarranger brasero handbrake vlc mumble keepassxc gtkterm python-is-python3 python3-poetry
    python3-pip python3-virtualenv python3-venv python3-numpy python3-requests python3-usb python3-pil
    virtualbox virtualbox-guest-additions-iso virt-manager blender cura appimagelauncher wireshark
    iperf3 inkstitch
  ];

  # Inkstitch DEB (über pkgs/visicut)
  environment.systemPackages = with pkgs; [
    (import ./pkgs/visicut/default.nix)
  ] ++ environment.systemPackages;

  # AppImages via systemd Service (siehe weiter unten)

  # GRUB Anpassungen
  environment.etc."default/grub.d/90_fln-fix-30s-timeout.cfg".text = ''
    GRUB_RECORDFAIL_TIMEOUT=0
  '';

  environment.etc."default/grub.d/90_fln-no-kernel-messages.cfg".text = ''
    GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=0 splash"
  '';

  # Touchpad config
  environment.etc."X11/xorg.conf.d/touchpad-disable-middle-click.conf".source = ./configurations/touchpad-disable-middle-click.conf;

  # Fonts (copy)
  environment.etc."usr/share/fonts/FabLab".source = ./fonts;

  # InkScape Templates & Extensions
  environment.etc."home/fablab/.config/inkscape/templates/default.svg".source = ./configurations/inkscape/default.svg;
  environment.etc."home/fablab/.config/inkscape/extensions".source = ./downloads/inkscape/TabbedBoxMaker-master;

  # FLN Wifi Desktop File
  environment.etc."home/fablab/.config/autostart/FLN-wifi_at_login.desktop".source = ./services/FLN-wifi_at_login.desktop;

  # visicut_export.py
  environment.etc."home/fablab/.config/inkscape/extensions/visicut_export.py".source = ./configurations/visicut_export.py;

  # Home Snapshot Service (einfacher rsync Snapshot)
  systemd.services.homeSnapshot = {
    description = "Snapshot / Reset /home/fablab";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        rsync -a --delete /home/fablab/ /var/backups/fablab-home-snapshot/
      '';
      ExecStop = ''
        rsync -a --delete /var/backups/fablab-home-snapshot/ /home/fablab/
      '';
      RemainAfterExit = true;
    };
    wantedBy = [ "multi-user.target" ];
    before = [ "shutdown.target" ];
  };

  # Auto Update Service & Timer (git pull + nixos-rebuild switch)
  systemd.services.autoUpdate = {
    description = "Auto update flake config";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        cd /etc/nixos
        git pull origin main
        nixos-rebuild switch --flake .#fablaptop
      '';
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.timers.autoUpdateTimer = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "12h";
    };
  };

  # AppImage Download Service
  systemd.services.appimageDownload = {
    description = "Download AppImages for fablab user";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        mkdir -p /home/fablab/Apps
        curl -L -o /home/fablab/Apps/MQTT-Explorer.AppImage https://github.com/thomasnordquist/MQTT-Explorer/releases/download/v0.4.0-beta.6/MQTT-Explorer-0.4.0-beta.6.AppImage
        curl -L -o /home/fablab/Apps/arduino-ide.AppImage https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.4_Linux_64bit.AppImage
        chmod +x /home/fablab/Apps/*.AppImage
        chown -R fablab:fablab /home/fablab/Apps
      '';
    };
    wantedBy = [ "multi-user.target" ];
  };

  # zsh as default shell for fablab
  users.users.fablab.shell = pkgs.zsh;

  # Set desktop background & logo (Beispiel mit gsettings overrides)
  services.xserver.desktopManager.cinnamon.extraGSettingsOverrides = {
    "org.cinnamon.desktop.background picture-uri" = "file:///static/fln2_wide.png";
  };

  # Boot logo kann über GRUB angepasst werden (z.B. im extraConfig)
  boot.loader.grub.enable = true;
  boot.loader.grub.extraConfig = ''
    set gfxmode=auto
    insmod all_video
    terminal_output gfxterm
    background_image /static/fln2_wide.png
  '';

  # SSH mit Passwort & Key Login möglich
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = true;

}
