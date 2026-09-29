{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.myHome.desktop.niri.components.zed;
  theme = "ech678/Nyxuri";
  enabled = cfg.enable && cfg.theme == theme;
  # Zed rewrites settings.json from its UI, so the files must be writable; each switch redeploys them.
  staged = pkgs.runCommandLocal "nyxuri-zed" { } ''
    mkdir -p "$out/.config/zed"
    cp ${inputs.nyxuri}/configs/zed/settings.json ${inputs.nyxuri}/configs/zed/keymap.json "$out/.config/zed/"
  '';
  reconcile = import ../../common/reconcile.nix { inherit config lib pkgs; };
in
{
  options.myHome.desktop.niri.components.zed = {
    enable = lib.mkEnableOption "Nyxuri Zed configuration";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
  };

  config = {
    home.packages = lib.mkIf enabled [ pkgs.zed-editor ];
    home.activation = reconcile {
      name = "reconcileNyxuriZed";
      scope = "nyxuri";
      component = "zed";
      inherit enabled;
      source = staged;
      identity = "${theme}:${staged}";
    };
  };
}
