{ config, lib, ... }:
let
  cfg = config.mySystem.desktop.common;
in
{
  options.mySystem.desktop.common.enable = lib.mkEnableOption "common desktop services";

  config = lib.mkIf cfg.enable {
    services = {
      printing.enable = true;
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
      geoclue2.enable = true;
    };
    security.polkit.enable = true;

  };
}
