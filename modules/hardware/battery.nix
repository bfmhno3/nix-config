{ config, lib, ... }:
let
  cfg = config.mySystem.hardware.battery;
in
{
  options.mySystem.hardware.battery.enable = lib.mkEnableOption "battery power management";
  config = lib.mkIf cfg.enable {
    services.tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };
    services.power-profiles-daemon.enable = false;
  };
}
