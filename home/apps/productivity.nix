{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.apps.productivity;
in
{
  options.myHome.apps.productivity.enable = lib.mkEnableOption "productivity applications";
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      google-chrome
      kdePackages.kate
      localsend
      easytier
      texlive.combined.scheme-full
      google-drive-ocamlfuse
      zotero
      obsidian
      typora
      drawio
      freecad
      imhex
      inkscape
      rpi-imager
      zeal
      zed-editor
      serial-studio
      tio
      thunar
    ];
  };
}
