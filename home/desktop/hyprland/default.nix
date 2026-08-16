{
  config,
  hostName,
  pkgs,
  ...
}:
{
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
        ${builtins.readFile ../../../hosts/${hostName}/monitors.lua}
        LUAEOF

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
}
