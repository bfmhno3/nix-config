{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.myHome.desktop.niri.components.noctalia;
  nyxmellow = config.myHome.desktop.niri.components.nyxmellow;
  theme = "ech678/Nyxuri";
  enabled = cfg.enable && cfg.theme == theme;
  nyxmellowEnabled = nyxmellow.enable && nyxmellow.theme == theme;
  src = "${inputs.nyxuri}/configs/noctalia";

  upstream = lib.importTOML "${src}/noctalia-config.toml";
  wallpaperDir = "${config.xdg.userDirs.pictures}/Wallpapers";
  replaceHome = lib.replaceStrings [ "/home/user" ] [ config.home.homeDirectory ];
  # NyxMellow template inputs exist only when the NyxMellow component installs them.
  userTemplates =
    lib.mapAttrs
      (
        _: t:
        t
        // {
          input_path = replaceHome t.input_path;
          output_path = replaceHome t.output_path;
        }
      )
      (
        lib.filterAttrs (
          n: _: nyxmellowEnabled || !lib.hasPrefix "nyxmellow_" n
        ) upstream.theme.templates.user
      );
  base = upstream // {
    hooks =
      assert lib.assertMsg (
        upstream.hooks.theme_mode_changed == "nyxuri theme sync"
      ) "Nyxuri theme hook changed upstream; review noctalia.nix";
      upstream.hooks // { theme_mode_changed = "~/.config/noctalia/theme-sync.sh"; };
    theme = upstream.theme // {
      templates = upstream.theme.templates // {
        user = userTemplates;
      };
    };
    wallpaper = upstream.wallpaper // {
      directory = wallpaperDir;
    };
    plugin_settings = upstream.plugin_settings // {
      "noctalia/mpvpaper" = upstream.plugin_settings."noctalia/mpvpaper" // {
        video_directory = "${wallpaperDir}/video";
      };
    };
  };
  configFile = (pkgs.formats.toml { }).generate "noctalia-config.toml" (
    lib.recursiveUpdate base cfg.settings
  );

  staged = pkgs.runCommandLocal "nyxuri-noctalia" { } ''
    d="$out/source/.config/noctalia"
    s="$out/seed/.config/noctalia"
    mkdir -p "$d" "$s/tools"
    cp -r ${src}/. "$d"
    chmod -R u+w "$out"
    rm "$d/.module.toml" "$d/README.md"
    cp ${configFile} "$d/noctalia-config.toml"

    substituteInPlace "$d/wallpaper-hook.sh" "$d/mpvpaper-sync.sh" \
      --replace-fail '#!/bin/bash' '#!/usr/bin/env bash'
    substituteInPlace "$d/tools/orbit-launcher.py" "$d/tools/wallpaper-picker.py" \
      --replace-fail '#!/usr/bin/env python3' '#!${pkgs.nyxuri-python}/bin/python3'

    mv "$d/tools/orbit-items__custom__.toml" "$s/tools/"
    ${lib.optionalString (cfg.orbitItems != null) ''
      cp ${pkgs.writeText "orbit-items__custom__.toml" cfg.orbitItems} "$d/tools/orbit-items__custom__.toml"
      rm "$s/tools/orbit-items__custom__.toml"
    ''}

    chmod 0755 "$d/theme-sync.sh" "$d/wallpaper-hook.sh" "$d/mpvpaper-sync.sh" "$d"/tools/*.py
  '';
  reconcile = import ../../common/reconcile.nix { inherit config lib pkgs; };
  noctaliaBin = "${pkgs.noctalia}/bin/noctalia";
in
{
  options.myHome.desktop.niri.components.noctalia = {
    enable = lib.mkEnableOption "Nyxuri Noctalia shell configuration";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Noctalia settings merged recursively over the Nyxuri noctalia-config.toml";
    };
    orbitItems = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      description = "Orbit tools/orbit-items__custom__.toml; null keeps the local file";
    };
  };

  config = {
    home.packages = lib.mkIf enabled (
      with pkgs;
      [
        noctalia
        adw-gtk3
        glib
        ffmpeg
        inotify-tools
        jq
        mpvpaper
        libnotify
      ]
    );
    home.activation = lib.mkMerge [
      (reconcile {
        name = "reconcileNyxuriNoctalia";
        scope = "nyxuri";
        component = "noctalia";
        inherit enabled;
        source = "${staged}/source";
        seed = "${staged}/seed";
        identity = "${theme}:${staged}";
      })
      {
        # Reconcile overwrites Noctalia's in-place kitty and starship palette edits; re-render them in a running session.
        refreshNyxuriTemplates = lib.mkIf enabled (
          config.lib.dag.entryAfter
            [
              "linkGeneration"
              "reconcileNyxuriNiri"
              "reconcileNyxuriNoctalia"
              "reconcileNyxuriKitty"
              "reconcileNyxuriStarship"
            ]
            ''
              export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(${pkgs.coreutils}/bin/id -u)}"
              if ${noctaliaBin} msg status >/dev/null 2>&1; then
                ${noctaliaBin} msg config-reload >/dev/null 2>&1 || true
                ${noctaliaBin} msg templates-apply >/dev/null 2>&1 || true
              fi
            ''
        );
      }
    ];
  };
}
