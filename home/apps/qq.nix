{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.apps.qq;
  scaleArgs = lib.optional (cfg.scale != null) "--force-device-scale-factor=${toString cfg.scale}";
  waylandArgs = [
    "--enable-features=WaylandWindowDecorations"
    "--enable-wayland-ime=true"
    "--wayland-text-input-version=3"
  ];
  # QQ's Electron build ignores --ozone-platform-hint=auto (verified on 3.2.32:
  # the process still opens an X11 connection), so the Ozone platform has to be
  # named explicitly; the launcher picks it from the session like Flathub does.
  # X11 has no output scale and needs --force-device-scale-factor; on Wayland that
  # flag *multiplies* the compositor scale (Chromium logs "TEST ONLY", a 2x
  # output became 4x), so it is only passed in the X11 branch.
  staticArgs = if cfg.wayland then waylandArgs else scaleArgs;
  qqBase =
    if staticArgs == [ ] then
      pkgs.qq
    else
      pkgs.qq.override {
        commandLineArgs = lib.concatStringsSep " " staticArgs;
      };
  qqLauncher = pkgs.writeShellScript "qq" ''
    if [ -n "''${WAYLAND_DISPLAY:-}" ]; then
      flags=(--ozone-platform=wayland)
    else
      flags=(--ozone-platform=x11 ${lib.concatStringsSep " " scaleArgs})
    fi
    exec ${lib.escapeShellArg "${qqBase}/bin/qq"} "''${flags[@]}" "$@"
  '';
  qqPackage =
    if !cfg.wayland then
      qqBase
    else
      pkgs.symlinkJoin {
        name = "qq";
        paths = [ qqBase ];
        postBuild = ''
          rm $out/bin/qq $out/share/applications/qq.desktop
          ln -s ${qqLauncher} $out/bin/qq
          substitute ${qqBase}/share/applications/qq.desktop $out/share/applications/qq.desktop \
            --replace-fail "Exec=${qqBase}/bin/qq" "Exec=$out/bin/qq"
        '';
      };
in
{
  options.myHome.apps.qq = {
    enable = lib.mkEnableOption "the QQ client";
    scale = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
      description = "Force a device scale factor for QQ; only applies on X11/XWayland (Wayland takes the compositor scale).";
      example = 2;
    };
    wayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run QQ as a native Wayland client (Ozone) instead of through XWayland.";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ qqPackage ];
  };
}
