{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.desktop.hyprland.components.services;
  theme = "end-4/dots-hyprland";
  active = cfg.enable && cfg.theme == theme;
  idleEnabled = active && cfg.features.idleLock;
  assets = ../themes/end-4/dots-hyprland/services;
  lockAssets = pkgs.runCommandLocal "end-4-dots-hyprland-lock-assets" { } ''
    mkdir -p "$out/.config/hypr"
    cp -a ${assets}/.config/hypr/hyprlock "$out/.config/hypr/"
  '';
  featureOption = name: {
    type = lib.types.bool;
    default = false;
    description = "Whether the ${name} service feature provides its runtime dependencies and managed configuration. Quickshell UI visibility and detailed values are controlled through myHome.desktop.hyprland.components.quickshell.settings.";
  };
  reconcile = import ./reconcile.nix { inherit config lib pkgs; };
in
{
  options.myHome.desktop.hyprland.components.services = {
    enable = lib.mkEnableOption "repository-owned desktop services";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
    features = {
      audio = lib.mkOption (featureOption "audio");
      backlight = lib.mkOption (featureOption "backlight");
      bluetooth = lib.mkOption (featureOption "Bluetooth");
      network = lib.mkOption (featureOption "network");
      idleLock = lib.mkOption (featureOption "idle and lock");
      screenCapture = lib.mkOption (featureOption "screen capture");
      screenRecording = lib.mkOption (featureOption "screen recording");
      onScreenKeyboard = lib.mkOption (featureOption "on-screen keyboard");
      musicRecognition = lib.mkOption (featureOption "music recognition");
      translation = lib.mkOption (featureOption "translation");
      wallpaper = lib.mkOption (featureOption "wallpaper");
      ai = lib.mkOption (featureOption "AI");
      kdeIntegration = lib.mkOption (featureOption "KDE integration");
    };
  };

  config = {
    home.packages =
      lib.optionals active [ pkgs.rsync ]
      ++ lib.optionals (active && cfg.features.audio) (
        with pkgs;
        [
          libcava
          lxqt.pavucontrol-qt
          easyeffects
          libdbusmenu-gtk3
          playerctl
        ]
      )
      ++ lib.optionals (active && cfg.features.backlight) [
        pkgs.brightnessctl
        pkgs.ddcutil
        (pkgs.geoclue2.override { withDemoAgent = true; })
      ]
      ++ lib.optionals (active && cfg.features.bluetooth) [ pkgs.kdePackages.bluedevil ]
      ++ lib.optionals (active && cfg.features.network) [
        pkgs.networkmanager
        pkgs.kdePackages.plasma-nm
      ]
      ++ lib.optionals idleEnabled [
        pkgs.hypridle
        pkgs.hyprlock
        pkgs.swaylock
      ]
      ++ lib.optionals (active && cfg.features.screenCapture) [
        pkgs.hyprshot
        pkgs.grim
        pkgs.slurp
        pkgs.swappy
        pkgs.tesseract5
      ]
      ++ lib.optionals (active && cfg.features.screenRecording) [ pkgs.wf-recorder ]
      ++ lib.optionals (active && cfg.features.onScreenKeyboard) [ pkgs.wtype ]
      ++ lib.optionals (active && cfg.features.musicRecognition) [ pkgs.songrec ]
      ++ lib.optionals (active && cfg.features.translation) [ pkgs.translate-shell ]
      ++ lib.optionals (active && cfg.features.wallpaper) [
        pkgs.mpv
        pkgs.mpvpaper
        pkgs.imagemagick
      ]
      ++ lib.optionals (active && cfg.features.kdeIntegration) [
        pkgs.gnome-keyring
        pkgs.kdePackages.polkit-kde-agent-1
        pkgs.kdePackages.dolphin
        pkgs.kdePackages.systemsettings
        pkgs.kdePackages.kdialog
        pkgs.kdePackages.kconfig
      ];

    home.activation.reconcileHyprlandServices = reconcile {
      component = "services";
      enabled = idleEnabled;
      source = lockAssets;
      identity = "${theme}:${lockAssets}";
    };

    home.activation.configureHyprlandLockServices =
      config.lib.dag.entryAfter [ "reconcileHyprlandServices" ]
        ''
          set -eu

          config_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
          state_home="''${XDG_STATE_HOME:-$HOME/.local/state}"
          state_dir="$state_home/nix-config/hyprland-theme"
          marker="$state_dir/services.marker"
          legacy_marker="$state_home/quickshell/.nix-upstream-revision"
          ${pkgs.coreutils}/bin/mkdir -p "$state_dir" "$config_home/hypr"

          ${lib.optionalString idleEnabled ''
            identity='${theme}:${assets}'
            if [ ! -e "$marker" ]; then
              if [ -e "$legacy_marker" ]; then
                ${pkgs.coreutils}/bin/install -Dm644 ${assets}/.config/hypr/hypridle.conf "$config_home/hypr/hypridle.conf.new"
                ${pkgs.coreutils}/bin/install -Dm644 ${assets}/.config/hypr/hyprlock.conf "$config_home/hypr/hyprlock.conf.new"
                mode=proposal
              else
                for name in hypridle.conf hyprlock.conf; do
                  if [ -e "$config_home/hypr/$name" ]; then
                    ${pkgs.coreutils}/bin/cp -a "$config_home/hypr/$name" "$config_home/hypr/$name.old"
                  fi
                done
                ${pkgs.coreutils}/bin/install -Dm644 ${assets}/.config/hypr/hypridle.conf "$config_home/hypr/hypridle.conf"
                ${pkgs.coreutils}/bin/install -Dm644 ${assets}/.config/hypr/hyprlock.conf "$config_home/hypr/hyprlock.conf"
                mode=owned
              fi
              printf '%s\n%s\n' "$identity" "$mode" > "$marker"
              ${pkgs.coreutils}/bin/rm -f "$legacy_marker"
            else
              old_identity="$(${pkgs.gnused}/bin/sed -n '1p' "$marker")"
              mode="$(${pkgs.gnused}/bin/sed -n '2p' "$marker")"
              if [ "$old_identity" != "$identity" ]; then
                ${pkgs.coreutils}/bin/install -Dm644 ${assets}/.config/hypr/hypridle.conf "$config_home/hypr/hypridle.conf.new"
                ${pkgs.coreutils}/bin/install -Dm644 ${assets}/.config/hypr/hyprlock.conf "$config_home/hypr/hyprlock.conf.new"
                printf '%s\n%s\n' "$identity" "$mode" > "$marker"
              fi
            fi
          ''}
          ${lib.optionalString (!idleEnabled) ''
            if [ -e "$marker" ]; then
              mode="$(${pkgs.gnused}/bin/sed -n '2p' "$marker")"
              if [ "$mode" = owned ]; then
                ${pkgs.coreutils}/bin/rm -f "$config_home/hypr/hypridle.conf" "$config_home/hypr/hyprlock.conf"
              fi
              ${pkgs.coreutils}/bin/rm -f "$config_home/hypr/hypridle.conf.new" "$config_home/hypr/hyprlock.conf.new" "$marker"
            fi
          ''}
        '';
  };
}
