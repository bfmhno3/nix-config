{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.apps.wechat;
  # WeChat 4.1.13 supports native Wayland, where the compositor scale is used.
  # Its Wayland backend mis-sizes the window when QT_SCREEN_SCALE_FACTORS is
  # set, so the override only belongs to X11 sessions. There the X server
  # advertises Xft.dpi = 96 * the output scale (xrdb -query reports 192 at
  # scale 2) and Qt's xcb plugin derives its base scale factor from that.
  # QT_SCALE_FACTOR multiplies on top of it and rendered WeChat at 4x, so the
  # factor has to be an override: QT_SCREEN_SCALE_FACTORS.
  wechatLauncher = pkgs.writeShellScript "wechat" ''
    if [ -n "''${WAYLAND_DISPLAY:-}" ]; then
      unset QT_SCREEN_SCALE_FACTORS
    else
      export QT_QPA_PLATFORM=xcb
      export QT_SCREEN_SCALE_FACTORS=${toString cfg.scale}
    fi
    exec ${lib.escapeShellArg "${pkgs.wechat}/bin/wechat"} "$@"
  '';
  wechatPackage =
    if cfg.scale == null then
      pkgs.wechat
    else
      pkgs.symlinkJoin {
        name = "wechat";
        paths = [ pkgs.wechat ];
        postBuild = ''
          rm $out/bin/wechat
          ln -s ${wechatLauncher} $out/bin/wechat
        '';
      };
in
{
  options.myHome.apps.wechat = {
    enable = lib.mkEnableOption "WeChat";
    scale = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
      description = "Force WeChat's Qt screen scale factor on X11, overriding the DPI-derived scale (Xft.dpi); Wayland uses the compositor scale.";
      example = 2;
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ wechatPackage ];
  };
}
