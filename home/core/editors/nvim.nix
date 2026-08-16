{ config, lib, ... }:
let
  cfg = config.myHome.core.editors.nvim;
in
{
  options.myHome.core.editors.nvim.enable = lib.mkEnableOption "Neovim editor";
  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
