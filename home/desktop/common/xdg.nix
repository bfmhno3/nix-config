{ ... }:
{
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
}
