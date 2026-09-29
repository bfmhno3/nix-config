{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.myHome.core.starship;
  end4 = "end-4/dots-hyprland";
  nyxuri = "ech678/Nyxuri";
  themeSettings = builtins.fromTOML (builtins.readFile ./themes/end-4/dots-hyprland/starship.toml);
  # Noctalia's starship template writes a palette block into $STARSHIP_CONFIG, so the file must be writable.
  staged = pkgs.runCommandLocal "nyxuri-starship" { } ''
    mkdir -p "$out/.config"
    cp ${inputs.nyxuri}/configs/starship.toml "$out/.config/starship.toml"
  '';
  reconcile = import ../desktop/common/reconcile.nix { inherit config lib pkgs; };
in
{
  options.myHome.core.starship = {
    enable = lib.mkEnableOption "Starship prompt";
    theme = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          end4
          nyxuri
        ]
      );
      default = null;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.starship = {
        enable = lib.mkForce true;
        settings = lib.mkIf (cfg.theme != nyxuri) (
          {
            add_newline = false;
            aws.disabled = true;
            gcloud.disabled = true;
            line_break.disabled = true;
          }
          // lib.optionalAttrs (cfg.theme == end4) themeSettings
        );
      };
      home.file = lib.mkIf (cfg.theme != nyxuri) {
        ${config.programs.starship.configPath}.force = true;
      };
    })
    {
      home.activation = reconcile {
        name = "reconcileNyxuriStarship";
        scope = "nyxuri";
        component = "starship";
        enabled = cfg.enable && cfg.theme == nyxuri;
        source = staged;
        identity = "${nyxuri}:${staged}";
      };
    }
  ];
}
