{ nixpkgs-unstable }:
_final: prev: {
  # Packages the nixos-26.05 branch has not caught up with are reachable in
  # modules as pkgs.unstable.<attribute>.
  unstable = import nixpkgs-unstable {
    inherit (prev.stdenv.hostPlatform) system;
    config = prev.config;
  };
}
