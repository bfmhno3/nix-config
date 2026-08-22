{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.myHome.dev.omp;
in
{
  imports = [ inputs.omp.homeManagerModules.default ];

  options.myHome.dev.omp.enable = lib.mkEnableOption "Oh My Pi coding agent";

  config = lib.mkIf cfg.enable {
    programs.omp.enable = true;
  };
}
