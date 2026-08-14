{
  description = "Modular NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      username = "bfmhno3";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      formatter.${system} = pkgs.nixfmt-tree;

      nixosConfigurations.test-vm = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit username; };
        modules = [ ./hosts/test-vm ];
      };

      checks.${system}.test-vm = self.nixosConfigurations.test-vm.config.system.build.toplevel;
    };
}
