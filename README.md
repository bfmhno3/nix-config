# nix-config

NixOS and Home Manager configuration for two exported hosts:

- `thinkpad-t14s`: physical AMD laptop with Plasma 6 and the Illogical Impulse Hyprland desktop.
- `test-vm`: headless disposable VM that validates the shared system and Home Manager cores.

## Architecture

`flake.nix` uses one `mkHost` factory. Its required parameters are `system`, `hostName`, `username`, `stateVersion`, `gitName`, and `gitEmail`; `extraModules` defaults to an empty list. The factory injects these values into the system and Home Manager layers and selects `hosts/<hostname>/default.nix` plus `hosts/<hostname>/home.nix`.

```text
modules/core/       mandatory system behavior
modules/desktop/    reusable desktop services
modules/hardware/   reusable hardware features
modules/network/    network tooling and access
modules/dev/        host-level development integrations
hosts/              machine system and Home Manager compositions
home/core/          shared headless user environment
home/desktop/       desktop environment and host display integration
home/apps/          desktop applications
home/dev/           user development tools
templates/          standalone project development flakes
```

Generated physical-host `hardware-configuration.nix` files are immutable repository inputs. Never edit, format, regenerate, or normalize them.

## Build and test

```sh
nix fmt <changed-hand-written-nix-files>
nix flake check
nix build .#nixosConfigurations.test-vm.config.system.build.vm
./result/bin/run-test-vm-vm
nix build .#nixosConfigurations.thinkpad-t14s.config.system.build.toplevel
```

Activate the physical host only from that machine:

```sh
sudo nixos-rebuild switch --flake .#thinkpad-t14s
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