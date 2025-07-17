{ config, pkgs, ... }:

let
  fetchApp = name: url: sha256:
    pkgs.runCommand name {
      src = pkgs.fetchurl {
        url = url;
        sha256 = sha256;
      };
    } ''
      mkdir -p $out/bin
      cp $src $out/bin/${name}.AppImage
      chmod +x $out/bin/${name}.AppImage
    '';
in {
  environment.systemPackages = [
    (fetchApp "MQTT-Explorer" "https://github.com/thomasnordquist/MQTT-Explorer/releases/download/v0.3.5/MQTT-Explorer-0.3.5.AppImage"
      "03kfc185ajgc88pwjamy8ri6pvz5d5dn59l3q3qis8smwzdziz31")
    (fetchApp "Arduino-IDE" "https://github.com/arduino/arduino-ide/releases/download/2.3.6/arduino-ide_2.3.6_Linux_64bit.AppImage"
      "16ga1qx0f4z0hzg8l3ci1gg6cyd7fw0xzxdv29shpg3431fpm76x")
    (fetchApp "VisiCut" "https://github.com/fablabnbg/VisiCut/releases/download/v1.9-208-jw2-ruida-5-lc2bee3a-g886ab0b9/VisiCut-1.9-208-jw2-ruida-5-lc2bee3a-g886ab0b9-x86_64.AppImage"
      "0v9vlcx5isszz6djgxhjcczspvqh116h5yfxvqalz8scan1cmbhr")
  ];
}
