{ config, lib, ... }:
let
  cfg = config.mySystem.desktop.plasma;
in
{
  options.mySystem.desktop.plasma.enable = lib.mkEnableOption "Plasma desktop";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.mySystem.desktop.hyprland.enable;
        message = "mySystem.desktop.plasma requires mySystem.desktop.hyprland";
      }
    ];

    services = {
      xserver = {
        enable = true;
        xkb = {
          layout = "cn";
          variant = "";
        };
      };
      displayManager = {
        sddm.enable = true;
        defaultSession = "hyprland-uwsm";
      };
      desktopManager.plasma6.enable = true;
    };
  };
}
