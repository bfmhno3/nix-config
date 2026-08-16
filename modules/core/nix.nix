{
  lib,
  username,
  ...
}:
{
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
}
