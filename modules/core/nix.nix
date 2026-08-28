{ config, lib, ... }:
let
  cfg = config.mySystem.core.nix;
  username = config.mySystem.core.base.username;
in
{
  options.mySystem.core.nix.enable = lib.mkEnableOption "Nix configuration";

  config = lib.mkIf cfg.enable {
    nix = {
      settings = {
        trusted-users = [ username ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        substituters = [
          "https://mirror.sjtu.edu.cn/nix-channels/store"
          "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
          "https://mirrors.ustc.edu.cn/nix-channels/store"
          "https://cache.nixos.org"
        ];
        extra-substituters = [
          "https://nix-community.cachix.org"
          "https://nixpkgs-wayland.cachix.org"
        ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        ];
        builders-use-substitutes = true;
      };
      gc = {
        automatic = lib.mkDefault true;
        dates = lib.mkDefault "weekly";
        options = lib.mkDefault "--delete-older-than 7d";
      };
      optimise.automatic = true;
    };

    nixpkgs.config.allowUnfree = true;
  };
}
