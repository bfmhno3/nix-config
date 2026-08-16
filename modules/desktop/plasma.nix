{
  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "cn";
        variant = "";
      };
    };
    displayManager = {
      sddm.enable = true;
      defaultSession = "hyprland-uwsm";
    };
    desktopManager.plasma6.enable = true;
  };
}
