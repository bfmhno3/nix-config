{
  pkgs,
  username,
  ...
}:
{
  users.users.${username}.extraGroups = [ "adbusers" ];
  environment.systemPackages = [
    pkgs.android-studio
    pkgs.android-tools
  ];
}
