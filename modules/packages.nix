{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gparted rsync screen atop htop nvtop stress tree smartmontools xrdp git vim molly-guard
    lm_sensors minicom openocd stlink-tools net-tools curl gnupg2 gnupg-agent scdaemon
    pcscd unattended-upgrades remmina gimp pdfarranger brasero handbrake vlc mumble
    keepassxc gtkterm wireshark iperf3 blender cura appimagelauncher inkscape
    python3 poetry pip pyenv python310Full zlib openssh java11OpenJDK java21OpenJDK
    virtualbox virtualboxGuestAdditions vmwareTools virt-manager inkscape-extensions.inkstitch
  ];
}
