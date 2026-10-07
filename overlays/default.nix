final: prev:
(import ../pkgs { pkgs = final; })
// {
  segger-jlink = prev.segger-jlink.override { headless = true; };
  qq = prev.qq.overrideAttrs (
    _:
    prev.lib.optionalAttrs (prev.stdenv.hostPlatform.system == "x86_64-linux") {
      version = "3.2.34-2026-09-24";
      src = prev.fetchurl {
        # The release-channel URL of this very file
        # (…/QQNTV2/9.9.36/release/9ee04bef/QQ_3.2.34_260924_amd64_01.deb) answers
        # 403 without Tencent's URL-signing API (see pkgs/by-name/qq/qq/update.sh),
        # so pin the beta-channel path, which serves the identical deb (verified
        # sha256) without signing.
        urls = [
          "https://qqdl.gtimg.cn/qqfile/QQNT/9.9.36/beta/9ee04bef/linuxqq_3.2.34-53644_amd64.deb"
        ];
        hash = "sha256-Q2xl4d0oQi4SiiHL3bX+Ti5sB51/J/7CVB4BTTjMM24=";
      };
    }
  );
}
