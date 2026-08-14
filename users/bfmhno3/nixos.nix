{
  inputs,
  pkgs,
  username,
  ...
}:
{
  users.users.${username} = {
    extraGroups = [ "docker" ];
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
    ];
  };

  environment.systemPackages = [
    pkgs.google-chrome
    pkgs.bun
    inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.helix
    inputs.omp.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  virtualisation.docker.enable = true;
  services.udev.packages = [ pkgs.openocd ];
}
