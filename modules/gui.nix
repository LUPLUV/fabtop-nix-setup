{ config, pkgs, ... }:
{
  services.xserver.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

  environment.etc."plymouth/themes/fablab-logo/".source = "/etc/nixos/downloads/fln2_wide.png";
  services.plymouth.enable = true;

  # Hintergrund & Lockscreen
  environment.variables = {
    FABLAB_WALLPAPER = "/etc/nixos/static/fln2_wide.png";
  };
  services.gnome.gdm.background = config.environment.variables.FABLAB_WALLPAPER;

  # Grub-Plymouth-Konfig
  boot.loader.grub = {
    enable = true;
    timeout = 5;
    extraConfig = ''
      GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3"
    '';
  };
}
