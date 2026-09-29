{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.myHome.desktop.niri.components.fish;
  shell = config.myHome.desktop.hyprland.components.shell;
  theme = "ech678/Nyxuri";
  enabled = cfg.enable && cfg.theme == theme;
  src = "${inputs.nyxuri}/configs/fish";
in
{
  options.myHome.desktop.niri.components.fish = {
    enable = lib.mkEnableOption "Nyxuri fish configuration";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
    customConfig = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      description = "fish conf.d/__custom__.fish";
    };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(enabled && shell.enable && shell.theme == "end-4/dots-hyprland");
          message = "Nyxuri fish and end-4 shell both manage ~/.config/fish";
        }
      ];
    }
    (lib.mkIf enabled {
      programs.fish = {
        enable = true;
        plugins = [
          {
            name = "autopair";
            src = pkgs.fishPlugins.autopair.src;
          }
          {
            name = "fzf-fish";
            src = pkgs.fishPlugins.fzf-fish.src;
          }
        ];
      };
      xdg.configFile = {
        # Replaces a file left by the end-4 shell component during a desktop switch.
        "fish/config.fish".force = true;
        "fish/conf.d/nyxuri.fish".source = "${src}/config.fish";
        "fish/conf.d/nyxuri-path.fish".source = "${src}/conf.d/nyxuri-path.fish";
        "fish/completions/nyxhelp.fish".source = "${src}/completions/nyxhelp.fish";
        "fish/conf.d/__custom__.fish" = lib.mkIf (cfg.customConfig != null) { text = cfg.customConfig; };
      };
      home.packages = with pkgs; [
        fzf
        fd
        bat
        eza
      ];
    })
  ];
}
