{ ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    keyMode = "vi";
    clock24 = true;
  };
}
