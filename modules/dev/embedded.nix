{ pkgs, ... }:
let
  seggerJlink = pkgs.segger-jlink.override { headless = true; };
in
{
  nixpkgs.config.segger-jlink.acceptLicense = true;

  services.udev.packages = with pkgs; [
    openocd
    stlink
    seggerJlink
    saleae-logic-2
  ];
  environment.systemPackages = with pkgs; [
    openocd
    stlink
    seggerJlink
    stm32cubemx
    saleae-logic-2
    kicad
    minicom
    picocom
  ];
}
