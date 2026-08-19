{ pkgs }:
{
  fcitx5-themes-candlelight = pkgs.callPackage ./fcitx5-themes-candlelight.nix { };
  google-sans-flex = pkgs.callPackage ./google-sans-flex.nix { };
  illogical-impulse-microtex = pkgs.callPackage ./illogical-impulse-microtex.nix {
    gtksourceviewmm = pkgs.gtksourceviewmm4;
    tinyxml2 = pkgs."tinyxml-2";
  };
  illogical-impulse-quickshell = pkgs.callPackage ./illogical-impulse-quickshell.nix { };
  grub2-theme = pkgs.callPackage ./grub2-theme.nix {
    theme = "tela";
    screen = "1080p";
  };
}
