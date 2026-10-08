{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.dev.codex;
in
{
  options.myHome.dev.codex.enable = lib.mkEnableOption "the Codex CLI";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.codex ];
  };
}
