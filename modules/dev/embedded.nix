{ pkgs, ... }:
{
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
}
