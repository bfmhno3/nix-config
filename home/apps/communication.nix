{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.apps.communication;
in
{
  options.myHome.apps.communication.enable = lib.mkEnableOption "communication applications";
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.telegram-desktop
      pkgs.discord
    ];
  };
}
