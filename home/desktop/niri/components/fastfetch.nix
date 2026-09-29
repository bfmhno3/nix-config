{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.myHome.desktop.niri.components.fastfetch;
  theme = "ech678/Nyxuri";
in
{
  options.myHome.desktop.niri.components.fastfetch = {
    enable = lib.mkEnableOption "Nyxuri fastfetch configuration";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
  };

  config = lib.mkIf (cfg.enable && cfg.theme == theme) {
    xdg.configFile."fastfetch/config.jsonc".source = "${inputs.nyxuri}/configs/fastfetch/config.jsonc";
    home.packages = [ pkgs.fastfetch ];
  };
}
