{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.desktop.fonts;
in
{
  options.mySystem.desktop.fonts.enable = lib.mkEnableOption "desktop fonts";

  config = lib.mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        material-design-icons
        google-sans-flex
        (google-fonts.override {
          fonts = [
            "Readex Pro"
            "Space Grotesk"
          ];
        })
        material-symbols
        rubik
        twemoji-color-font
        maple-mono.NF-CN
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        nerd-fonts.symbols-only
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
        nerd-fonts.iosevka
      ];
      enableDefaultPackages = false;
      fontconfig.defaultFonts = {
        serif = [
          "Noto Serif"
          "Noto Color Emoji"
        ];
        sansSerif = [
          "Noto Sans"
          "Noto Color Emoji"
        ];
        monospace = [
          "Maple Mono NF CN"
          "Noto Color Emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
