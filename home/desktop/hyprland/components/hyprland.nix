{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.desktop.hyprland.components.hyprland;
  hyprlandCfg = config.myHome.desktop.hyprland;
  theme = "end-4/dots-hyprland";
  enabled = cfg.enable && cfg.theme == theme;
  assets = ../themes/end-4/dots-hyprland/hyprland;
  staged = pkgs.runCommandLocal "end-4-dots-hyprland-hyprland" { } ''
    cp -a ${assets}/. "$out"
    chmod -R u+w "$out"
    rm -rf "$out/.config/hypr/custom"
    mkdir -p "$out/.config/hypr/custom"
    cat > "$out/.config/hypr/custom/env.lua" <<'LUA'
    local home_dir = os.getenv("HOME")
    local path_old = os.getenv("PATH") or ""
    local xdg_data_dirs_old = os.getenv("XDG_DATA_DIRS") or ""
    hl.env("PATH", home_dir .. "/.nix-profile/bin:/run/current-system/sw/bin:" .. path_old)
    hl.env("XDG_DATA_DIRS", home_dir .. "/.nix-profile/share:/run/current-system/sw/share:" .. xdg_data_dirs_old)
    hl.env("QT_QPA_PLATFORMTHEME", "kde")
    LUA
    cat > "$out/.config/hypr/custom/general.lua" <<'LUA'
    ${hyprlandCfg.monitorConfig}
    LUA
  '';
  reconcile = import ./reconcile.nix { inherit config lib pkgs; };
in
{
  options.myHome.desktop.hyprland.components.hyprland = {
    enable = lib.mkEnableOption "repository-owned Hyprland configuration";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
  };

  config = {
    home.packages = lib.mkIf enabled (
      with pkgs;
      [
        inetutils
        libnotify
        dbus
        glib
        xlsclients
        hyprsunset
        wl-clipboard
        upower
        hyprpicker
      ]
    );
    home.activation.reconcileHyprlandTheme = reconcile {
      component = "hyprland";
      inherit enabled;
      source = staged;
      identity = "${theme}:${staged}";
    };
  };
}
