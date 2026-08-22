{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "fcitx5-theme-ori";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "Reverier-Xu";
    repo = "Ori-fcitx5";
    rev = "16cfbcfb6dc31453044d566df89be0601fbd3b9f";
    hash = "sha256-wspAM/LM7v4VWWhD+Jf+IyAziUoPEXk84X2ZqxGiSoI=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fcitx5/themes
    cp -r OriDark "$out/share/fcitx5/themes/"

    runHook postInstall
  '';

  meta = {
    description = "Ori dark theme for Fcitx 5";
    homepage = "https://github.com/Reverier-Xu/Ori-fcitx5";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
  };
}
