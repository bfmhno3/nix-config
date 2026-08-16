{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    lazygit
    uv
    bun
    ast-grep
    gh
    inputs.omp.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
