{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.desktop.hyprland.components.shell;
  theme = "end-4/dots-hyprland";
  enabled = cfg.enable && cfg.theme == theme;
  assets = ../themes/end-4/dots-hyprland/shell;
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
  staged = pkgs.runCommandLocal "end-4-dots-hyprland-shell" { } ''
    cp -a ${assets}/. "$out"
    chmod -R u+w "$out"
    cat >> "$out/.config/fish/config.fish" <<'FISH'

    source ${fishSessionVariables}/etc/profile.d/hm-session-vars.fish

    if not functions -q __direnv_export_eval
      ${config.programs.direnv.package}/bin/direnv hook fish | source
    end

    ${config.programs.zoxide.package}/bin/zoxide init fish --cmd z | source
    FISH
  '';
  reconcile = import ./reconcile.nix { inherit config lib pkgs; };
in
{
  options.myHome.desktop.hyprland.components.shell = {
    enable = lib.mkEnableOption "repository-owned interactive shell configuration";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
  };

  config = {
    home.packages = lib.mkIf enabled (
      with pkgs;
      [
        fish
        eza
      ]
    );
    home.activation.reconcileHyprlandShell = reconcile {
      component = "shell";
      inherit enabled;
      source = staged;
      identity = "${theme}:${staged}";
    };
  };
}
