{ config, lib, ... }:
let
  cfg = config.myHome.core.tmux;
in
{
  options.myHome.core.tmux.enable = lib.mkEnableOption "tmux configuration";
  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
      keyMode = "vi";
      clock24 = true;
    };
  };
}
