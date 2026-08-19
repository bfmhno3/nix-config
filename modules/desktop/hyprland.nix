{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.desktop.hyprland;
  username = config.mySystem.core.base.username;
in
{
  options.mySystem.desktop.hyprland.enable = lib.mkEnableOption "Hyprland desktop";

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = false;
      xwayland.enable = true;
    };
    hardware.i2c.enable = true;
    programs.ydotool.enable = true;
    environment.systemPackages = [ (pkgs.geoclue2.override { withDemoAgent = true; }) ];
    users.users.${username}.extraGroups = [
      "video"
      "input"
      "i2c"
      config.programs.ydotool.group
    ];
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    security.pam.services.hyprlock = { };
  };
}
