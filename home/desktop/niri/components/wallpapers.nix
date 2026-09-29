{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.myHome.desktop.niri.components.wallpapers;
  theme = "ech678/Nyxuri";
  wallpaperDir = "${config.xdg.userDirs.pictures}/Wallpapers";
in
{
  options.myHome.desktop.niri.components.wallpapers = {
    enable = lib.mkEnableOption "Nyxuri wallpapers";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ theme ]);
      default = null;
    };
  };

  config = lib.mkIf (cfg.enable && cfg.theme == theme) {
    home.activation.installNyxuriWallpapers = config.lib.dag.entryAfter [ "linkGeneration" ] ''
      ${pkgs.coreutils}/bin/mkdir -p "${wallpaperDir}/video"
      ${pkgs.coreutils}/bin/cp --update=none --no-preserve=mode ${inputs.nyxuri}/assets/wallpapers/* "${wallpaperDir}/"
    '';
  };
}
