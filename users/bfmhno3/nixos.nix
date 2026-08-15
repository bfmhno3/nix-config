{
  inputs,
  pkgs,
  username,
  ...
}:
{
  users.users.${username} = {
    extraGroups = [
      "docker"
      "wireshark"
    ];
    packages = with pkgs; [
      kdePackages.kate
      vscode
      jetbrains.clion
      lazygit
      uv
      rustup
      cmake
      gcc
      clang-tools
      openocd
      localsend
      easytier
      gimp
      texlive.combined.scheme-full

      google-drive-ocamlfuse
      telegram-desktop
      zotero
      obsidian
      typora
      kicad
      android-tools
      ffmpeg
      ast-grep
      drawio
      freecad
      gh
      imhex
      inkscape
      neovim
      rpi-imager
      zeal
      zed-editor
      serial-studio
      tio
    ];
  };

  environment.systemPackages = [
    pkgs.google-chrome
    pkgs.bun
    inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.helix
    inputs.omp.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs = {
    steam.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };

  virtualisation.docker.enable = true;
  services.udev.packages = [ pkgs.openocd ];
}
