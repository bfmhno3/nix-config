{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.core.packages;
in
{
  options.myHome.core.packages.enable = lib.mkEnableOption "core user packages";
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fastfetch
      nnn
      zip
      xz
      unzip
      p7zip
      ripgrep
      dust
      nh
      nvd
      fd
      jq
      yq-go
      eza
      delta
      yazi
      xh
      trippy
      fzf
      dnsutils
      ldns
      aria2
      socat
      ipcalc
      cowsay
      file
      which
      tree
      gnused
      gnutar
      gawk
      zstd
      gnupg
      nix-output-monitor
      glow
      btop
      htop
      bat
      iotop
      iftop
      strace
      ltrace
      lsof
      sysstat
      lm_sensors
      pciutils
      usbutils
      wget
      curl
    ];
    home.sessionVariables.NH_FLAKE = "${config.home.homeDirectory}/Projects/nix-config";

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
