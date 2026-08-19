{ config, lib, ... }:
let
  cfg = config.myHome.core.user;
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

  options.myHome.core.user = {
    enable = lib.mkEnableOption "Home Manager user configuration";
    username = lib.mkOption {
      type = lib.types.str;
    };
    stateVersion = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      username = cfg.username;
      homeDirectory = "/home/${cfg.username}";
      stateVersion = cfg.stateVersion;
    };
  };
}
