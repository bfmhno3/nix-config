{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.desktop.hyprland;
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
    programs.illogical-impulse = {
      enable = true;
      dotfiles = {
        fish.enable = true;
        kitty.enable = true;
        starship.enable = false;
      };
    };

    home.activation.configureIllogicalImpulse =
      config.lib.dag.entryAfter [ "copyIllogicalImpulseConfigs" ]
        ''
          cat >> "$HOME/.config/fish/config.fish" <<'FISH'
          source ${config.programs.fish.sessionVariablesPackage}/etc/profile.d/hm-session-vars.fish
          FISH

          generator="$HOME/.config/quickshell/ii/scripts/colors/generate_colors_material.py"
          ${pkgs.gnused}/bin/sed -i \
            "s/material_colors\['primary_paletteKeyColor'\]/material_colors.get('primary_paletteKeyColor', material_colors['primary'])/" \
            "$generator"

          applycolor="$HOME/.config/quickshell/ii/scripts/colors/applycolor.sh"
          ${pkgs.gnused}/bin/sed -i \
            's/kill -SIGUSR1 $(pidof kitty)/pkill -SIGUSR1 kitty || true/' \
            "$applycolor"

          general="$HOME/.config/hypr/custom/general.lua"
          # The host monitor topology must follow the upstream configuration copy that replaces this file.
          cat >> "$general" <<'LUAEOF'
          ${cfg.monitorConfig}
          LUAEOF

          require_once() {
            count="$(${pkgs.gnugrep}/bin/grep -Foc -- "$2" "$1" || true)"
            if [ "$count" -ne 1 ]; then
              echo "Expected exactly one '$2' in $1, found $count" >&2
              exit 1
            fi
          }

          foot="$HOME/.config/foot/foot.ini"
          require_once "$foot" 'font=JetBrainsMono Nerd Font:size=11'
          ${pkgs.gnused}/bin/sed -i \
            's/^font=JetBrainsMono Nerd Font:size=11$/font=Maple Mono NF CN:size=11/' \
            "$foot"
          require_once "$foot" 'font=Maple Mono NF CN:size=11'

          kitty="$HOME/.config/kitty/kitty.conf"
          require_once "$kitty" 'font_family      JetBrains Mono Nerd Font'
          if ${pkgs.gnugrep}/bin/grep -Fq 'disable_ligatures' "$kitty"; then
            echo "Unexpected disable_ligatures setting in $kitty" >&2
            exit 1
          fi
          ${pkgs.gnused}/bin/sed -i \
            's/^font_family      JetBrains Mono Nerd Font$/font_family family="Maple Mono NF CN" features="+calt"\ndisable_ligatures never/' \
            "$kitty"
          require_once "$kitty" 'font_family family="Maple Mono NF CN" features="+calt"'
          require_once "$kitty" 'disable_ligatures never'

          kdeglobals="$HOME/.config/kdeglobals"
          require_once "$kdeglobals" 'fixed=JetBrainsMono Nerd Font,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1'
          ${pkgs.gnused}/bin/sed -i \
            's/^fixed=JetBrainsMono Nerd Font,11,/fixed=Maple Mono NF CN,11,/' \
            "$kdeglobals"
          require_once "$kdeglobals" 'fixed=Maple Mono NF CN,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1'

          reload_popup="$HOME/.config/quickshell/ii/ReloadPopup.qml"
          require_once "$reload_popup" 'font.family: "JetBrains Mono NF"'
          ${pkgs.gnused}/bin/sed -i \
            's/font\.family: "JetBrains Mono NF"/font.family: "Maple Mono NF CN"/' \
            "$reload_popup"
          require_once "$reload_popup" 'font.family: "Maple Mono NF CN"'

          ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/illogical-impulse"
          font_config="$HOME/.config/illogical-impulse/config.json"
          font_config_tmp="$(${pkgs.coreutils}/bin/mktemp "$font_config.tmp.XXXXXX")"
          trap '${pkgs.coreutils}/bin/rm -f "$font_config_tmp"' EXIT
          if [ -e "$font_config" ]; then
            ${pkgs.jq}/bin/jq -e . "$font_config" > /dev/null
            ${pkgs.jq}/bin/jq \
              '.appearance.fonts.monospace = "Maple Mono NF CN" | .appearance.fonts.iconNerd = "Maple Mono NF CN"' \
              "$font_config" > "$font_config_tmp"
            ${pkgs.coreutils}/bin/chmod --reference="$font_config" "$font_config_tmp"
          else
            ${pkgs.jq}/bin/jq -n \
              '.appearance.fonts.monospace = "Maple Mono NF CN" | .appearance.fonts.iconNerd = "Maple Mono NF CN"' \
              > "$font_config_tmp"
          fi
          ${pkgs.jq}/bin/jq -e \
            '.appearance.fonts.monospace == "Maple Mono NF CN" and .appearance.fonts.iconNerd == "Maple Mono NF CN"' \
            "$font_config_tmp" > /dev/null
          ${pkgs.coreutils}/bin/mv "$font_config_tmp" "$font_config"
          trap - EXIT
          ${pkgs.jq}/bin/jq -e \
            '.appearance.fonts.monospace == "Maple Mono NF CN" and .appearance.fonts.iconNerd == "Maple Mono NF CN"' \
            "$font_config" > /dev/null

          theme="$HOME/.local/state/quickshell/user/generated/terminal/kitty-theme.conf"
          if [ -f "$theme" ] && ${pkgs.gnugrep}/bin/grep -q '#\$' "$theme"; then
            cat > "$theme" <<'KITTYEOF'
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
          KITTYEOF
          fi
        '';
  };
}
