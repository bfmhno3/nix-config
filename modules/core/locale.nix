{ config, lib, ... }:
let
  cfg = config.mySystem.core.locale;
in
{
  options.mySystem.core.locale.enable = lib.mkEnableOption "locale configuration";

  config = lib.mkIf cfg.enable {
    time.timeZone = "Asia/Shanghai";
    i18n = {
      defaultLocale = lib.mkDefault "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "zh_CN.UTF-8";
        LC_IDENTIFICATION = "zh_CN.UTF-8";
        LC_MEASUREMENT = "zh_CN.UTF-8";
        LC_MONETARY = "zh_CN.UTF-8";
        LC_NAME = "zh_CN.UTF-8";
        LC_NUMERIC = "zh_CN.UTF-8";
        LC_PAPER = "zh_CN.UTF-8";
        LC_TELEPHONE = "zh_CN.UTF-8";
        LC_TIME = "zh_CN.UTF-8";
      };
    };
  };
}
