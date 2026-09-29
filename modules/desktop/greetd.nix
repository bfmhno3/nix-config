{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.desktop.greetd;
  defaultSession = config.services.displayManager.defaultSession;
in
{
  options.mySystem.desktop.greetd.enable =
    lib.mkEnableOption "greetd display manager with Noctalia greeter";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.mySystem.desktop.sddm.enable;
        message = "mySystem.desktop.greetd and mySystem.desktop.sddm cannot both be enabled";
      }
    ];

    services.greetd = {
      enable = true;
      # NixOS session files exist only under sessionData, and the greeter scans XDG_DATA_DIRS/wayland-sessions.
      settings.default_session.command = lib.concatStringsSep " " (
        [
          "${pkgs.coreutils}/bin/env"
          "XDG_DATA_DIRS=${config.services.displayManager.sessionData.desktops}/share:/run/current-system/sw/share"
          "${pkgs.noctalia-greeter}/bin/noctalia-greeter-session"
        ]
        ++ lib.optionals (defaultSession != null) [
          "--"
          "--session"
          defaultSession
        ]
      );
    };
    systemd.services.greetd.path = [ pkgs.dbus ];
    environment.systemPackages = [ pkgs.noctalia-greeter ];
    systemd.tmpfiles.packages = [ pkgs.noctalia-greeter ];

    security.polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.noctalia.greeter.apply-appearance" && subject.isInGroup("wheel")) {
            return polkit.Result.YES;
          }
        });
      '';
    };
  };
}
