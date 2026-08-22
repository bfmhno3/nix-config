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
  wechatPackage =
    if cfg.wechatScale == null then
      pkgs.wechat
    else
      pkgs.symlinkJoin {
        name = "wechat";
        paths = [ pkgs.wechat ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/wechat \
            --set QT_SCALE_FACTOR "${toString cfg.wechatScale}"
        '';
      };
in
{
  options.myHome.apps.communication = {
    enable = lib.mkEnableOption "communication applications";
    qqScale = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
    };
    wechatScale = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      qqPackage
      wechatPackage
      pkgs.telegram-desktop
      pkgs.discord
    ];
  };
}
