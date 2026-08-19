{
  lib,
  quickshell,
  fetchgit,
  gsettings-desktop-schemas,
  kdePackages,
  qt6,
}:
let
  qmlPackages = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qt5compat
    qt6.qtimageformats
    qt6.qtmultimedia
    qt6.qtpositioning
    qt6.qtquicktimeline
    qt6.qtsensors
    qt6.qtsvg
    qt6.qttools
    qt6.qttranslations
    qt6.qtvirtualkeyboard
    qt6.qtwayland
    qt6.qtwebsockets
    kdePackages.kirigami
    kdePackages.kdialog
    kdePackages.syntax-highlighting
  ];
in
quickshell.overrideAttrs (old: {
  pname = "illogical-impulse-quickshell";
  version = "0.2.1-7511545";

  src = fetchgit {
    url = "https://git.outfoxxed.me/quickshell/quickshell.git";
    rev = "7511545ee20664e3b8b8d3322c0ffe7567c56f7a";
    hash = "sha256-FyO/nPw2CZn35YL22Xl8V5qkTTANwKoNw2MIAIcmZH0=";
  };

  buildInputs = (old.buildInputs or [ ]) ++ qmlPackages;

  cmakeFlags = (old.cmakeFlags or [ ]) ++ [
    (lib.cmakeFeature "DISTRIBUTOR" "illogical-impulse")
    (lib.cmakeFeature "GIT_REVISION" "7511545ee20664e3b8b8d3322c0ffe7567c56f7a")
    (lib.cmakeBool "SERVICE_POLKIT" true)
  ];

  preFixup = (old.preFixup or "") + ''
    qtWrapperArgs+=(
      --prefix QML2_IMPORT_PATH : "${lib.makeSearchPath "lib/qt-6/qml" qmlPackages}"
      --prefix QT_PLUGIN_PATH : "${lib.makeSearchPath "lib/qt-6/plugins" qmlPackages}"
      --prefix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
    )
  '';

  meta = (old.meta or { }) // {
    description = "Pinned Quickshell build for Illogical Impulse";
    license = lib.licenses.lgpl3Only;
  };
})
