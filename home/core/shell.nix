{ config, lib, ... }:
let
  cfg = config.myHome.core.shell;
in
{
  options.myHome.core.shell.enable = lib.mkEnableOption "Zsh shell configuration";
  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        ll = "ls -la";
        g = "git";
        cat = "bat";
      };
    };
  };
}
