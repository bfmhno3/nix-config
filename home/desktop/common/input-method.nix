{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.desktop.common.inputMethod;
  rimeIceDefaults = pkgs.writeTextDir "share/rime-data/default.custom.yaml" ''
    patch:
      schema_list:
        - schema: rime_ice
  '';
  rimeIceSimplified = pkgs.writeTextDir "share/rime-data/rime_ice.custom.yaml" ''
    patch:
      switches/@2/reset: 0
  '';
in
{
  options.myHome.desktop.common.inputMethod.enable = lib.mkEnableOption "Fcitx 5 input method";
  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = [
          (pkgs.fcitx5-rime.override {
            rimeDataPkgs = [
              pkgs.rime-data
              pkgs.rime-ice
              rimeIceDefaults
              rimeIceSimplified
            ];
          })
          pkgs.fcitx5-themes-candlelight
        ];
        waylandFrontend = true;
        settings = {
          inputMethod = {
            GroupOrder."0" = "Default";
            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "us";
              DefaultIM = "rime";
            };
            "Groups/0/Items/0".Name = "rime";
            "Groups/0/Items/1".Name = "keyboard-us";
          };
          addons.classicui.globalSection = {
            "Vertical Candidate List" = "False";
            PerScreenDPI = "True";
            Theme = "macOS-dark";
          };
        };
      };
    };

    home.file.".local/share/fcitx5/rime/.nix-rime-package" = {
      text = "${config.i18n.inputMethod.package}\n";
      onChange = ''
        rime_dir="$HOME/.local/share/fcitx5/rime"
        ${pkgs.coreutils}/bin/install -Dm644 \
          "${rimeIceDefaults}/share/rime-data/default.custom.yaml" "$rime_dir/default.custom.yaml"
        ${pkgs.coreutils}/bin/install -Dm644 \
          "${rimeIceSimplified}/share/rime-data/rime_ice.custom.yaml" "$rime_dir/rime_ice.custom.yaml"
        ${pkgs.librime}/bin/rime_deployer \
          --build "$rime_dir" "${config.i18n.inputMethod.package}/share/rime-data" "$rime_dir/build"
        (
          cd "$rime_dir"
          ${pkgs.librime}/bin/rime_deployer --set-active-schema rime_ice
        )
      '';
    };
  };
}
