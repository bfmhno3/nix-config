{
  self,
  inputs,
  pkgs,
  formatter,
}:
self.packages.${pkgs.stdenv.hostPlatform.system}
// {
  searxng = pkgs.testers.runNixOSTest {
    name = "searxng";
    nodes.machine = {
      imports = [
        inputs.dae.nixosModules.dae
        ./modules
      ];
      mySystem.network.searxng.enable = true;
    };
    testScript = ''
      machine.wait_for_unit("searx.service")
      machine.wait_for_open_port(8888)
      machine.succeed("test -f /var/lib/searx/searx.env")
      machine.succeed("test \"$(${pkgs.coreutils}/bin/stat -c %a /var/lib/searx/searx.env)\" = 600")
      machine.succeed("${pkgs.gnugrep}/bin/grep -Eq '^SEARXNG_SECRET=[0-9a-f]{64}$' /var/lib/searx/searx.env")
      machine.succeed("test \"$(${pkgs.iproute2}/bin/ss -H -ltn4 'sport = :8888' | ${pkgs.gnugrep}/bin/grep -c '127\\.0\\.0\\.1:8888')\" = 1")
      machine.succeed("test -z \"$(${pkgs.iproute2}/bin/ss -H -ltn6 'sport = :8888')\"")
      machine.succeed("${pkgs.curl}/bin/curl --fail --silent 'http://127.0.0.1:8888/search?q=1%2B1&format=json&engines=calculator' | ${pkgs.jq}/bin/jq -e '.results | type == \"array\"'")
    '';
  };
  test-vm = self.nixosConfigurations.test-vm.config.system.build.toplevel;
  communication-scaling =
    let
      homeConfig = self.nixosConfigurations.thinkpad-t14s.config.home-manager.users.bfmhno3.home;
      getPackage =
        name:
        let
          matches = builtins.filter (package: pkgs.lib.getName package == name) homeConfig.packages;
        in
        assert pkgs.lib.assertMsg (
          builtins.length matches == 1
        ) "ThinkPad Home Manager must contain exactly one ${name} package";
        builtins.head matches;
      qqPackage = getPackage "qq";
      wechatPackage = getPackage "wechat";
    in
    assert pkgs.lib.assertMsg (
      !(homeConfig.sessionVariables ? QT_SCALE_FACTOR)
    ) "ThinkPad Home Manager must not set QT_SCALE_FACTOR globally";
    pkgs.runCommand "communication-scaling-check" { } ''
      test -x ${qqPackage}/bin/qq
      test -x ${wechatPackage}/bin/wechat

      # WeChat 4.1.13 mis-sizes its Wayland window when QT_SCREEN_SCALE_FACTORS
      # is set, so a Wayland session must leave the variable unset and use the
      # compositor scale. On X11 the launcher pins xcb and overrides the
      # DPI-derived scale; QT_SCALE_FACTOR would multiply it and render the UI
      # at 2x the intended size.
      ${pkgs.gnugrep}/bin/grep -F "WAYLAND_DISPLAY" ${wechatPackage}/bin/wechat
      ${pkgs.gnugrep}/bin/grep -F "unset QT_SCREEN_SCALE_FACTORS" ${wechatPackage}/bin/wechat
      ${pkgs.gnugrep}/bin/grep -F "export QT_QPA_PLATFORM=xcb" ${wechatPackage}/bin/wechat
      ${pkgs.gnugrep}/bin/grep -F "export QT_SCREEN_SCALE_FACTORS=2" ${wechatPackage}/bin/wechat
      if ${pkgs.gnugrep}/bin/grep -q "QT_SCALE_FACTOR" ${wechatPackage}/bin/wechat; then
        echo "wechat wrapper must not set QT_SCALE_FACTOR: it multiplies the DPI-derived scale"
        exit 1
      fi
      ${pkgs.gnugrep}/bin/grep -Fx "Exec=wechat %U" ${wechatPackage}/share/applications/wechat.desktop

      # QQ selects the Ozone platform explicitly at launch (its Electron
      # build ignores --ozone-platform-hint=auto), and
      # --force-device-scale-factor only belongs to the X11 branch because
      # on Wayland it multiplies the compositor scale (2x display -> 4x).
      ${pkgs.gnugrep}/bin/grep -F -- "flags=(--ozone-platform=wayland)" ${qqPackage}/bin/qq
      ${pkgs.gnugrep}/bin/grep -F -- "flags=(--ozone-platform=x11 --force-device-scale-factor=2)" ${qqPackage}/bin/qq
      touch $out
    '';
  formatting = pkgs.runCommand "formatting-check" { } ''
    cp -rL ${self} source
    chmod -R u+w source
    cd source
    ${formatter}/bin/treefmt --tree-root . --ci
    touch $out
  '';
}
