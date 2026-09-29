{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.myHome.desktop.niri.components.nyxmellow;
  noctalia = config.myHome.desktop.niri.components.noctalia;
  theme = "ech678/Nyxuri";
in
{
  options.myHome.desktop.niri.components.nyxmellow = {
    enable = lib.mkEnableOption "Nyxuri NyxMellow fcitx5 theme";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
  };

  config = lib.mkIf (cfg.enable && cfg.theme == theme) {
    assertions = [
      {
        assertion = config.myHome.desktop.common.inputMethod.enable;
        message = "NyxMellow requires myHome.desktop.common.inputMethod.enable";
      }
      {
        assertion = noctalia.enable && noctalia.theme == theme;
        message = "NyxMellow requires components.noctalia";
      }
    ];
    # Noctalia renders the theme files into the writable parent directory.
    xdg.dataFile."fcitx5/themes/nyxmellow/templates".source =
      "${inputs.nyxuri}/assets/fcitx5/nyxmellow/templates";
    i18n.inputMethod.fcitx5.settings.addons.classicui.globalSection = {
      Theme = lib.mkForce "nyxmellow";
      DarkTheme = "nyxmellow";
    };
  };
}
