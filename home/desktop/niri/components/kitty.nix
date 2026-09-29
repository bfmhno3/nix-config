{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.myHome.desktop.niri.components.kitty;
  terminals = config.myHome.desktop.hyprland.components.terminals;
  theme = "ech678/Nyxuri";
  enabled = cfg.enable && cfg.theme == theme;
  src = "${inputs.nyxuri}/configs/kitty";
  # Kitty presets are standalone trees; .module.toml declares no inheritance.
  root = if cfg.preset == "default" then src else "${src}/__presets__/${cfg.preset}";
  staged = pkgs.runCommandLocal "nyxuri-kitty" { } ''
    d="$out/source/.config/kitty"
    s="$out/seed/.config/kitty"
    mkdir -p "$d" "$s/themes"
    cp -r ${root}/. "$d"
    chmod -R u+w "$out"
    rm -rf "$d/__presets__" "$d/.module.toml"

    mv "$d/__custom__.conf" "$s/__custom__.conf"
    mv "$d/themes/noctalia.conf" "$s/themes/noctalia.conf"
    ${lib.optionalString (cfg.customConfig != null) ''
      cp ${pkgs.writeText "kitty-custom.conf" cfg.customConfig} "$d/__custom__.conf"
      rm "$s/__custom__.conf"
    ''}
  '';
  reconcile = import ../../common/reconcile.nix { inherit config lib pkgs; };
in
{
  options.myHome.desktop.niri.components.kitty = {
    enable = lib.mkEnableOption "Nyxuri kitty configuration";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
    preset = lib.mkOption {
      type = lib.types.enum ([ "default" ] ++ builtins.attrNames (builtins.readDir "${src}/__presets__"));
      default = "default";
      description = "Nyxuri kitty preset";
    };
    customConfig = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      description = "kitty __custom__.conf; null keeps the local file";
    };
  };

  config = {
    assertions = [
      {
        assertion = !(enabled && terminals.enable && terminals.theme == "end-4/dots-hyprland");
        message = "Nyxuri kitty and end-4 terminals both manage ~/.config/kitty";
      }
    ];
    home.packages = lib.mkIf enabled (
      with pkgs;
      [
        kitty
        fish
        wl-clipboard
      ]
    );
    home.activation = reconcile {
      name = "reconcileNyxuriKitty";
      scope = "nyxuri";
      component = "kitty";
      inherit enabled;
      source = "${staged}/source";
      seed = "${staged}/seed";
      identity = "${theme}:${staged}";
    };
  };
}
