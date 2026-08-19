{
  config,
  lib,
  ...
}:
let
  cfg = config.myHome.desktop.terminals.foot;
  theme = "end-4/dots-hyprland";
in
{
  options.myHome.desktop.terminals.foot = {
    enable = lib.mkEnableOption "Foot terminal";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
      settings = lib.mkIf (cfg.theme == theme) {
        main = {
          shell = "fish";
          term = "xterm-256color";
          title = "foot";
          font = "Maple Mono NF CN:size=11";
          letter-spacing = 0;
          dpi-aware = "no";
          pad = "25x25";
          bold-text-in-bright = "no";
        };
        scrollback.lines = 10000;
        cursor = {
          style = "beam";
          blink = "no";
          beam-thickness = 1.5;
        };
        key-bindings = {
          scrollback-up-page = "Page_Up";
          scrollback-down-page = "Page_Down";
          clipboard-copy = "Control+c";
          clipboard-paste = "Control+v";
          search-start = "Control+f";
          font-increase = "Control+plus Control+equal Control+KP_Add";
          font-decrease = "Control+minus Control+KP_Subtract";
          font-reset = "Control+0 Control+KP_0";
        };
        search-bindings = {
          cancel = "Escape";
          find-prev = "Shift+F3";
          find-next = "F3 Control+G";
          delete-prev-word = "Control+BackSpace";
        };
        text-bindings."\\x03" = "Control+Shift+c";
      };
    };
    xdg.configFile."foot/foot.ini".force = true;
  };
}
