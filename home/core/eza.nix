{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.core.eza;
in
{
  options.myHome.core.eza.enable = lib.mkEnableOption "eza file listing aliases";
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.eza ];
    home.shellAliases = {
      ls = "eza";
      ll = "eza -lh --icons --group-directories-first";
      la = "eza -lah --icons --group-directories-first";
      tree = "eza --tree --icons";
    };
  };
}
