{ config, lib, ... }:
let
  cfg = config.mySystem.network.localsend;
in
{
  options.mySystem.network.localsend.enable = lib.mkEnableOption "LocalSend";

  config = lib.mkIf cfg.enable {
    programs.localsend.enable = true;
  };
}
