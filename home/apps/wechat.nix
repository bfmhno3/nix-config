{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.apps.wechat;
  # WeChat runs on XWayland, where the X server advertises Xft.dpi = 96 * the
  # output scale (xrdb -query reports 192 at scale 2) and Qt's xcb plugin derives
  # its base scale factor from that. QT_SCALE_FACTOR multiplies on top of it and
  # rendered WeChat at 4x, so the factor has to be an override:
  # QT_SCREEN_SCALE_FACTORS.
  wechatPackage =
    if cfg.scale == null then
      pkgs.wechat
    else
      pkgs.symlinkJoin {
        name = "wechat";
        paths = [ pkgs.wechat ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/wechat \
            --set QT_SCREEN_SCALE_FACTORS "${toString cfg.scale}"
        '';
      };
in
{
  options.myHome.apps.wechat = {
    enable = lib.mkEnableOption "WeChat";
    scale = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
      description = "Force WeChat's Qt screen scale factor, overriding the DPI-derived scale (Xft.dpi on X11/XWayland).";
      example = 2;
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ wechatPackage ];
  };
}
