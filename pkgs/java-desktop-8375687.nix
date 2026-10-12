{
  lib,
  jdk21,
  stdenvNoCC,
  unzip,
}:
# JDK-8375687: Window.setMaximizedBounds publishes the X11 maximum size hints in
# user space instead of device pixels, so with any sun.java2d.uiScale above 1 the
# maximum ends up below the minimum size hint of the same frame and window
# managers pin the window to its minimum. The patch scales both assignments in
# XFramePeer.setMaximizedBounds, matching every other size hint.
#
# The result is only the patched java.desktop, to be layered on the JDK the
# application runs on with "--patch-module java.desktop=${java-desktop-8375687}"
# (for example through JDK_JAVA_OPTIONS). Drop this package once the fix is in
# the JDK.
stdenvNoCC.mkDerivation {
  name = "java-desktop-8375687";

  nativeBuildInputs = [
    jdk21
    unzip
  ];

  unpackPhase = ''
    runHook preUnpack
    mkdir -p src/java.desktop/unix/classes/sun/awt/X11
    unzip -j ${jdk21}/lib/openjdk/lib/src.zip \
      java.desktop/sun/awt/X11/XFramePeer.java \
      -d src/java.desktop/unix/classes/sun/awt/X11
    runHook postUnpack
  '';

  patches = [ ../patches/java-desktop-8375687.patch ];

  buildPhase = ''
    runHook preBuild
    mkdir -p classes
    ${jdk21}/bin/javac \
      --patch-module java.desktop=src/java.desktop/unix/classes \
      -d classes \
      src/java.desktop/unix/classes/sun/awt/X11/XFramePeer.java
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r classes/. $out
    runHook postInstall
  '';

  meta = {
    description = "java.desktop with the JDK-8375687 maximum size hint fix";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
