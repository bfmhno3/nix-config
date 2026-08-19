{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.desktop.hyprland.components.terminals;
  theme = "end-4/dots-hyprland";
  enabled = cfg.enable && cfg.theme == theme;
  assets = ../themes/end-4/dots-hyprland/terminals;
  reconcile = import ./reconcile.nix { inherit config lib pkgs; };
in
{
  options.myHome.desktop.hyprland.components.terminals = {
    enable = lib.mkEnableOption "repository-owned terminal configuration";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
  };

  config = {
    home.packages = lib.mkIf enabled [ pkgs.kitty ];
    home.activation.reconcileHyprlandTerminals = reconcile {
      component = "terminals";
      inherit enabled;
      source = assets;
      identity = "${theme}:${assets}";
    };
  };
}
