{
  description = "Fablab NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";

      # Funktion um Laptop-Konfiguration zu erstellen
      makeLaptopConfig = hostname: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hardware-configuration.nix
          ./configuration.nix
          {
            networking.hostName = hostname;

            # Hostname-spezifische Konfiguration falls nötig
            environment.etc."hostname-info".text = ''
              Laptop: ${hostname}
              Konfiguration: Fablab Makerspace
              Erstellt: ${builtins.toString self.lastModified}
            '';
          }
        ];
      };
    in
    {
      # Vordefinierte Laptop-Konfigurationen
      nixosConfigurations = {
        fabtop01 = makeLaptopConfig "fabtop01";
        fabtop02 = makeLaptopConfig "fabtop02";
        fabtop03 = makeLaptopConfig "fabtop03";
        fabtop04 = makeLaptopConfig "fabtop04";
        fabtop05 = makeLaptopConfig "fabtop05";
        fabtop06 = makeLaptopConfig "fabtop06";
        fabtop07 = makeLaptopConfig "fabtop07";
        fabtop08 = makeLaptopConfig "fabtop08";
        fabtop09 = makeLaptopConfig "fabtop09";
        fabtop10 = makeLaptopConfig "fabtop10";
      };

      # Standardkonfiguration für neue Laptops
      nixosConfigurations.default = makeLaptopConfig "fabtop-new";
    };
}