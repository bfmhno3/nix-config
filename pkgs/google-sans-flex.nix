{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "google-sans-flex";
  version = "251aa5a";

  src = fetchFromGitHub {
    owner = "end-4";
    repo = "google-sans-flex";
    rev = "251aa5abd30496368f634e54ce2a508fe5a2fdfa";
    hash = "sha256-HMAS0L/Tsqyl1xI16cyIzg9LEb6Dyq91JY4wqFQV9Vs=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 *.ttf -t "$out/share/fonts/truetype"
    runHook postInstall
  '';

  meta = {
    description = "Google Sans Flex variable font";
    homepage = "https://github.com/end-4/google-sans-flex";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
