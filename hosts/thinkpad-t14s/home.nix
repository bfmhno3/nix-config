{
  myHome = {
    core.enable = true;

    desktop = {
      niri = {
        enable = true;
        themes = "ech678/Nyxuri";
        monitorConfig = builtins.readFile ./monitor.kdl;
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
    };

    apps = {
      media.enable = true;
      communication.enable = true;
      qq = {
        enable = true;
        scale = 2;
      };
      wechat = {
        enable = true;
        scale = 2;
      };
      viewer.enable = true;
      productivity.enable = true;
      ccSwitch.enable = true;
      codexDesktop.enable = true;
    };

    dev = {
      tools.enable = true;
      omp.enable = true;
      uv.enable = true;
      vscode.enable = true;
      gdb.enable = true;
      codex.enable = true;
      claudeCode.enable = true;
    };
  };
}
