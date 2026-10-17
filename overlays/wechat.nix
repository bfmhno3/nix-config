_final: prev: {
  # nixos-26.05 still packages WeChat 4.1.1.4; the upstream AppImage is a rolling
  # URL, so pin the current build through an archive snapshot until nixpkgs
  # catches up.
  wechat =
    if prev.stdenv.hostPlatform.system == "x86_64-linux" then
      let
        version = "4.1.13";
        src = prev.fetchurl {
          url = "https://web.archive.org/web/20261016045027if_/https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
          hash = "sha256-RSYYC8qYASh5FZmvEi/0eVACpXFaUQ9qZUgOK+aHQkQ=";
        };
        appimageContents = prev.appimageTools.extract {
          pname = "wechat";
          inherit version src;
          postExtract = ''
            patchelf --replace-needed libtiff.so.5 libtiff.so $out/opt/wechat/wechat
          '';
        };
      in
      prev.appimageTools.wrapAppImage {
        pname = "wechat";
        inherit version;
        src = appimageContents;
        extraInstallCommands = ''
          mkdir -p $out/share/applications
          cp ${appimageContents}/wechat.desktop $out/share/applications/
          mkdir -p $out/share/icons/hicolor/256x256/apps
          cp ${appimageContents}/wechat.png $out/share/icons/hicolor/256x256/apps/

          substituteInPlace $out/share/applications/wechat.desktop --replace-fail AppRun wechat
        '';
        meta = prev.wechat.meta;
      }
    else
      prev.wechat;
}
