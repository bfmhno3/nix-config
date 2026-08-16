{ config, lib, ... }:
let
  cfg = config.myHome.desktop.terminals.foot;
in
{
  options.myHome.desktop.terminals.foot.enable = lib.mkEnableOption "Foot terminal";
  config = lib.mkIf cfg.enable {
    programs.foot.enable = true;
  };
}
