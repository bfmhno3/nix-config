{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.core.bat;
in
{
  options.myHome.core.bat.enable = lib.mkEnableOption "bat file viewer alias";
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.bat ];
    home.shellAliases.cat = "bat";
  };
}
