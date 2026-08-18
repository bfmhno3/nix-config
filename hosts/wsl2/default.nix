{
  hostName,
  stateVersion,
  username,
  ...
}:
{
  mySystem.core = {
    base = {
      enable = true;
      inherit hostName username stateVersion;
    };
    nix.enable = true;
    user.enable = true;
    locale.enable = true;
  };

  networking.hostName = hostName;

  wsl = {
    enable = true;
    defaultUser = username;
    docker-desktop.enable = true;
  };

  programs.nix-ld.enable = true;
}
