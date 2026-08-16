{
  description = "Embedded Linux development shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      devShells = nixpkgs.lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              qemu
              dtc
              ubootTools
              gnumake
              pkgsCross.aarch64-multiplatform.buildPackages.gcc
              pkgsCross.riscv64.buildPackages.gcc
            ];
            shellHook = ''
              echo "Embedded Linux shell: $(qemu-system-aarch64 --version | sed -n '1p')"
            '';
          };
        }
      );
    };
}
