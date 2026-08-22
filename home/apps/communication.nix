{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.apps.communication;
  qqPackage =
    if cfg.qqScale == null then
      pkgs.qq
    else
      pkgs.qq.override {
        commandLineArgs = "--force-device-scale-factor=${toString cfg.qqScale}";
      };
in
{
  options.myHome.apps.communication = {
    enable = lib.mkEnableOption "communication applications";
    qqScale = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      qqPackage
      pkgs.wechat
      pkgs.telegram-desktop
      pkgs.discord
    ];
  };
}
