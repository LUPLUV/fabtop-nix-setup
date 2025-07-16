{
  description = "Fablab NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;

        # Funktion zum sicheren Passwort Hashen
        hashedPass = password: lib.mkPassword password;
      in {
        nixosConfigurations.fablaptop = pkgs.nixosSystem {
          system = "x86_64-linux";

          modules = [
            ./configuration.nix

            # Weitere Module falls gewünscht
          ];

          configuration = {
            # Basis System und User Konfiguration
            users.users.fablab = {
              isNormalUser = true;
              extraGroups = [ "dialout" "netdev" "audio" "plugdev" ];
              hashedPassword = hashedPass "fablab";
            };

            users.users.fabtop = {
              isNormalUser = true;
              extraGroups = [ "wheel" "networkmanager" "docker" ];
              hashedPassword = hashedPass "fab90763top";
              openssh.authorizedKeys.keys = [
                # "ssh-ed25519 AAAAC3... deine keys hier"
              ];
            };
          };
        };
      });
}
