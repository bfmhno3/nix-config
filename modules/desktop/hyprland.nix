{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  security.pam.services.hyprlock = { };
}
