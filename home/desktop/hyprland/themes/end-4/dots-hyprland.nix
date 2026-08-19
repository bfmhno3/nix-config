{
  config,
  lib,
  ...
}:
let
  cfg = config.myHome.desktop.hyprland;
  theme = "end-4/dots-hyprland";
in
{
  config = lib.mkIf (cfg.enable && cfg.themes == theme) {
    myHome.desktop.hyprland.components = {
      hyprland = {
        enable = lib.mkDefault true;
        theme = lib.mkDefault theme;
      };
      quickshell = {
        enable = lib.mkDefault true;
        theme = lib.mkDefault theme;
        settings = lib.mkDefault {
          appearance.fonts = {
            monospace = "Maple Mono NF CN";
            iconNerd = "Maple Mono NF CN";
          };
        };
      };
      appearance = {
        enable = lib.mkDefault true;
        theme = lib.mkDefault theme;
      };
      terminals = {
        enable = lib.mkDefault true;
        theme = lib.mkDefault theme;
      };
      shell = {
        enable = lib.mkDefault true;
        theme = lib.mkDefault theme;
      };
      applications = {
        enable = lib.mkDefault true;
        theme = lib.mkDefault theme;
      };
      services = {
        enable = lib.mkDefault true;
        theme = lib.mkDefault theme;
        features = {
          audio = lib.mkDefault true;
          backlight = lib.mkDefault true;
          bluetooth = lib.mkDefault true;
          network = lib.mkDefault true;
          idleLock = lib.mkDefault true;
          screenCapture = lib.mkDefault true;
          screenRecording = lib.mkDefault true;
          onScreenKeyboard = lib.mkDefault true;
          musicRecognition = lib.mkDefault true;
          translation = lib.mkDefault true;
          wallpaper = lib.mkDefault true;
          ai = lib.mkDefault true;
          kdeIntegration = lib.mkDefault true;
        };
      };
    };

    myHome.core.starship = {
      enable = lib.mkDefault true;
      theme = lib.mkDefault theme;
    };
    myHome.desktop.terminals.foot = {
      enable = lib.mkDefault true;
      theme = lib.mkDefault theme;
    };
  };
}
