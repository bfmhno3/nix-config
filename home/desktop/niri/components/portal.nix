{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.myHome.desktop.niri.components.portal;
  theme = "ech678/Nyxuri";
  src = "${inputs.nyxuri}/configs/xdg-desktop-portal";
in
{
  options.myHome.desktop.niri.components.portal = {
    enable = lib.mkEnableOption "Nyxuri XDG desktop portal routing";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
  };

  config = lib.mkIf (cfg.enable && cfg.theme == theme) {
    xdg.configFile = {
      "xdg-desktop-portal/portals.conf".source = "${src}/portals.conf";
      "xdg-desktop-portal/niri-portals.conf".source = "${src}/niri-portals.conf";
    };
  };
}
