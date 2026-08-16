{
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "fcitx5-themes-candlelight";
  version = "60aeadd";

  src = fetchzip {
    url = "https://github.com/thep0y/fcitx5-themes-candlelight/archive/60aeaddfb3ecdb6a132e8da7569a6c442e6bb217.tar.gz";
    hash = "sha256-YQ/2sveC57vQ36BjgnvPzObSAiAYmg1zK/TmEVqSvhY=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fcitx5/themes
    cp -r macOS-dark $out/share/fcitx5/themes/

    runHook postInstall
  '';
}
