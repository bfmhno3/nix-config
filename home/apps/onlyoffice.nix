{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.apps.onlyoffice;
  # ONLYOFFICE's X11 shell draws its own 26px window shadow and publishes that
  # margin through _NET_FRAME_EXTENTS. xwayland-satellite claims _NET_WM_CM_S0,
  # so ONLYOFFICE takes the custom-frame path, but neither xwayland-satellite
  # nor niri applies frame extents, which leaves the transparent margin inside
  # the window. --system-title-bar drops the custom frame and its shadow margin.
  # niri draws no server-side decorations, so niri's binds own close, maximize,
  # and fullscreen.
  launcher = pkgs.writeShellScript "onlyoffice-desktopeditors" ''
    exec ${pkgs.unstable.onlyoffice-desktopeditors}/bin/onlyoffice-desktopeditors --system-title-bar "$@"
  '';
  package = pkgs.symlinkJoin {
    name = "onlyoffice-desktopeditors";
    paths = [ pkgs.unstable.onlyoffice-desktopeditors ];
    postBuild = ''
      rm $out/bin/onlyoffice-desktopeditors $out/share/applications/onlyoffice-desktopeditors.desktop
      ln -s ${launcher} $out/bin/onlyoffice-desktopeditors
      substitute ${pkgs.unstable.onlyoffice-desktopeditors}/share/applications/onlyoffice-desktopeditors.desktop $out/share/applications/onlyoffice-desktopeditors.desktop \
        --replace-fail "Exec=${pkgs.unstable.onlyoffice-desktopeditors}/bin/onlyoffice-desktopeditors" "Exec=$out/bin/onlyoffice-desktopeditors"
    '';
  };
in
{
  options.myHome.apps.onlyoffice.enable = lib.mkEnableOption "the ONLYOFFICE desktop editors";

  config = lib.mkIf cfg.enable {
    home.packages = [ package ];
  };
}
