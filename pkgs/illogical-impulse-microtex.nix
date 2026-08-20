{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  fontconfig,
  gtkmm3,
  gtksourceviewmm,
  cairomm,
  tinyxml2,
}:
stdenv.mkDerivation {
  pname = "illogical-impulse-microtex";
  version = "r494-0e3707f";

  src = fetchFromGitHub {
    owner = "end-4";
    repo = "MicroTeX";
    rev = "0e3707f6dafebb121d98b53c64364d16fefe481d";
    hash = "sha256-U6zqh+VqoLtlE0IwgfwjY9zt8e5/2R3cqf5fWXwoIi0=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    fontconfig
    gtkmm3
    gtksourceviewmm
    cairomm
    tinyxml2
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail gtksourceviewmm-3.0 gtksourceviewmm-4.0
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 LaTeX "$out/libexec/MicroTeX/LaTeX"
    cp -r res "$out/libexec/MicroTeX/res"
    mkdir -p "$out/bin"
    ln -s ../libexec/MicroTeX/LaTeX "$out/bin/LaTeX"
    runHook postInstall
  '';

  meta = {
    description = "MicroTeX renderer for Illogical Impulse";
    homepage = "https://github.com/end-4/MicroTeX";
    license = lib.licenses.mit;
    mainProgram = "LaTeX";
    platforms = lib.platforms.linux;
  };
}
