{ config, pkgs, ... }:
{
  fileSystems."/home" = {
    fsType = "btrfs";
    device = "/dev/sdxN"; # anpassen
    mountOptions = [ "compress=zstd" ];
  };
}
