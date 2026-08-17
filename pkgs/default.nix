{ pkgs }:
{
  fcitx5-themes-candlelight = pkgs.callPackage ./fcitx5-themes-candlelight.nix { };
  grub2-theme = pkgs.callPackage ./grub2-theme.nix {
    theme = "tela";
    screen = "1080p";
  };
}
