{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.helix ];
}
