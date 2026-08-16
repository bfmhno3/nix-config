{
  hostName,
  stateVersion,
  username,
  ...
}:
{
  mySystem.core = {
    base = {
      enable = true;
      inherit hostName username stateVersion;
    };
    nix.enable = true;
    user.enable = true;
    locale.enable = true;
    network.enable = true;
  };

  mySystem.desktop.fonts.enable = true;

  boot.loader.grub.enable = false;
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
  };

  services.getty.autologinUser = username;

  virtualisation.vmVariant.virtualisation = {
    cores = 2;
    memorySize = 2048;
    graphics = false;
  };
}
