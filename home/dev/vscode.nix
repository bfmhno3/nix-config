{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.dev.vscode;
in
{
  options.myHome.dev.vscode.enable = lib.mkEnableOption "Visual Studio Code";
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      # The nixos-26.05 branch does not receive Visual Studio Code releases.
      package = pkgs.unstable.vscode;
    };
  };
}
