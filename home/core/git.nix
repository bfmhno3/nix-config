{ config, lib, ... }:
let
  cfg = config.myHome.core.git;
in
{
  options.myHome.core.git = {
    enable = lib.mkEnableOption "Git configuration";
    name = lib.mkOption {
      type = lib.types.str;
    };
    email = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings.user = {
        inherit (cfg) name email;
      };
    };
  };
}
