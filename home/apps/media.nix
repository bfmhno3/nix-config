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

    home.sessionVariables.GST_PLUGIN_PATH_1_0 = lib.makeSearchPath "lib/gstreamer-1.0" [
      pkgs.gst_all_1.gst-plugins-base
    ];
  };
}
