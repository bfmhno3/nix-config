{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.core.user;
  username = config.mySystem.core.base.username;
in
{
  options.mySystem.core.user.enable = lib.mkEnableOption "primary system user";

  config = lib.mkIf cfg.enable {
    users.groups.plugdev = { };
    users.users.${username} = {
      isNormalUser = true;
      description = username;
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"
        "networkmanager"
        "dialout"
        "plugdev"
      ];
    };

    programs.zsh.enable = true;
  };
}
