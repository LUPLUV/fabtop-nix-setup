{ config, pkgs, ... }:
{
  environment.etc."/etc/fonts/conf.d/99-fablab-fonts.conf".source = ./../downloads/fonts;
}
