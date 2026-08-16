final: prev:
(import ../pkgs { pkgs = final; })
// {
  segger-jlink = prev.segger-jlink.override { headless = true; };
  qq = prev.qq.overrideAttrs (
    _:
    prev.lib.optionalAttrs (prev.stdenv.hostPlatform.system == "x86_64-linux") {
      version = "3.2.32-2026-08-12";
      src = prev.fetchurl {
        urls = [
          "https://qqdl.gtimg.cn/qqfile/QQNT/9.9.33/release/3f89efc5/QQ_3.2.32_260812_amd64_01.deb"
          "https://github.com/Rodert/qq-versions/releases/download/qq-packages-20260813-1d08f1d4/QQ_3.2.32_260812_amd64_01.deb"
        ];
        hash = "sha256-0IXdiTlyJQYeufGUMI9ogSmBjtRFd36XpKChbhPXsOg=";
      };
    }
  );
}
