{ config, lib, ... }:
let
  cfg = config.mySystem.network.clashVerge;
in
{
  options.mySystem.network.clashVerge.enable =
    lib.mkEnableOption "Clash Verge Rev with TUN via its service";

  config = lib.mkIf cfg.enable {
    programs.clash-verge = {
      enable = true;
      serviceMode = true;
    };

    # Proxied replies injected on the TUN device are dropped by strict reverse path
    # filtering (nixpkgs#477636); trustedInterfaces does not exempt rpfilter here.
    networking.firewall.checkReversePath = "loose";
  };
}
