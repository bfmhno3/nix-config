{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.desktop.hyprland.components.appearance;
  theme = "end-4/dots-hyprland";
  enabled = cfg.enable && cfg.theme == theme;
  assets = ../themes/end-4/dots-hyprland/appearance;
  reconcile = import ./reconcile.nix { inherit config lib pkgs; };
in
{
  options.myHome.desktop.hyprland.components.appearance = {
    enable = lib.mkEnableOption "repository-owned desktop appearance";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
  };

  config = {
    home.packages = lib.mkIf enabled (
      with pkgs;
      [
        adw-gtk3
        kdePackages.breeze
        kdePackages.breeze-icons
        darkly
        matugen
        fontconfig
        bibata-cursors
      ]
    );
    home.activation.reconcileHyprlandAppearance = reconcile {
      component = "appearance";
      inherit enabled;
      source = assets;
      identity = "${theme}:${assets}";
    };
  };
}
