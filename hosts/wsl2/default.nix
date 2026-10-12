{ config, ... }:
{
  mySystem.core = {
    nix.enable = true;
    user.enable = true;
    locale.enable = true;
  };

  mySystem.network.searxng.enable = true;

  wsl = {
    enable = true;
    defaultUser = config.mySystem.core.base.username;
    docker-desktop.enable = true;
  };

  programs.nix-ld.enable = true;
}
