{ ... }:
{
  imports = [
    ./core
    ./apps/media.nix
    ./apps/communication.nix
    ./apps/viewer.nix
    ./apps/productivity.nix
    ./desktop/hyprland
    ./desktop/hyprland/components/hyprland.nix
    ./desktop/hyprland/components/quickshell.nix
    ./desktop/hyprland/components/appearance.nix
    ./desktop/hyprland/components/terminals.nix
    ./desktop/hyprland/components/shell.nix
    ./desktop/hyprland/components/applications.nix
    ./desktop/hyprland/components/services.nix
    ./desktop/common/theme.nix
    ./desktop/common/fonts.nix
    ./desktop/common/xdg.nix
    ./desktop/common/input-method.nix
    ./desktop/terminals/foot.nix
    ./dev/tools.nix
    ./dev/uv.nix
    ./dev/vscode.nix
    ./dev/gdb.nix
  ];
}
