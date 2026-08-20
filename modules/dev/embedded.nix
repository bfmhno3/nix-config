{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.dev.embedded;
  stm32cubemx =
    if cfg.stm32cubemx.uiScale == null then
      pkgs.stm32cubemx
    else
      pkgs.symlinkJoin {
        name = "stm32cubemx";
        paths = [ pkgs.stm32cubemx ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/stm32cubemx \
            --set JDK_JAVA_OPTIONS "-Dsun.java2d.uiScale=${toString cfg.stm32cubemx.uiScale}"
        '';
      };
in
{
  options.mySystem.dev.embedded = {
    enable = lib.mkEnableOption "embedded development tools";
    stm32cubemx.uiScale = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
    };
  };
  config = lib.mkIf cfg.enable {
    nixpkgs.config.segger-jlink.acceptLicense = true;

    services.udev.packages = with pkgs; [
      openocd
      stlink
      segger-jlink
      saleae-logic-2
    ];
    environment.systemPackages = with pkgs; [
      openocd
      stlink
      segger-jlink
      stm32cubemx
      saleae-logic-2
      kicad
      minicom
      picocom
    ];
  };
}
