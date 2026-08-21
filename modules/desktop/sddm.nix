{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.desktop.sddm;
  screenPresets = {
    "1080p" = {
      ScreenWidth = "1920";
      ScreenHeight = "1080";
      FontSize = "13";
    };
    "4k" = {
      ScreenWidth = "3840";
      ScreenHeight = "2160";
      FontSize = "27";
    };
  };
  themePackage = pkgs.sddm-astronaut.override {
    embeddedTheme = cfg.theme;
    themeConfig = screenPresets.${cfg.screen} // cfg.themeConfig;
  };
in
{
  options.mySystem.desktop.sddm = {
    enable = lib.mkEnableOption "SDDM display manager";
    theme = lib.mkOption {
      type = lib.types.enum [
        "astronaut"
        "black_hole"
        "cyberpunk"
        "hyprland_kath"
        "jake_the_dog"
        "japanese_aesthetic"
        "pixel_sakura"
        "pixel_sakura_static"
        "post-apocalyptic_hacker"
        "purple_leaves"
      ];
      default = "astronaut";
    };
    screen = lib.mkOption {
      type = lib.types.enum [
        "1080p"
        "4k"
      ];
      default = "1080p";
    };
    themeConfig = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.bool
          lib.types.int
          lib.types.float
          lib.types.str
        ]
      );
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ themePackage ];
    services.displayManager.sddm = {
      enable = true;
      enableHidpi = true;
      theme = "sddm-astronaut-theme";
      extraPackages = [ themePackage ];
      settings.General.InputMethod = "qtvirtualkeyboard";
    };
  };
}
