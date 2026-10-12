{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.dev.claudeDesktop;
  claudeDesktop = inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  options.mySystem.dev.claudeDesktop.enable = lib.mkEnableOption "the official Claude desktop app";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ claudeDesktop ];

    # Cowork runs agent work in a QEMU micro-VM and probes these absolute paths
    # at startup, without any environment override: UEFI firmware under
    # /usr/share/OVMF (the app derives the _VARS_4M.fd template from the code
    # file) and virtiofsd under /usr/libexec, where it ignores its own bundled
    # copy. The package wrapper already publishes qemu on PATH.
    systemd.tmpfiles.rules = [
      "L+ /usr/share/OVMF/OVMF_CODE_4M.fd - - - - ${pkgs.OVMF.firmware}"
      "L+ /usr/share/OVMF/OVMF_VARS_4M.fd - - - - ${pkgs.OVMF.variables}"
      "L+ /usr/libexec/virtiofsd - - - - ${pkgs.virtiofsd}/bin/virtiofsd"
    ];

    boot.kernelModules = [ "vhost_vsock" ];

    # The micro-VM opens /dev/kvm.
    users.users.${config.mySystem.core.base.username}.extraGroups = [ "kvm" ];
  };
}
