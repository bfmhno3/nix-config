{
  description = "Modular NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    helix.url = "github:helix-editor/helix/master";
    oh-my-tmux = {
      url = "github:gpakosz/.tmux";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    omp.url = "github:can1357/oh-my-pi";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      defaultSystem = "x86_64-linux";
      defaultOverlay = import ./overlays;
      pkgs = import nixpkgs {
        system = defaultSystem;
        overlays = [ defaultOverlay ];
      };
      formatter = pkgs.nixfmt-tree.override {
        settings.formatter.nixfmt.excludes = [ "hosts/*/hardware-configuration.nix" ];
      };
      mkHost =
        {
          system,
          hostName,
          hostPath,
          username,
          stateVersion,
          gitName,
          gitEmail,
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              hostName
              username
              stateVersion
              ;
          };
          modules = [
            {
              nixpkgs = {
                hostPlatform = system;
                overlays = [ defaultOverlay ];
              };
            }
            ./modules
            hostPath
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                sharedModules = [ ./home ];
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit
                    inputs
                    username
                    stateVersion
                    gitName
                    gitEmail
                    ;
                };
                users.${username} = import (hostPath + "/home.nix");
              };
            }
          ]
          ++ extraModules;
        };
      commonHostArgs = {
        system = defaultSystem;
        username = "bfmhno3";
        stateVersion = "26.05";
        gitName = "bfmhno3";
        gitEmail = "858446559@qq.com";
      };
    in
    {
      formatter.${defaultSystem} = formatter;
      overlays.default = defaultOverlay;
      packages.${defaultSystem} = nixpkgs.lib.getAttrs [
        "fcitx5-theme-ori"
        "fcitx5-themes-candlelight"
        "google-sans-flex"
        "illogical-impulse-microtex"
        "illogical-impulse-quickshell"
        "grub2-theme"
      ] pkgs;

      devShells.${defaultSystem}.default = pkgs.mkShellNoCC {
        packages = [
          formatter
          pkgs.deadnix
          pkgs.nh
          pkgs.statix
        ];
      };

      nixosConfigurations = {
        thinkpad-t14s = mkHost (
          commonHostArgs
          // {
            hostName = "thinkpad-t14s";
            hostPath = ./hosts/thinkpad-t14s;
          }
        );
        test-vm = mkHost (
          commonHostArgs
          // {
            hostName = "test-vm";
            hostPath = ./hosts/examples/test-vm;
          }
        );
        wsl2 = mkHost (
          commonHostArgs
          // {
            username = "joe";
            hostName = "wsl2";
            hostPath = ./hosts/wsl2;
            extraModules = [ inputs.nixos-wsl.nixosModules.default ];
          }
        );
      };

      checks.${defaultSystem} = self.packages.${defaultSystem} // {
        searxng = pkgs.testers.runNixOSTest {
          name = "searxng";
          nodes.machine = {
            imports = [ ./modules ];
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
        wechat-scaling =
          let
            homeConfig = self.nixosConfigurations.thinkpad-t14s.config.home-manager.users.bfmhno3.home;
            wechatPackages = builtins.filter (
              package: nixpkgs.lib.getName package == "wechat"
            ) homeConfig.packages;
            wechatPackage =
              assert nixpkgs.lib.assertMsg (
                builtins.length wechatPackages == 1
              ) "ThinkPad Home Manager must contain exactly one WeChat package";
              builtins.head wechatPackages;
          in
          assert nixpkgs.lib.assertMsg (
            !(homeConfig.sessionVariables ? QT_SCALE_FACTOR)
          ) "ThinkPad Home Manager must not set QT_SCALE_FACTOR globally";
          pkgs.runCommand "wechat-scaling-check" { } ''
            test -x ${wechatPackage}/bin/wechat
            ${pkgs.gnugrep}/bin/grep -Fx "export QT_SCALE_FACTOR='2'" ${wechatPackage}/bin/wechat
            ${pkgs.gnugrep}/bin/grep -Fx "Exec=wechat %U" ${wechatPackage}/share/applications/wechat.desktop
            touch $out
          '';
        formatting = pkgs.runCommand "formatting-check" { } ''
          cp -rL ${self} source
          chmod -R u+w source
          cd source
          ${formatter}/bin/treefmt --tree-root . --ci
          touch $out
        '';
      };

      templates = {
        stm32 = {
          path = ./templates/stm32;
          description = "STM32 development shell";
        };
        rust = {
          path = ./templates/rust;
          description = "Rust development shell";
        };
        qt6 = {
          path = ./templates/qt6;
          description = "Qt 6 development shell";
        };
        embedded-linux = {
          path = ./templates/embedded-linux;
          description = "Embedded Linux development shell";
        };
      };
    };
}
