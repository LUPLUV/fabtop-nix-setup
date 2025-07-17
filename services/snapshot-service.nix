{ config, pkgs, lib, ... }:
let snapshot = ''
  ts=$(date +%Y%m%d%H%M)
  btrfs subvolume snapshot -r /home/fablab /home/.snapshots/fablab-$ts
  # älteren Snapshot löschen, außer aktuell
'';
in {
  systemd.services.fablab-snapshot = {
    Type = "oneshot";
    ExecStart = "${pkgs.bash}/bin/bash -c '${snapshot}'";
  };
  systemd.targetUnits."shutdown.target".wantedBy = [ "fablab-snapshot.service" ];
  systemd.targetUnits."reboot.target".wantedBy = [ "fablab-snapshot.service" ];
}
