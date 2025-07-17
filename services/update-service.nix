{ config, pkgs, lib, ... }:

let script = ''
  cd /etc/nixos
  git pull origin main
  nixos-rebuild switch --flake .#$(hostname)
'';

in {
  systemd.timers.fablab-update = {
    description = "Update Flake and apply config";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "1d";
    };
    unitConfig = {
      Wants = [ "fablab-update.service" ];
    };
  };

  systemd.services.fablab-update = {
    description = "Update flake and switch configuration";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${script}'";
    };
  };
}
