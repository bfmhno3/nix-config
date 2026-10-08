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
      locale = {
        enable = true;
        timeZone = "America/Los_Angeles";
        extraLocale = "en_US.UTF-8";
      };
      network.enable = true;
    };
    desktop = {
      common.enable = true;
      fonts.enable = true;
      niri.enable = true;
      greetd.enable = true;
      plasma.enable = false;
      gaming.enable = true;
    };
    hardware = {
      bluetooth.enable = true;
      battery.enable = true;
    };
    network = {
      enable = true;
      clashVerge.enable = true;
      searxng.enable = true;
      localsend.enable = true;
      dae = {
        enable = true;
        autoStart = false;
      };
    };
    dev = {
      general.enable = true;
      embedded = {
        enable = true;
        stm32cubemx.uiScale = 2;
      };
      android.enable = true;
      codexDesktop.enable = true;
    };
  };

  boot.loader.efi.canTouchEfiVariables = true;

  services.fprintd.enable = true;

  security.pam.services = {
    polkit-1 = {
      fprintAuth = false;
      howdy.enable = false;
    };
    greetd = {
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
