{ pkgs, ... }:
{
  home.packages = [ pkgs.gdb ];
  home.file.".gdbinit".text = ''
    set pagination off
    set print pretty on
    set confirm off
    set history save on
    set history size 1000
    set history filename ~/.gdb_history
  '';
}
