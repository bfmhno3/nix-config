{ config, lib, ... }:
let
  cfg = config.mySystem.desktop.gaming;
in
{
  options.mySystem.desktop.gaming.enable = lib.mkEnableOption "gaming support";
  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;
  };
}
