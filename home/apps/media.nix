{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.apps.media;
in
{
  options.myHome.apps.media.enable = lib.mkEnableOption "media applications";
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      obs-studio
      mpv
      gimp
      kdePackages.kdenlive
      ffmpeg
      upscayl
    ];
  };
}
