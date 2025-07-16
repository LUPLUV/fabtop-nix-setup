{ stdenv, fetchurl, dpkg }:

stdenv.mkDerivation rec {
  pname = "visicut";
  version = "1.9-208";

  src = fetchurl {
    url = "https://github.com/fablabnbg/VisiCut/releases/download/v1.9-208-jw2-ruida-5-lc2bee3a-g886ab0b9/visicut_1.9-208-jw2-ruida-5-lc2bee3a-g886ab0b9-1_all.deb";
    sha256 = "<sha256-checksum-here>";
  };

  phases = [ "unpackPhase" "installPhase" ];

  unpackPhase = ''
    mkdir -p $out
    dpkg -x $src $out
  '';

  installPhase = ''
    echo "VisiCut DEB unpacked"
  '';
}
