#!/usr/bin/env bash
set -e
usage() { echo "Usage: $0 [-h HOST] [-f FLakeRepo]"; exit 1; }
while getopts ":h:f:" o; do case $o in h) HOST=$OPTARG;; f) REPO=$OPTARG;; *) usage;; esac; done
: "${HOST:?Must specify hostname via -h}" "${REPO:?must specify repo}" 
PASS_FABLAB=${PASS_FABLAB:-$(mkpasswd -m sha-512)}
PASS_FABADM=${PASS_FABADM:-$(mkpasswd -m sha-512)}
git clone "$REPO" /etc/nixos
cd /etc/nixos
nix flake update
nixos-rebuild switch --flake .#"$HOST" --arg config '{ fablab.passwordHash = "'$PASS_FABLAB'"; fabadm.passwordHash = "'$PASS_FABADM'"; }'
systemctl start fablab-update.timer
