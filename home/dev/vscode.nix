{ config, lib, ... }:
let
  cfg = config.myHome.dev.vscode;
in
{
  options.myHome.dev.vscode.enable = lib.mkEnableOption "Visual Studio Code";
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      profiles.default.userSettings = {
        "editor.fontFamily" = "'Maple Mono NF CN', monospace";
        "editor.fontLigatures" = true;
        "terminal.integrated.fontFamily" = "'Maple Mono NF CN', monospace";
        "terminal.integrated.fontLigatures.enabled" = true;
      };
    };
  };
}
