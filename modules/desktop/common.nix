{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.desktop.common;
in
{
  options.mySystem.desktop.common.enable = lib.mkEnableOption "common desktop services";

  config = lib.mkIf cfg.enable {
    services = {
      printing.enable = true;
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
      geoclue2.enable = true;
    };
    security.polkit.enable = true;

    fonts = {
      packages = with pkgs; [
        material-design-icons
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
          "JetBrainsMono Nerd Font"
          "Noto Color Emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
