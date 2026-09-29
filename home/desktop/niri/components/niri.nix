{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.myHome.desktop.niri.components.niri;
  noctalia = config.myHome.desktop.niri.components.noctalia;
  monitorConfig = config.myHome.desktop.niri.monitorConfig;
  theme = "ech678/Nyxuri";
  enabled = cfg.enable && cfg.theme == theme;
  src = "${inputs.nyxuri}/configs/niri";
  variants =
    dir:
    map (lib.removeSuffix ".kdl") (builtins.attrNames (builtins.readDir "${src}/__presets__/${dir}"));
  declare =
    file: text:
    lib.optionalString (text != null) ''
      cp ${pkgs.writeText "niri-${file}" text} "$d/${file}"
      rm "$s/${file}"
    '';
  staged = pkgs.runCommandLocal "nyxuri-niri" { nativeBuildInputs = [ pkgs.niri ]; } ''
    d="$out/source/.config/niri"
    s="$out/seed/.config/niri"
    mkdir -p "$d" "$s"
    cp -r ${src}/. "$d"
    chmod -R u+w "$out"
    rm -rf "$d/__presets__" "$d/.module.toml"

    cp ${src}/__presets__/effects/${cfg.effects}.kdl "$d/effects_normal.kdl"
    cp ${src}/__presets__/glow/${cfg.glow}.kdl "$d/glow.kdl"

    for f in monitor.kdl colors.kdl __custom__.kdl input__custom__.kdl; do
      mv "$d/$f" "$s/$f"
    done
    # config.kdl includes effects.kdl unconditionally, and toggle-eyecare.sh owns it at runtime.
    ln -s effects_normal.kdl "$s/effects.kdl"

    ${declare "monitor.kdl" monitorConfig}
    ${declare "__custom__.kdl" cfg.customConfig}
    ${declare "input__custom__.kdl" cfg.inputConfig}

    substituteInPlace "$d/scripts/toggle-eyecare.sh" "$d/scripts/niri-scratch-toggle.sh" \
      --replace-fail '#!/bin/bash' '#!/usr/bin/env bash'
    substituteInPlace "$d/scripts/niri-scratch-menu.py" \
      --replace-fail '#!/usr/bin/env python3' '#!${pkgs.nyxuri-python}/bin/python3'
    substituteInPlace "$d/config.kdl" \
      --replace-fail 'screenshot-path "~/Pictures/Screenshots/' 'screenshot-path "${config.xdg.userDirs.pictures}/Screenshots/'
    chmod 0755 "$d"/scripts/*

    export HOME="$TMPDIR"
    v="$(mktemp -d)"
    cp -a "$d/." "$v/"
    cp -an "$s/." "$v/"
    niri validate -c "$v/config.kdl"
  '';
  reconcile = import ../../common/reconcile.nix { inherit config lib pkgs; };
in
{
  options.myHome.desktop.niri.components.niri = {
    enable = lib.mkEnableOption "Nyxuri niri configuration";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
    effects = lib.mkOption {
      type = lib.types.enum (variants "effects");
      default = "default";
      description = "Nyxuri effects part";
    };
    glow = lib.mkOption {
      type = lib.types.enum (variants "glow");
      default = "default";
      description = "Nyxuri focus ring and glow part";
    };
    customConfig = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      description = "niri __custom__.kdl; null keeps the local file";
    };
    inputConfig = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      description = "niri input__custom__.kdl; null keeps the local file";
    };
  };

  config = {
    assertions = [
      {
        assertion = !enabled || (noctalia.enable && noctalia.theme == theme);
        message = "myHome.desktop.niri.components.niri requires components.noctalia (session-shell.sh and binds dispatch to Noctalia)";
      }
    ];
    home.packages = lib.mkIf enabled (
      with pkgs;
      [
        jq
        tmux
        util-linux
        libnotify
        wlsunset
        wireplumber
        ddcutil
        procps
        wl-clipboard
        nautilus
        mission-center
        adwaita-icon-theme
        xdg-user-dirs
      ]
    );
    home.activation = reconcile {
      name = "reconcileNyxuriNiri";
      scope = "nyxuri";
      component = "niri";
      inherit enabled;
      source = "${staged}/source";
      seed = "${staged}/seed";
      identity = "${theme}:${staged}";
    };
  };
}
