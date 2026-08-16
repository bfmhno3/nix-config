{ config, lib, ... }:
let
  cfg = config.mySystem.core.base;
in
{
  imports = [
    ./nix.nix
    ./user.nix
    ./locale.nix
    ./network.nix
  ];

  options.mySystem.core.base = {
    enable = lib.mkEnableOption "base system configuration";
    hostName = lib.mkOption {
      type = lib.types.str;
    };
    username = lib.mkOption {
      type = lib.types.str;
    };
    stateVersion = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    system.stateVersion = cfg.stateVersion;
  };
}
