{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.apps.ccSwitch;
in
{
  options.myHome.apps.ccSwitch.enable = lib.mkEnableOption "the CC Switch desktop provider manager";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.cc-switch ];
  };
}
