{
  username,
  stateVersion,
  ...
}:
{
  imports = [
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./tmux.nix
    ./starship.nix
    ./editors/nvim.nix
    ./editors/helix.nix
  ];

  home = {
    inherit username stateVersion;
    homeDirectory = "/home/${username}";
  };
}
