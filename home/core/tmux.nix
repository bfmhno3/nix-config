{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.core.tmux;
in
{
  options.myHome.core.tmux.enable = lib.mkEnableOption "tmux configuration";
  config = lib.mkIf cfg.enable {
    programs.tmux.enable = true;
    xdg.configFile."tmux/tmux.conf" = {
      text = lib.mkForce null;
      source = "${inputs.oh-my-tmux}/.tmux.conf";
    };
    xdg.configFile."tmux/tmux.conf.local".source = "${inputs.oh-my-tmux}/.tmux.conf.local";
    home.packages = with pkgs; [
      gawk
      gnugrep
      gnused
      perl
    ];
  };
}
