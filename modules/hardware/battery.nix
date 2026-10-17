{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.hardware.battery;
in
{
  options.mySystem.hardware.battery.enable = lib.mkEnableOption "battery power management";
  config = lib.mkIf cfg.enable {
    services.tlp = {
      enable = true;
      # Noctalia's power profile switch talks to org.freedesktop.UPower.PowerProfiles.
      pd.enable = true;
    };
    services.power-profiles-daemon.enable = false;
    services.upower.enable = true;

    # TLP must not write charge thresholds, otherwise UPower marks them as
    # externally managed and Noctalia disables its charge limit toggle.
    # Enable UPower once; it persists the choice and re-applies the EC
    # thresholds on later boots.
    systemd.services.upower-adopt-charge-thresholds = {
      description = "Adopt battery charge thresholds into UPower";
      after = [ "upower.service" ];
      requires = [ "upower.service" ];
      wantedBy = [ "multi-user.target" ];
      unitConfig.ConditionPathExists = "!/var/lib/upower/charging-threshold-status";
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.systemd}/bin/busctl --system call \
          org.freedesktop.UPower \
          /org/freedesktop/UPower/devices/battery_BAT0 \
          org.freedesktop.UPower.Device \
          EnableChargeThreshold b true
      '';
    };
  };
}
