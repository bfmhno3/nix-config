{ config, lib, ... }:
let
  cfg = config.myHome.core;
in
{
  imports = [
    ./bat.nix
    ./eza.nix
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./tmux.nix
    ./starship.nix
    ./editors/nvim.nix
    ./editors/helix.nix
  ];

  options.myHome.core.enable = lib.mkEnableOption "every headless core user module";

  options.myHome.core.user = {
    enable = lib.mkEnableOption "Home Manager user configuration";
    username = lib.mkOption {
      type = lib.types.str;
    };
    stateVersion = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.user.enable {
      home = {
        username = cfg.user.username;
        homeDirectory = "/home/${cfg.user.username}";
        stateVersion = cfg.user.stateVersion;
      };
    })
    (lib.mkIf cfg.enable {
      myHome.core = {
        bat.enable = lib.mkDefault true;
        eza.enable = lib.mkDefault true;
        packages.enable = lib.mkDefault true;
        shell.enable = lib.mkDefault true;
        git.enable = lib.mkDefault true;
        tmux.enable = lib.mkDefault true;
        starship.enable = lib.mkDefault true;
        editors = {
          nvim.enable = lib.mkDefault true;
          helix.enable = lib.mkDefault true;
        };
      };
    })
  ];
}
