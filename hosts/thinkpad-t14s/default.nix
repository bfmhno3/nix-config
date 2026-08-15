{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../users/bfmhno3/nixos.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "thinkpad-t14s";
  networking.networkmanager.enable = true;

  i18n.defaultLocale = "zh_CN.UTF-8";

  services.xserver = {
    enable = true;
    xkb = {
      layout = "cn";
      variant = "";
    };
  };

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

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

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  environment.variables.EDITOR = "vim";

  system.stateVersion = "26.05";
}
