{ config, lib, ... }:
let
  cfg = config.mySystem.core.network;
in
{
  options.mySystem.core.network.enable = lib.mkEnableOption "core networking";

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;

    services.openssh = {
      enable = true;
      settings = {
        X11Forwarding = true;
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
      openFirewall = true;
    };
  };
}
