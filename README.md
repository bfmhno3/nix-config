# nix-config

NixOS and Home Manager configuration for one physical host and one exported example:

- `thinkpad-t14s`: physical AMD laptop with Plasma 6 and the Illogical Impulse Hyprland desktop, sourced from `hosts/thinkpad-t14s`.
- `test-vm`: headless disposable VM that validates the shared system and Home Manager cores, sourced from `hosts/examples/test-vm`.

## Architecture

`flake.nix` uses one `mkHost` factory. Its required parameters are `system`, `hostName`, `hostPath`, `username`, `stateVersion`, `gitName`, and `gitEmail`; `extraModules` defaults to an empty list. Explicit `hostPath` values decouple source layout from runtime hostnames and flake output names.

`modules/default.nix` centrally registers every reusable NixOS module, and `home/default.nix` centrally registers every reusable Home Manager module. Host files contain machine-local configuration and select behavior through `mySystem.*` and `myHome.*` options instead of importing reusable features.

The flake exposes repository packages at `packages.<system>` and the nixpkgs integration layer at `overlays.default`. Every host uses that overlay through its global package set, which Home Manager shares.

```text
modules/default.nix       explicit NixOS option registry
modules/core/             selectable shared system core
modules/desktop/          reusable desktop services
modules/hardware/         reusable hardware features
modules/network/          network tooling and access
modules/dev/              host-level development integrations
hosts/<hostname>/         physical machine configuration and assets
hosts/examples/           exported nonphysical reference configurations
home/default.nix          explicit Home Manager option registry
home/core/                selectable headless user environment
home/desktop/             desktop environment and display integration
home/apps/                desktop applications
home/dev/                 user development tools
pkgs/                     repository-owned package recipes
overlays/                 nixpkgs package integration and modifications
templates/                standalone project development flakes
```

Generated physical-host `hardware-configuration.nix` files are immutable repository inputs. Never edit, format, regenerate, or normalize them.

## Build and test

```sh
nix fmt <changed-hand-written-nix-files>
nix flake check
nix build .#nixosConfigurations.test-vm.config.system.build.vm
./result/bin/run-test-vm-vm
nh os build .#thinkpad-t14s
```

Activate the physical host only from that machine:

```sh
nh os switch .#thinkpad-t14s
```

## Project templates

```sh
nix flake init -t github:bfmhno3/nix-config#stm32
direnv allow

nix flake init -t github:bfmhno3/nix-config#rust
direnv allow

nix flake init -t github:bfmhno3/nix-config#qt6
direnv allow

nix flake init -t github:bfmhno3/nix-config#embedded-linux
direnv allow
```