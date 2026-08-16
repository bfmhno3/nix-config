{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.core.editors.helix;
in
{
  options.myHome.core.editors.helix.enable = lib.mkEnableOption "Helix editor";
  config = lib.mkIf cfg.enable {
    home.packages = [ inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.helix ];
  };
}
