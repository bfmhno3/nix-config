{ ... }:
{
  imports = [
    ./core
    ./apps/media.nix
    ./apps/communication.nix
    ./apps/viewer.nix
    ./apps/productivity.nix
    ./desktop/hyprland
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
