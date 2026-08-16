{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.network;
  username = config.mySystem.core.base.username;
in
{
  options.mySystem.network.enable = lib.mkEnableOption "network analysis tools";
  config = lib.mkIf cfg.enable {
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
    users.users.${username}.extraGroups = [ "wireshark" ];
    environment.systemPackages = with pkgs; [
      wireshark
      tcpdump
      iperf3
      nmap
      mtr
      ethtool
      netcat-gnu
    ];
  };
}
