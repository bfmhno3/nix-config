{
  description = "STM32 development shell";

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
              gcc-arm-embedded
              cmake
              ninja
              openocd
              stlink
              bear
              gdb
            ];
            shellHook = ''
              echo "STM32 shell: $(arm-none-eabi-gcc --version | sed -n '1p')"
            '';
          };
        }
      );
    };
}
