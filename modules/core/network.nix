{ config, lib, ... }:
let
  cfg = config.mySystem.core.network;
  hostName = config.mySystem.core.base.hostName;
in
{
  options.mySystem.core.network.enable = lib.mkEnableOption "core networking";

  config = lib.mkIf cfg.enable {
    networking = {
      inherit hostName;
      networkmanager.enable = true;
      firewall.enable = false;
    };

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
