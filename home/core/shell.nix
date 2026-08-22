{ config, lib, ... }:
let
  cfg = config.myHome.core.shell;
in
{
  options.myHome.core.shell.enable = lib.mkEnableOption "interactive shell configuration";
  config = lib.mkIf cfg.enable {
    home.shellAliases.g = "git";
    programs.bash.enable = true;

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };
  };
}
