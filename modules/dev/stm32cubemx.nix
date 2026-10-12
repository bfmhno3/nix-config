{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.dev.stm32cubemx;
  # java-desktop-8375687 puts the X11 maximum size hint of setMaximizedBounds in
  # device pixels. Without it any uiScale above 1 publishes a maximum below the
  # minimum size hint of the same window, and niri pins CubeMX to that minimum:
  # the window can be neither resized nor maximized.
  jvmOptions = "--patch-module java.desktop=${pkgs.java-desktop-8375687}";
  # AWT on X11 takes its HiDPI scale from the X screen DPI and truncates it to an
  # integer. Xwayland reports 96 dpi whatever the compositor scales at, so the
  # JVM's own detection always resolves to 1 there. Ask the compositor for the
  # scale of the focused output (where niri will open the window) at launch
  # instead, and round it, since AWT truncates fractional scales anyway.
  jvmOptionsFlags =
    if cfg.uiScale != null then
      "--set JDK_JAVA_OPTIONS ${lib.escapeShellArg "${jvmOptions} -Dsun.java2d.uiScale=${toString cfg.uiScale}"}"
    else
      "--run ${lib.escapeShellArg ''
        scale=
        if command -v niri > /dev/null 2>&1; then
          scale=$(niri msg focused-output 2>/dev/null | awk "/^  Scale: /{ printf \"%d\", \$2 + 0.5; exit }")
        fi
        options="${jvmOptions}"
        if [ -n "$scale" ]; then
          options="$options -Dsun.java2d.uiScale=$scale"
        else
          options="$options -Dsun.java2d.uiScale.enabled=true"
        fi
        export JDK_JAVA_OPTIONS="$options"
      ''}";
  # AWT also carries a hardcoded list of non-reparenting window managers and does
  # not know niri/Xwayland (the X WM name is xwayland-satellite), so CubeMX would
  # otherwise be managed as if it were reparented. See ArchWiki "Java#Gray
  # window, applications not resizing with WM, menus immediately closing".
  stm32cubemx = pkgs.symlinkJoin {
    name = "stm32cubemx";
    paths = [ pkgs.stm32cubemx ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/stm32cubemx \
        --set _JAVA_AWT_WM_NONREPARENTING 1 \
        --set AWT_TOOLKIT MToolkit \
        ${jvmOptionsFlags}
    '';
  };
in
{
  options.mySystem.dev.stm32cubemx = {
    enable = lib.mkEnableOption "STM32CubeMX";
    uiScale = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
      description = ''
        sun.java2d.uiScale for CubeMX's JVM. CubeMX does not scale its own UI on
        HiDPI setups, so it stays at half the size of native applications unless
        a scale is applied. Unset takes the scale of the compositor's focused
        output at launch and rounds it, because AWT truncates fractional scales
        on X11; it falls back to the JVM's own detection when no compositor
        answers. Set an integer to pin the scale.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ stm32cubemx ];
  };
}
