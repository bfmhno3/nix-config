{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.dev.codexDesktop;
  codexDesktop = inputs.codex-desktop-linux.packages.${pkgs.stdenv.hostPlatform.system}.codex-desktop;
in
{
  options.mySystem.dev.codexDesktop.enable =
    lib.mkEnableOption "the nix-ld libraries for Codex Desktop cached runtimes";

  # Codex sources a snapshot of the login shell before every sandboxed command,
  # which re-exports NIX_LD_LIBRARY_PATH and overrides the packaged Bubblewrap
  # adapter. The workspace and document runtimes it caches in ~/.cache/codex-runtimes
  # then resolve through the system nix-ld path instead, so its libraries have to
  # be published there too.
  config = lib.mkIf (cfg.enable && config.programs.nix-ld.enable) {
    programs.nix-ld.libraries = codexDesktop.passthru.workspaceRuntimeLibraries;
  };
}
