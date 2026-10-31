{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.core.packages;
  # Upstream's package tests the whole workspace. Its reqwest clients require
  # system CA roots, which do not exist in the Nix build sandbox, so every test
  # that constructs a client fails before making a request. Only the CLI is
  # installed.
  mq = inputs.mq.packages.${pkgs.stdenv.hostPlatform.system}.mq.overrideAttrs {
    doCheck = false;
    cargoBuildFlags = [
      "--package"
      "mq-run"
    ];
  };
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
      mq
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
    home.sessionVariables.NH_FLAKE = "${config.home.homeDirectory}/.config/nix-config";

    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      options = [
        "--cmd"
        "z"
      ];
    };

    programs.nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
