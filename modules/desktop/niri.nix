{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.desktop.niri;
  username = config.mySystem.core.base.username;
in
{
  options.mySystem.desktop.niri.enable = lib.mkEnableOption "Niri desktop";

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    services.displayManager.defaultSession = "niri";
    # Nyxuri portals.conf routes Settings, Access, and Notification to the GTK portal.
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    programs.dconf.enable = true;
    services.upower.enable = true;
    hardware.i2c.enable = true;
    users.users.${username}.extraGroups = [
      "video"
      "i2c"
    ];
    security.pam.services.noctalia = { };
    environment.systemPackages = [ pkgs.xwayland-satellite ];
    fonts.packages = [ pkgs.jetbrains-mono ];
  };
}
