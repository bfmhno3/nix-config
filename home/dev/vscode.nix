{ config, lib, ... }:
let
  cfg = config.myHome.dev.vscode;
in
{
  options.myHome.dev.vscode.enable = lib.mkEnableOption "Visual Studio Code";
  config = lib.mkIf cfg.enable {
    programs.vscode.enable = true;
  };
}
