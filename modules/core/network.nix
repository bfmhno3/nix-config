{ hostName, ... }:
{
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
}
