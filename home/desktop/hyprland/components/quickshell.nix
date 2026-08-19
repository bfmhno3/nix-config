{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.desktop.hyprland.components.quickshell;
  features = config.myHome.desktop.hyprland.components.services.features;
  theme = "end-4/dots-hyprland";
  enabled = cfg.enable && cfg.theme == theme;
  python = pkgs.python3.withPackages (
    ps:
    with ps;
    [
      build
      pillow
      setuptools-scm
      wheel
      pywayland
      psutil
      kde-material-you-colors
      materialyoucolor
      libsass
      material-color-utilities
      setproctitle
      click
      loguru
      pycairo
      pygobject3
      tqdm
      numpy
      (opencv4.override { enableContrib = true; })
    ]
    ++ lib.optionals features.ai [
      google-auth
      requests
    ]
  );
  assets = ../themes/end-4/dots-hyprland/quickshell;
  staged = pkgs.runCommandLocal "end-4-dots-hyprland-quickshell" { } ''
    cp -a ${assets}/. "$out"
    chmod -R u+w "$out"
    substituteInPlace "$out/.config/quickshell/ii/services/LatexRenderer.qml" \
      --replace-fail 'property string microtexBinaryDir: "/opt/MicroTeX"' \
      'property string microtexBinaryDir: "${pkgs.illogical-impulse-microtex}/libexec/MicroTeX"'
  '';
  declaredSettings = pkgs.writeText "illogical-impulse-declared-settings.json" (
    builtins.toJSON cfg.settings
  );
  reconcile = import ./reconcile.nix { inherit config lib pkgs; };
in
{
  options.myHome.desktop.hyprland.components.quickshell = {
    enable = lib.mkEnableOption "repository-owned Quickshell configuration";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Declared Illogical Impulse settings merged recursively over settings UI values";
    };
  };

  config = {
    home.packages = lib.mkIf enabled (
      with pkgs;
      [
        illogical-impulse-quickshell
        illogical-impulse-microtex
        python
        bc
        cliphist
        curl
        wget
        ripgrep
        jq
        xdg-user-dirs
        xdg-utils
        yq-go
        libqalculate
      ]
    );
    home.sessionVariables = lib.mkIf enabled {
      ILLOGICAL_IMPULSE_VIRTUAL_ENV = "${config.xdg.stateHome}/quickshell/.venv";
    };
    home.activation.reconcileQuickshellTheme = reconcile {
      component = "quickshell";
      inherit enabled;
      source = staged;
      identity = "${theme}:${staged}";
    };
    home.activation.configureQuickshellTheme = lib.mkIf enabled (
      config.lib.dag.entryAfter [ "reconcileQuickshellTheme" ] ''
        set -eu

        config_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
        state_home="''${XDG_STATE_HOME:-$HOME/.local/state}"
        ${pkgs.coreutils}/bin/mkdir -p "$config_home/illogical-impulse" "$state_home/quickshell"

        settings="$config_home/illogical-impulse/config.json"
        if [ ! -e "$settings" ]; then
          printf '{}\n' > "$settings"
        fi
        ${pkgs.jq}/bin/jq -e . "$settings" > /dev/null
        settings_tmp="$(${pkgs.coreutils}/bin/mktemp "$settings.tmp.XXXXXX")"
        trap '${pkgs.coreutils}/bin/rm -f "$settings_tmp"' EXIT
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$settings" ${declaredSettings} > "$settings_tmp"
        ${pkgs.coreutils}/bin/chmod --reference="$settings" "$settings_tmp"
        ${pkgs.coreutils}/bin/mv "$settings_tmp" "$settings"
        trap - EXIT

        venv="$state_home/quickshell/.venv"
        if [ -L "$venv" ]; then
          ${pkgs.coreutils}/bin/rm "$venv"
        fi
        ${pkgs.coreutils}/bin/mkdir -p "$venv/bin"
        ${pkgs.coreutils}/bin/rm -f "$venv/bin/activate" "$venv/pyvenv.cfg"
        ${pkgs.coreutils}/bin/ln -sfn ${python}/bin/python "$venv/bin/python"
        ${pkgs.coreutils}/bin/ln -sfn ${python}/bin/python3 "$venv/bin/python3"
        cat > "$venv/bin/activate" <<EOF
        _ILLOGICAL_IMPULSE_OLD_PATH="\$PATH"
        export VIRTUAL_ENV="$venv"
        export PATH="$venv/bin:\$PATH"
        deactivate() {
          PATH="\$_ILLOGICAL_IMPULSE_OLD_PATH"
          export PATH
          unset VIRTUAL_ENV _ILLOGICAL_IMPULSE_OLD_PATH
          unset -f deactivate 2>/dev/null || true
        }
        EOF

        kitty_theme="$state_home/quickshell/user/generated/terminal/kitty-theme.conf"
        if [ -f "$kitty_theme" ] && ${pkgs.gnugrep}/bin/grep -q '#$' "$kitty_theme"; then
          cat > "$kitty_theme" <<'KITTY'
        background #1E1E2E
        foreground #CDD6F4
        cursor #F5E0DC
        selection_background #585B70
        selection_foreground #CDD6F4
        color0 #45475A
        color1 #F38BA8
        color2 #A6E3A1
        color3 #F9E2AF
        color4 #89B4FA
        color5 #F5C2E7
        color6 #94E2D5
        color7 #BAC2DE
        color8 #585B70
        color9 #F38BA8
        color10 #A6E3A1
        color11 #F9E2AF
        color12 #89B4FA
        color13 #F5C2E7
        color14 #94E2D5
        color15 #A6ADC8
        KITTY
        fi
      ''
    );
  };
}
