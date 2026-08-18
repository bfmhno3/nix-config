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
    illogical-flake = {
      url = "github:soymou/illogical-flake";
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
      formatter.${defaultSystem} = pkgs.nixfmt-tree;
      overlays.default = defaultOverlay;
      packages.${defaultSystem} = import ./pkgs { inherit pkgs; };

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

      checks.${defaultSystem}.test-vm = self.nixosConfigurations.test-vm.config.system.build.toplevel;

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
