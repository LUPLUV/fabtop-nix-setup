{
  description = "FabLab Nürnberg laptop flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: rec {
    nixosConfigurations = builtins.listToAttrs (map (hostnm: {
      name = hostnm;
      value = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./modules/user.nix
          ./modules/gui.nix
          ./modules/packages.nix
          ./modules/appimages.nix
          ./modules/python.nix
          ./modules/fonts.nix
          ./modules/snapshots.nix
          ./services/update-service.nix
          ./services/snapshot-service.nix
          { config, pkgs, ... }: {
            imports = [ ./configurations/touchpad-disable-middle-click.conf ];
            networking.hostName = hostnm;
          }
        ];
      };
    }) (builtins.mapAttrsToList (name: _: name) (builtins.readDir ./hosts)))
  };
}
