{ config, lib, ... }:
let
  cfg = config.myHome.apps.viewer;
in
{
  options.myHome.apps.viewer.enable = lib.mkEnableOption "document viewers";
  config = lib.mkIf cfg.enable {
    programs.zathura.enable = true;
  };
}
