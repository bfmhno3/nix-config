{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.dev.tools;
in
{
  options.myHome.dev.tools.enable = lib.mkEnableOption "user development tools";
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      lazygit
      bun
      ast-grep
      gh
    ];
  };
}
