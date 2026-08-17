{
  lib,
  stdenvNoCC,
  fetchzip,
  theme ? "tela",
  screen ? "1080p",
}:

let
  assetScreen =
    {
      ultrawide = "1080p";
      ultrawide2k = "2k";
    }
    .${screen} or screen;
in
stdenvNoCC.mkDerivation {
  pname = "grub2-theme-${theme}-${screen}";
  version = "unstable-2026-08-12";

  src = fetchzip {
    url = "https://github.com/vinceliuice/grub2-themes/archive/241d3be041c2823cf2430fe2f44bca2215331d67.tar.gz";
    hash = "sha256-yvnz/8Nh4iq67X27Vf2oD181SqnYi01M6VnSxBt5qcg=";
  };

  installPhase = ''
    runHook preInstall

    themeDir="$out/grub/themes/${theme}"
    mkdir -p "$themeDir"
    cp common/*.pf2 "$themeDir/"
    cp config/theme-${screen}.txt "$themeDir/theme.txt"
    cp backgrounds/${screen}/background-${theme}.jpg "$themeDir/background.jpg"
    cp -r assets/assets-color/icons-${assetScreen} "$themeDir/icons"
    cp assets/assets-select/select-${assetScreen}/*.png "$themeDir/"
    cp assets/info-${assetScreen}.png "$themeDir/info.png"

    for box in c e n ne nw s se sw w; do
      touch "$themeDir/terminal_box_$box.png"
    done

    runHook postInstall
  '';

  meta = {
    description = "GRUB2 theme from vinceliuice/grub2-themes";
    homepage = "https://github.com/vinceliuice/grub2-themes";
    license = lib.licenses.gpl3Plus;
  };
}
