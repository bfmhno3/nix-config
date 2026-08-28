{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.network.localsend;
in
{
  options.mySystem.network.localsend.enable = lib.mkEnableOption "LocalSend";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.localsend ];
    networking.firewall = {
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };
  };
}
