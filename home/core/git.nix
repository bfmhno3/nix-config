{
  gitName,
  gitEmail,
  ...
}:
{
  programs.git = {
    enable = true;
    settings.user = {
      name = gitName;
      email = gitEmail;
    };
  };
}
