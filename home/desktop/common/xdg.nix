{ config, lib, ... }:
let
  cfg = config.myHome.desktop.common.xdg;
in
{
  options.myHome.desktop.common.xdg.enable =
    lib.mkEnableOption "XDG user directories and MIME associations";
  config = lib.mkIf cfg.enable {
    xdg = {
      userDirs.enable = true;
      mimeApps = {
        enable = true;
        defaultApplications = {
          "application/pdf" = [ "org.pwmt.zathura.desktop" ];
          "video/mp4" = [ "mpv.desktop" ];
          "video/x-matroska" = [ "mpv.desktop" ];
          "video/webm" = [ "mpv.desktop" ];
          "audio/mpeg" = [ "mpv.desktop" ];
          "audio/flac" = [ "mpv.desktop" ];
          "audio/ogg" = [ "mpv.desktop" ];
        };
      };
    };
    xdg.configFile."user-dirs.dirs".force = true;
    xdg.configFile."mimeapps.list".force = true;
    xdg.dataFile."applications/mimeapps.list".force = true;
  };
}
