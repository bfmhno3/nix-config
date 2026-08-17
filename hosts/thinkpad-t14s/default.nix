{
  hostName,
  stateVersion,
  username,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  mySystem = {
    core = {
      base = {
        enable = true;
        inherit hostName username stateVersion;
      };
      grub = {
        enable = true;
        screen = "4k";
      };
      nix.enable = true;
      user.enable = true;
      locale.enable = true;
      network.enable = true;
    };
    desktop = {
      common.enable = true;
      fonts.enable = true;
      hyprland.enable = true;
      plasma.enable = true;
      gaming.enable = true;
    };
    hardware = {
      bluetooth.enable = true;
      battery.enable = true;
    };
    network.enable = true;
    dev = {
      general.enable = true;
      embedded.enable = true;
      android.enable = true;
    };
  };

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
