{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.apps.remoteDesktop;
in
{
  options.myHome.apps.remoteDesktop.enable = lib.mkEnableOption "remote desktop clients";
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.unstable.remmina ];
  };
}
