{
  pkgs,
  username,
  ...
}:
{
  programs.nix-ld.enable = true;
  virtualisation.docker.enable = true;
  users.users.${username}.extraGroups = [ "docker" ];
  environment.systemPackages = [ pkgs.jetbrains.clion ];
}
