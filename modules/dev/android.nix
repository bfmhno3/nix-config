{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.dev.android;
  username = config.mySystem.core.base.username;
in
{
  options.mySystem.dev.android.enable = lib.mkEnableOption "Android development tools";
  config = lib.mkIf cfg.enable {
    users.users.${username}.extraGroups = [ "adbusers" ];
    environment.systemPackages = [
      pkgs.android-studio
      pkgs.android-tools
    ];
  };
}
