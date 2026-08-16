{
  config,
  inputs,
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
      uv
      bun
      ast-grep
      gh
      inputs.omp.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
