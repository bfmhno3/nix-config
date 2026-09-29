{ lib, ... }:
{
  imports = [ ./themes/ech678/nyxuri.nix ];

  options.myHome.desktop.niri = {
    enable = lib.mkEnableOption "Niri user environment";
    monitorConfig = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      description = "Host-specific niri monitor.kdl; null keeps the local file";
    };
    themes = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "ech678/Nyxuri" ]);
      default = null;
      description = "Niri desktop theme composition";
    };
  };
}
