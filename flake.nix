{
  description = "Modular NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    helix = {
      url = "github:helix-editor/helix/master";
      # Following nixpkgs-unstable fails: glibc 2.44 defines bsearch as a C23
      # generic macro, which collides with the tree-sitter-perl grammar's own
      # bsearch() definition.
      # inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
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
    dae = {
      url = "github:daeuniverse/flake.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    omp = {
      url = "github:can1357/oh-my-pi?ref=v18.12.5";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nyxuri = {
      url = "github:ech678/Nyxuri/v3.1.0";
      flake = false;
    };
    codex-desktop-linux = {
      url = "github:ilysenko/codex-desktop-linux";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    claude-desktop = {
      url = "github:nmcbride/claude-desktop-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ...
    }:
    let
      defaultSystem = "x86_64-linux";
      defaultOverlay = import ./overlays;
      unstableOverlay = import ./overlays/unstable.nix { inherit nixpkgs-unstable; };
      overlays = [
        defaultOverlay
        unstableOverlay
      ];
      pkgs = import nixpkgs {
        system = defaultSystem;
        inherit overlays;
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
          specialArgs = { inherit inputs; };
          modules = [
            {
              nixpkgs = {
                hostPlatform = system;
                inherit overlays;
              };
              mySystem.core.base = {
                enable = true;
                inherit hostName username stateVersion;
              };
            }
            inputs.dae.nixosModules.dae
            ./modules
            hostPath
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                sharedModules = [ ./home ];
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users.${username} = {
                  imports = [ (hostPath + "/home.nix") ];
                  myHome.core = {
                    user = {
                      enable = true;
                      inherit username stateVersion;
                    };
                    git = {
                      name = gitName;
                      email = gitEmail;
                    };
                  };
                };
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
      packages.${defaultSystem} = import ./pkgs { inherit pkgs; };

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

      checks.${defaultSystem} = import ./checks.nix {
        inherit
          self
          inputs
          pkgs
          formatter
          ;
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
