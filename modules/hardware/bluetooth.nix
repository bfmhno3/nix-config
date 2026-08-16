{ config, lib, ... }:
let
  cfg = config.mySystem.hardware.bluetooth;
in
{
  options.mySystem.hardware.bluetooth.enable = lib.mkEnableOption "Bluetooth support";
  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
  };
}
