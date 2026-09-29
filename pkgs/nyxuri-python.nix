{
  lib,
  runCommandLocal,
  makeBinaryWrapper,
  python3,
  gtk3,
  gtk-layer-shell,
  pango,
  gdk-pixbuf,
  harfbuzz,
  at-spi2-core,
  glib,
  gobject-introspection,
}:
let
  python = python3.withPackages (ps: [
    ps.pygobject3
    ps.pycairo
  ]);
in
# A binary wrapper is required because the Nyxuri tools use this as a shebang interpreter.
runCommandLocal "nyxuri-python" { nativeBuildInputs = [ makeBinaryWrapper ]; } ''
  makeBinaryWrapper ${python}/bin/python3 $out/bin/python3 \
    --prefix GI_TYPELIB_PATH : ${
      lib.makeSearchPathOutput "out" "lib/girepository-1.0" [
        gtk3
        gtk-layer-shell
        pango
        gdk-pixbuf
        harfbuzz
        at-spi2-core
        glib
        gobject-introspection
      ]
    }
''
