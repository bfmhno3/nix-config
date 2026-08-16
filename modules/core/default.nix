{ stateVersion, ... }:
{
  imports = [
    ./nix.nix
    ./user.nix
    ./locale.nix
    ./network.nix
  ];

  system.stateVersion = stateVersion;
}
