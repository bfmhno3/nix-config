# nix-config

Personal NixOS and Home Manager configuration with three exported hosts:

- `thinkpad-t14s`: physical AMD laptop running Hyprland. Plasma is disabled. Source: `hosts/thinkpad-t14s`.
- `test-vm`: headless disposable VM for validating the shared system and Home Manager cores. Source: `hosts/examples/test-vm`.
- `wsl2`: personal WSL configuration for the `joe` user. Source: `hosts/wsl2`.

The physical host output is tied to its generated hardware configuration and must not be activated on other hardware. The WSL output is also personal configuration, not a generic anonymous example.

## Architecture

`flake.nix` uses one `mkHost` factory. Its required parameters are `system`, `hostName`, `hostPath`, `username`, `stateVersion`, `gitName`, and `gitEmail`; `extraModules` defaults to an empty list. Explicit `hostPath` values decouple source layout from runtime hostnames and flake output names.

`modules/default.nix` centrally registers every reusable NixOS module, and `home/default.nix` centrally registers every reusable Home Manager module. Host files contain machine-local configuration and select behavior through `mySystem.*` and `myHome.*` options instead of importing reusable features.

The root flake supports `x86_64-linux` and exposes:

- NixOS configurations: `thinkpad-t14s`, `test-vm`, `wsl2`
- Packages: `fcitx5-themes-candlelight`, `google-sans-flex`, `illogical-impulse-microtex`, `illogical-impulse-quickshell`, `grub2-theme`
- A maintenance development shell with `treefmt`, `deadnix`, `nh`, and `statix`
- The nixpkgs integration overlay as `overlays.default`

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

## First use

Clone the repository into the path used by `NH_FLAKE`:

```sh
mkdir -p "$HOME/.config"
git clone https://github.com/bfmhno3/nix-config.git "$HOME/.config/nix-config"
```

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

The standalone templates support `x86_64-linux` and `aarch64-linux`. Stable examples pin the repository release tag:

```sh
nix flake init -t github:bfmhno3/nix-config/v1.0.0#stm32
nix flake init -t github:bfmhno3/nix-config/v1.0.0#rust
nix flake init -t github:bfmhno3/nix-config/v1.0.0#qt6
nix flake init -t github:bfmhno3/nix-config/v1.0.0#embedded-linux
direnv allow
```

Omitting `/v1.0.0` follows the repository default branch instead of a stable release.

## Releases and support

Git tags and `CHANGELOG.md` define project versions. `system.stateVersion` and `home.stateVersion` remain `"26.05"` compatibility state values; they do not change automatically with the `v1.0.0` project release.

Renovate maintains the root lock file and all four template lock files without automerge. If the Renovate GitHub App is unavailable, update and verify each flake explicitly:

```sh
nix flake update
(cd templates/rust && nix flake update)
(cd templates/stm32 && nix flake update)
(cd templates/qt6 && nix flake update)
(cd templates/embedded-linux && nix flake update)
nix flake check --no-write-lock-file --print-build-logs
```

See `THIRD_PARTY.md` for vendored source and license boundaries.