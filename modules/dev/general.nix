{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.dev.general;
  username = config.mySystem.core.base.username;
in
{
  options.mySystem.dev.general.enable = lib.mkEnableOption "general development tools";
  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = true;
    virtualisation.docker.enable = true;
    users.users.${username}.extraGroups = [ "docker" ];
    environment.systemPackages = [ pkgs.jetbrains.clion ];
  };
}
