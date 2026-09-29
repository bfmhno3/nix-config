{
  config,
  lib,
  ...
}:
let
  cfg = config.myHome.desktop.niri;
  theme = "ech678/Nyxuri";
  component = {
    enable = lib.mkDefault true;
    theme = lib.mkDefault theme;
  };
in
{
  config = lib.mkIf (cfg.enable && cfg.themes == theme) {
    myHome.desktop.niri.components = {
      niri = component;
      noctalia = component;
      kitty = component;
      fish = component;
      fastfetch = component;
      zed = component;
      portal = component;
      wallpapers = component;
      nyxmellow = {
        enable = lib.mkDefault config.myHome.desktop.common.inputMethod.enable;
        theme = lib.mkDefault theme;
      };
    };

    myHome.core.starship = component;
  };
}
