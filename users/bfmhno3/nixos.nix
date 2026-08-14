{
  inputs,
  pkgs,
  username,
  ...
}:
{
  users.users.${username}.packages = [ pkgs.kdePackages.kate ];

  environment.systemPackages = [
    pkgs.google-chrome
    pkgs.bun
    inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.helix
    inputs.omp.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
