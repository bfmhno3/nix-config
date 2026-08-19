{ lib, ... }:
{
  imports = [ ./themes/end-4/dots-hyprland.nix ];

  options.myHome.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland user environment";
    monitorConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Host-specific Illogical Impulse monitor configuration";
    };
    themes = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "end-4/dots-hyprland" ]);
      default = null;
      description = "Hyprland desktop theme composition";
    };
  };
}
