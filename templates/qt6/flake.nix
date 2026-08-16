{
  description = "Qt 6 development shell";

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
              gcc
              gdb
              cmake
              ninja
              pkg-config
              qt6.qtbase
              qt6.qttools
            ];
            shellHook = ''
              echo "Qt shell: Qt $(pkg-config --modversion Qt6Core)"
            '';
          };
        }
      );
    };
}
