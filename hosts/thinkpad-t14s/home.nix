{ inputs, ... }:
{
  imports = [
    inputs.illogical-flake.homeManagerModules.default
    ../../home/core
    ../../home/desktop/hyprland
    ../../home/desktop/common/theme.nix
    ../../home/desktop/common/fonts.nix
    ../../home/desktop/common/xdg.nix
    ../../home/desktop/common/input-method.nix
    ../../home/desktop/terminals/foot.nix
    ../../home/apps/media.nix
    ../../home/apps/viewer.nix
    ../../home/apps/productivity.nix
    ../../home/dev/tools.nix
    ../../home/dev/vscode.nix
    ../../home/dev/gdb.nix
  ];
}
