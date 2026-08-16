{ config, lib, ... }:
let
  cfg = config.mySystem.hardware.battery;
in
{
  options.mySystem.hardware.battery.enable = lib.mkEnableOption "battery power management";
  config = lib.mkIf cfg.enable {
    services.power-profiles-daemon.enable = true;
  };
}
