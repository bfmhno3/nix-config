{ config, lib, ... }:
let
  cfg = config.myHome.desktop.common.fonts;
in
{
  options.myHome.desktop.common.fonts = {
    enable = lib.mkEnableOption "desktop font rendering";
    cursorSize = lib.mkOption {
      type = lib.types.int;
    };
    dpi = lib.mkOption {
      type = lib.types.int;
    };
  };

  config = lib.mkIf cfg.enable {
    xresources.properties = {
      "Xcursor.size" = cfg.cursorSize;
      "Xft.dpi" = cfg.dpi;
    };
  };
}
