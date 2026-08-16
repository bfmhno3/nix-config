{ config, lib, ... }:
let
  cfg = config.mySystem.hardware.nvidia;
in
{
  options.mySystem.hardware.nvidia.enable = lib.mkEnableOption "NVIDIA graphics";
  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware = {
      graphics.enable = true;
      nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
    };
  };
}
