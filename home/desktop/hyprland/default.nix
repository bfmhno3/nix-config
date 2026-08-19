{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.desktop.hyprland;
  revision = lib.strings.removeSuffix "\n" (builtins.readFile ./upstream-revision);
  python = pkgs.python3.withPackages (
    ps: with ps; [
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
      google-auth
      requests
    ]
  );
  defaultConfig = pkgs.writeText "illogical-impulse-config.json" "{}\n";
  fishSessionVariables = pkgs.runCommandLocal "hm-session-vars.fish" { } ''
    mkdir -p "$out/etc/profile.d"
    {
      echo "function setup_hm_session_vars;"
      ${pkgs.buildPackages.babelfish}/bin/babelfish \
        < ${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh
      echo "end"
      echo "setup_hm_session_vars"
    } > "$out/etc/profile.d/hm-session-vars.fish"
  '';
  stagedConfig =
    pkgs.runCommand "illogical-impulse-config-${revision}"
      {
        nativeBuildInputs = with pkgs; [
          gnugrep
          gnused
        ];
      }
      ''
        cp -a ${./upstream}/dots/. "$out"
        chmod -R u+w "$out"
        cp ${./upstream}/dots-extra/via-nix/hypridle.conf "$out/.config/hypr/hypridle-nix.conf"

        require_once() {
          count="$(grep -Foc -- "$2" "$1" || true)"
          if [ "$count" -ne 1 ]; then
            echo "Expected exactly one '$2' in $1, found $count" >&2
            exit 1
          fi
        }

        fish="$out/.config/fish/config.fish"
        require_once "$fish" "# Commands to run in interactive sessions can go here"
        cat >> "$fish" <<'FISH'

        source ${fishSessionVariables}/etc/profile.d/hm-session-vars.fish
        FISH

        generator="$out/.config/quickshell/ii/scripts/colors/generate_colors_material.py"
        require_once "$generator" "material_colors['primary_paletteKeyColor']"
        substituteInPlace "$generator" \
          --replace-fail "material_colors['primary_paletteKeyColor']" "material_colors.get('primary_paletteKeyColor', material_colors['primary'])"

        applycolor="$out/.config/quickshell/ii/scripts/colors/applycolor.sh"
        require_once "$applycolor" 'kill -SIGUSR1 $(pidof kitty)'
        substituteInPlace "$applycolor" \
          --replace-fail 'kill -SIGUSR1 $(pidof kitty)' 'pkill -SIGUSR1 kitty || true'

        env="$out/.config/hypr/custom/env.lua"
        if [ -n "$(cat "$env")" ]; then
          echo "Expected empty upstream custom/env.lua" >&2
          exit 1
        fi
        cat > "$env" <<'LUA'
        local home_dir = os.getenv("HOME")
        local path_old = os.getenv("PATH") or ""
        local xdg_data_dirs_old = os.getenv("XDG_DATA_DIRS") or ""
        hl.env("PATH", home_dir .. "/.nix-profile/bin:/run/current-system/sw/bin:" .. path_old)
        hl.env("XDG_DATA_DIRS", home_dir .. "/.nix-profile/share:/run/current-system/sw/share:" .. xdg_data_dirs_old)
        hl.env("QT_QPA_PLATFORMTHEME", "kde")
        LUA

        general="$out/.config/hypr/custom/general.lua"
        if [ -n "$(cat "$general")" ]; then
          echo "Expected empty upstream custom/general.lua" >&2
          exit 1
        fi
        cat > "$general" <<'LUA'
        ${cfg.monitorConfig}
        LUA

        foot="$out/.config/foot/foot.ini"
        require_once "$foot" 'font=JetBrainsMono Nerd Font:size=11'
        substituteInPlace "$foot" \
          --replace-fail 'font=JetBrainsMono Nerd Font:size=11' 'font=Maple Mono NF CN:size=11'

        kitty="$out/.config/kitty/kitty.conf"
        require_once "$kitty" 'font_family      JetBrains Mono Nerd Font'
        substituteInPlace "$kitty" \
          --replace-fail 'font_family      JetBrains Mono Nerd Font' 'font_family family="Maple Mono NF CN" features="+calt"'
        sed -i '/^font_family family="Maple Mono NF CN"/a disable_ligatures never' "$kitty"

        kdeglobals="$out/.config/kdeglobals"
        require_once "$kdeglobals" 'fixed=JetBrainsMono Nerd Font,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1'
        substituteInPlace "$kdeglobals" \
          --replace-fail 'fixed=JetBrainsMono Nerd Font,11,' 'fixed=Maple Mono NF CN,11,'

        reload_popup="$out/.config/quickshell/ii/ReloadPopup.qml"
        require_once "$reload_popup" 'font.family: "JetBrains Mono NF"'
        substituteInPlace "$reload_popup" \
          --replace-fail 'font.family: "JetBrains Mono NF"' 'font.family: "Maple Mono NF CN"'

        shell_config="$out/.config/quickshell/ii/modules/common/Config.qml"
        require_once "$shell_config" 'property string iconNerd: "JetBrains Mono NF"'
        require_once "$shell_config" 'property string monospace: "JetBrains Mono NF"'
        substituteInPlace "$shell_config" \
          --replace-fail 'property string iconNerd: "JetBrains Mono NF"' 'property string iconNerd: "Maple Mono NF CN"' \
          --replace-fail 'property string monospace: "JetBrains Mono NF"' 'property string monospace: "Maple Mono NF CN"'

        latex="$out/.config/quickshell/ii/services/LatexRenderer.qml"
        require_once "$latex" 'property string microtexBinaryDir: "/opt/MicroTeX"'
        substituteInPlace "$latex" \
          --replace-fail 'property string microtexBinaryDir: "/opt/MicroTeX"' 'property string microtexBinaryDir: "${pkgs.illogical-impulse-microtex}/libexec/MicroTeX"'
      '';
in
{
  options.myHome.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland user environment";
    monitorConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Host-specific Illogical Impulse monitor configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      illogical-impulse-quickshell
      illogical-impulse-microtex
      python
      inetutils
      libnotify
      dbus
      glib
      xlsclients
      foot
      kitty
      fish
      fuzzel
      matugen
      mpv
      mpvpaper
      easyeffects
      adw-gtk3
      kdePackages.breeze
      kdePackages.breeze-icons
      darkly
      eza
      fontconfig
      starship
      libcava
      lxqt.pavucontrol-qt
      libdbusmenu-gtk3
      playerctl
      brightnessctl
      ddcutil
      (geoclue2.override { withDemoAgent = true; })
      bc
      cliphist
      curl
      wget
      ripgrep
      jq
      xdg-user-dirs
      xdg-utils
      rsync
      yq-go
      bibata-cursors
      hyprsunset
      wl-clipboard
      gnome-keyring
      kdePackages.bluedevil
      networkmanager
      kdePackages.plasma-nm
      kdePackages.polkit-kde-agent-1
      kdePackages.dolphin
      kdePackages.systemsettings
      kdePackages.kdialog
      kdePackages.kconfig
      hyprshot
      grim
      slurp
      swappy
      tesseract5
      wf-recorder
      upower
      wtype
      imagemagick
      hypridle
      hyprlock
      hyprpicker
      songrec
      translate-shell
      wlogout
      libqalculate
    ];

    home.sessionVariables.ILLOGICAL_IMPULSE_VIRTUAL_ENV = "${config.xdg.stateHome}/quickshell/.venv";

    home.activation.installIllogicalImpulse = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      set -eu

      config_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
      data_home="''${XDG_DATA_HOME:-$HOME/.local/share}"
      state_home="''${XDG_STATE_HOME:-$HOME/.local/state}"
      stage=${stagedConfig}

      ${pkgs.coreutils}/bin/mkdir -p "$config_home" "$data_home/icons" "$state_home/quickshell" "$config_home/hypr/custom"

      for source in "$stage/.config"/*; do
        name="$(${pkgs.coreutils}/bin/basename "$source")"
        case "$name" in
          fish|hypr|quickshell|fontconfig|illogical-impulse) continue ;;
        esac
        if [ -d "$source" ]; then
          ${pkgs.rsync}/bin/rsync -a --chmod=Du+w,Fu+w --delete "$source/" "$config_home/$name/"
        else
          ${pkgs.coreutils}/bin/install -Dm644 "$source" "$config_home/$name"
        fi
      done

      ${pkgs.rsync}/bin/rsync -a --chmod=Du+w,Fu+w --delete "$stage/.config/quickshell/" "$config_home/quickshell/"
      ${pkgs.rsync}/bin/rsync -a --chmod=Du+w,Fu+w --delete --exclude=/conf.d/ "$stage/.config/fish/" "$config_home/fish/"
      ${pkgs.rsync}/bin/rsync -a --chmod=Du+w,Fu+w --delete "$stage/.config/fontconfig/" "$config_home/fontconfig/"
      ${pkgs.rsync}/bin/rsync -a --chmod=Du+w,Fu+w --delete "$stage/.config/hypr/hyprland/" "$config_home/hypr/hyprland/"
      ${pkgs.coreutils}/bin/install -Dm644 "$stage/.config/hypr/hyprland.lua" "$config_home/hypr/hyprland.lua"
      ${pkgs.coreutils}/bin/install -Dm644 "$stage/.config/hypr/custom/env.lua" "$config_home/hypr/custom/env.lua"
      ${pkgs.coreutils}/bin/install -Dm644 "$stage/.config/hypr/custom/general.lua" "$config_home/hypr/custom/general.lua"
      ${pkgs.rsync}/bin/rsync -a --chmod=Du+w,Fu+w "$stage/.local/share/konsole/" "$data_home/konsole/"
      ${pkgs.coreutils}/bin/install -Dm644 "$stage/.local/share/icons/illogical-impulse.svg" "$data_home/icons/illogical-impulse.svg"

      revision_file="$state_home/quickshell/.nix-upstream-revision"
      if [ ! -e "$revision_file" ]; then
        for name in hypridle.conf hyprlock.conf; do
          if [ -e "$config_home/hypr/$name" ]; then
            ${pkgs.coreutils}/bin/cp -a "$config_home/hypr/$name" "$config_home/hypr/$name.old"
          fi
        done
        ${pkgs.coreutils}/bin/install -Dm644 "$stage/.config/hypr/hypridle-nix.conf" "$config_home/hypr/hypridle.conf"
        ${pkgs.coreutils}/bin/install -Dm644 "$stage/.config/hypr/hyprlock.conf" "$config_home/hypr/hyprlock.conf"
      elif [ "$(cat "$revision_file")" != "${revision}" ]; then
        ${pkgs.coreutils}/bin/install -Dm644 "$stage/.config/hypr/hypridle-nix.conf" "$config_home/hypr/hypridle.conf.new"
        ${pkgs.coreutils}/bin/install -Dm644 "$stage/.config/hypr/hyprlock.conf" "$config_home/hypr/hyprlock.conf.new"
      fi
      printf '%s\n' '${revision}' > "$revision_file"

      ${pkgs.coreutils}/bin/mkdir -p "$config_home/illogical-impulse"
      font_config="$config_home/illogical-impulse/config.json"
      if [ ! -e "$font_config" ]; then
        ${pkgs.coreutils}/bin/cp ${defaultConfig} "$font_config"
      fi
      ${pkgs.jq}/bin/jq -e . "$font_config" > /dev/null
      font_config_tmp="$(${pkgs.coreutils}/bin/mktemp "$font_config.tmp.XXXXXX")"
      trap '${pkgs.coreutils}/bin/rm -f "$font_config_tmp"' EXIT
      ${pkgs.jq}/bin/jq \
        '.appearance.fonts.monospace = "Maple Mono NF CN" | .appearance.fonts.iconNerd = "Maple Mono NF CN"' \
        "$font_config" > "$font_config_tmp"
      ${pkgs.coreutils}/bin/chmod --reference="$font_config" "$font_config_tmp"
      ${pkgs.coreutils}/bin/mv "$font_config_tmp" "$font_config"
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

      theme="$state_home/quickshell/user/generated/terminal/kitty-theme.conf"
      if [ -f "$theme" ] && ${pkgs.gnugrep}/bin/grep -q '#$' "$theme"; then
        cat > "$theme" <<'KITTY'
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
    '';
  };
}
