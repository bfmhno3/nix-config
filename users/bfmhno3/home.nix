{ pkgs, ... }: {
  imports = [
    ../../home/core.nix
    ../../home/fcitx5
    ../../home/programs
  ];

  programs.git = {
    settings = {
      user = {
        name = "bfmhno3";
        email = "858446559@qq.com";
      };
    };
  };
}

