{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.dev.claudeCode;
in
{
  options.myHome.dev.claudeCode.enable = lib.mkEnableOption "the Claude Code CLI";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.claude-code ];
  };
}
