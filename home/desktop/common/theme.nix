{ config, lib, ... }:
let
  cfg = config.myHome.desktop.common.theme;
in
{
  options.myHome.desktop.common.theme.enable = lib.mkEnableOption "desktop theme integration";
  config = lib.mkIf cfg.enable {
    gtk.enable = false;
    home.sessionVariables = {
      QT_IM_MODULE = "fcitx";
      QT_QPA_PLATFORMTHEME = lib.mkForce "kde";
    };
    qt = {
      enable = true;
      platformTheme.name = "kde";
    };
  };
}
