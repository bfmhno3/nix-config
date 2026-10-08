{
  lib,
  stdenvNoCC,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  desktop-file-utils,
  webkitgtk_4_1,
  gtk3,
  gdk-pixbuf,
  glib,
  libsoup_3,
  openssl,
  xz,
  libayatana-appindicator,
  glib-networking,
  gsettings-desktop-schemas,
  librsvg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cc-switch";
  version = "4.0.4";

  # Upstream ships no nixpkgs package and no Linux tarball, so the Debian build
  # is the input and the Nix-native WebKitGTK stack is linked in at install time.
  src = fetchurl {
    url = "https://github.com/farion1231/cc-switch/releases/download/v${finalAttrs.version}/CC-Switch-v${finalAttrs.version}-Linux-x86_64.deb";
    hash = "sha256-QZMHITPrHBCNdfmAXvupEUDxjqz4MbSEnTg34qcNubo=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    webkitgtk_4_1
    gtk3
    gdk-pixbuf
    glib
    libsoup_3
    openssl
    xz
    librsvg
    gsettings-desktop-schemas
    glib-networking
  ];

  # Loaded at runtime by the tray backend rather than linked as a DT_NEEDED.
  runtimeDependencies = [ libayatana-appindicator ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/* $out/

    substituteInPlace "$out/share/applications/CC Switch.desktop" \
      --replace-fail 'Exec=cc-switch' "Exec=$out/bin/cc-switch"

    runHook postInstall
  '';

  # tauri-plugin-deep-link shells out to update-desktop-database to register the
  # ccswitch:// handler; without it the handler file is written but never indexed.
  postInstall = ''
    gappsWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ desktop-file-utils ]})
  '';

  meta = {
    description = "Desktop provider, MCP and Skills manager for Claude Code, Codex and other AI coding agents";
    homepage = "https://github.com/farion1231/cc-switch";
    license = lib.licenses.mit;
    mainProgram = "cc-switch";
    platforms = [ "x86_64-linux" ];
  };
})
