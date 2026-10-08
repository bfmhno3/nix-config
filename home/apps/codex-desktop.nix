{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.myHome.apps.codexDesktop;
in
{
  imports = [ inputs.codex-desktop-linux.homeManagerModules.default ];

  options.myHome.apps.codexDesktop.enable = lib.mkEnableOption "the Codex Desktop client";

  config = lib.mkIf cfg.enable {
    programs.codexDesktopLinux.enable = true;
  };
}
