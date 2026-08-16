{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.desktop.hyprland;
in
{
  options.mySystem.desktop.hyprland.enable = lib.mkEnableOption "Hyprland desktop";

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    security.pam.services.hyprlock = { };
  };
}
