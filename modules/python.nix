{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    python310FullPackages.numpy python310FullPackages.requests
    python310FullPackages.pillow python310FullPackages.pyusb
  ];
}
