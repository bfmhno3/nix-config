{ config, lib, ... }:
let
  cfg = config.myHome.core.starship;
in
{
  options.myHome.core.starship.enable = lib.mkEnableOption "Starship prompt";
  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = lib.mkForce true;
      settings = {
        add_newline = false;
        aws.disabled = true;
        gcloud.disabled = true;
        line_break.disabled = true;
      };
    };
    home.file."${config.home.homeDirectory}/.config/starship.toml".force = true;
  };
}
