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
    let
      devShellsBySystem = nixpkgs.lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.mkShell {
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
        }
      );
    in
    {
      devShells = nixpkgs.lib.mapAttrs (_: devShell: { default = devShell; }) devShellsBySystem;
      checks = nixpkgs.lib.mapAttrs (_: devShell: { dev-shell = devShell; }) devShellsBySystem;
    };

}
