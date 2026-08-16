{ pkgs, ... }:
{
  home.packages = with pkgs; [
    obs-studio
    mpv
    gimp
    kdePackages.kdenlive
    ffmpeg
    upscayl
  ];
}
