{ config, pkgs, ... }:
{
  users.users = {
    fablab = {
      isNormalUser = true;
      extraGroups = [ "dialout" "netdev" "widgetkit" "video" ];
      shell = pkgs.zsh;
      password = config.lib.mkDefault config.fablab.passwordHash;
    };
    fabadm = {
      isNormalUser = true;
      isRoot = false;
      extraGroups = [ "wheel" "dialout" "netdev" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAnjPAjJolbiamuD7BydWbvLMtoId+4JCJ6i1Hokfkr thore@fablab"
      ];
      password = config.lib.mkDefault config.fabadm.passwordHash;
    };
  };

  services.openssh.enable = true;
  services.openssh.allowUsers = [ "fabadm" ];
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ pkgs.zsh-autosuggestions pkgs.zsh-syntax-highlighting pkgs.fzf ];
    };
  };
}
