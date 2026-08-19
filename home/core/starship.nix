{
  config,
  lib,
  ...
}:
let
  cfg = config.myHome.core.starship;
  theme = "end-4/dots-hyprland";
  themeSettings = builtins.fromTOML (builtins.readFile ./themes/end-4/dots-hyprland/starship.toml);
in
{
  options.myHome.core.starship = {
    enable = lib.mkEnableOption "Starship prompt";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = lib.mkForce true;
      settings = {
        add_newline = false;
        aws.disabled = true;
        gcloud.disabled = true;
        line_break.disabled = true;
      }
      // lib.optionalAttrs (cfg.theme == theme) themeSettings;
    };
    home.file."${config.home.homeDirectory}/.config/starship.toml".force = true;
  };
}
