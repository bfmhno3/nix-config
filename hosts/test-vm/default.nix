{ username, ... }: {
  imports = [ ../../modules/system.nix ];

  boot.loader.grub.enable = false;
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
  };

  networking.hostName = "test-vm";
  networking.networkmanager.enable = true;
  services.getty.autologinUser = username;
  system.stateVersion = "26.05";

  virtualisation.vmVariant.virtualisation = {
    cores = 2;
    memorySize = 2048;
    graphics = false;
  };
}
