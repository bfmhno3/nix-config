{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop/common.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/plasma.nix
    ../../modules/desktop/gaming.nix
    ../../modules/hardware/bluetooth.nix
    ../../modules/hardware/battery.nix
    ../../modules/network
    ../../modules/dev/general.nix
    ../../modules/dev/embedded.nix
    ../../modules/dev/android.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  i18n.defaultLocale = "zh_CN.UTF-8";

  services.fprintd.enable = true;

  security.pam.services = {
    polkit-1 = {
      fprintAuth = false;
      howdy.enable = false;
    };
    sddm = {
      fprintAuth = true;
      howdy.enable = true;
    };
  };

  services.howdy = {
    enable = true;
    control = "sufficient";
    settings.video.device_path = "/dev/video2";
  };

  services.linux-enable-ir-emitter = {
    enable = true;
    device = "video2";
  };

  environment.variables.EDITOR = "vim";
}
