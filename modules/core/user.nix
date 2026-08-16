{
  pkgs,
  username,
  ...
}:
{
  users.groups.plugdev = { };
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "dialout"
      "plugdev"
    ];
  };

  programs.zsh.enable = true;
}
