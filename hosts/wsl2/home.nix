{
  gitEmail,
  gitName,
  stateVersion,
  username,
  ...
}:
{
  myHome.dev.tools.enable = true;
  myHome.dev.omp.enable = true;

  myHome.core = {
    user = {
      enable = true;
      inherit username stateVersion;
    };
    bat.enable = true;
    eza.enable = true;
    packages.enable = true;
    shell.enable = true;
    git = {
      enable = true;
      name = gitName;
      email = gitEmail;
    };
    tmux.enable = true;
    starship.enable = true;
    editors = {
      nvim.enable = true;
      helix.enable = true;
    };
  };
}
