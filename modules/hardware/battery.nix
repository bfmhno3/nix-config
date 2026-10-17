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
      # TLP and power-profiles-daemon both control platform_profile and CPU
      # EPP, so they cannot run together. tlp-pd exposes the ppd D-Bus API on
      # top of TLP, which Noctalia uses for its power profile switch.
      pd.enable = true;
      # Do not set START_CHARGE_THRESH_BAT0/STOP_CHARGE_THRESH_BAT0 here:
      # UPower must own the thresholds, otherwise Noctalia sees them as
      # externally managed and disables its charge limit toggle.
    };
    services.power-profiles-daemon.enable = false;
    services.upower.enable = true;

    # Enable UPower's threshold management once; it persists the choice and
    # re-applies the EC thresholds on later boots.
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
