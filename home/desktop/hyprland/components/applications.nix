{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.desktop.hyprland.components.applications;
  theme = "end-4/dots-hyprland";
  enabled = cfg.enable && cfg.theme == theme;
  assets = ../themes/end-4/dots-hyprland/applications;
  reconcile = import ./reconcile.nix { inherit config lib pkgs; };
in
{
  options.myHome.desktop.hyprland.components.applications = {
    enable = lib.mkEnableOption "repository-owned desktop application configuration";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
  };

  config = {
    home.packages = lib.mkIf enabled (
      with pkgs;
      [
        fuzzel
        wlogout
      ]
    );
    home.activation.reconcileHyprlandApplications = reconcile {
      component = "applications";
      inherit enabled;
      source = assets;
      identity = "${theme}:${assets}";
    };
  };
}
