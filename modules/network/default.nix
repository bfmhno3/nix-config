{
  pkgs,
  username,
  ...
}:
{
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
}
