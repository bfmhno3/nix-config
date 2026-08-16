{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.dev.uv;
in
{
  options.myHome.dev.uv.enable = lib.mkEnableOption "uv Python package and tool manager";
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.uv ];
    home.sessionPath = [ config.xdg.binHome ];
  };
}
