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
          # The Codex/ChatGPT desktop package ships a chatgpt.desktop that claims
          # x-scheme-handler/http and https and republishes it in
          # ~/.local/share/applications on every launch. Without an explicit
          # default, the xdg-utils and glib fallback (first entry in the user
          # mimeinfo.cache) picks ChatGPT over Chrome.
          "text/html" = [ "google-chrome.desktop" ];
          "x-scheme-handler/http" = [ "google-chrome.desktop" ];
          "x-scheme-handler/https" = [ "google-chrome.desktop" ];
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
