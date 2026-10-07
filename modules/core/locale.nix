{ config, lib, ... }:
let
  cfg = config.mySystem.core.locale;
in
{
  options.mySystem.core.locale = {
    enable = lib.mkEnableOption "locale configuration";
    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "Asia/Shanghai";
    };
    defaultLocale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
    };
    extraLocale = lib.mkOption {
      type = lib.types.str;
      default = "zh_CN.UTF-8";
    };
  };

  config = lib.mkIf cfg.enable {
    time.timeZone = cfg.timeZone;
    i18n = {
      defaultLocale = cfg.defaultLocale;
      extraLocaleSettings = {
        LC_ADDRESS = cfg.extraLocale;
        LC_IDENTIFICATION = cfg.extraLocale;
        LC_MEASUREMENT = cfg.extraLocale;
        LC_MONETARY = cfg.extraLocale;
        LC_NAME = cfg.extraLocale;
        LC_NUMERIC = cfg.extraLocale;
        LC_PAPER = cfg.extraLocale;
        LC_TELEPHONE = cfg.extraLocale;
        LC_TIME = cfg.extraLocale;
      };
    };
  };
}
