{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.core.grub;
  resolutions = {
    "1080p" = "1920x1080";
    "2k" = "2560x1440";
    "4k" = "3840x2160";
    ultrawide = "2560x1080";
    ultrawide2k = "3440x1440";
  };
  resolution = resolutions.${cfg.screen};
  themePackage = pkgs.grub2-theme.override {
    inherit (cfg) theme screen;
  };
in
{
  options.mySystem.core.grub = {
    enable = lib.mkEnableOption "GRUB boot loader";
    theme = lib.mkOption {
      type = lib.types.enum [
        "tela"
        "vimix"
        "stylish"
        "whitesur"
      ];
      default = "tela";
    };
    screen = lib.mkOption {
      type = lib.types.enum [
        "1080p"
        "2k"
        "4k"
        "ultrawide"
        "ultrawide2k"
      ];
      default = "1080p";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      gfxmodeEfi = "${resolution},auto";
      gfxmodeBios = "${resolution},auto";
      theme = "${themePackage}/grub/themes/${cfg.theme}";
      splashImage = "${themePackage}/grub/themes/${cfg.theme}/background.jpg";
      extraConfig = ''
        insmod gfxterm
        insmod png
        set icondir=($root)/theme/icons
      '';
    };
  };
}
