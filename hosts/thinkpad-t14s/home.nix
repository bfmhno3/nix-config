{
  gitEmail,
  gitName,
  stateVersion,
  username,
  ...
}:
{
  myHome = {
    core = {
      user = {
        enable = true;
        inherit username stateVersion;
      };
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

    desktop = {
      hyprland = {
        enable = true;
        monitorConfig = builtins.readFile ./monitors.lua;
      };
      common = {
        theme.enable = true;
        fonts = {
          enable = true;
          cursorSize = 16;
          dpi = 172;
        };
        xdg.enable = true;
        inputMethod.enable = true;
      };
      terminals.foot.enable = true;
    };

    apps = {
      media.enable = true;
      viewer.enable = true;
      productivity.enable = true;
    };

    dev = {
      tools.enable = true;
      uv.enable = true;
      vscode.enable = true;
      gdb.enable = true;
    };
  };
}
