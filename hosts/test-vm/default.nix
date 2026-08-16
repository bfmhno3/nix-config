{ username, ... }:
{
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
