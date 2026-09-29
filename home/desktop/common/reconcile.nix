{
  config,
  lib,
  pkgs,
}:
{
  name,
  scope,
  component,
  enabled,
  source,
  seed ? null,
  identity,
}:
let
  setup = ''
    set -eu

    state_home="''${XDG_STATE_HOME:-$HOME/.local/state}"
    state_dir="$state_home/nix-config/${scope}"
    manifest="$state_dir/${component}.manifest"
    new_manifest="$state_dir/${component}.manifest.new"
    ${pkgs.coreutils}/bin/mkdir -p "$state_dir"
  '';
  createManifest =
    if enabled then
      ''
        {
          printf '# %s\n' '${identity}'
          cd ${source}
          ${pkgs.findutils}/bin/find . \( -type f -o -type l \) -printf '%P\n' | ${pkgs.coreutils}/bin/sort
        } > "$new_manifest"
      ''
    else
      ''
        : > "$new_manifest"
      '';
  installFiles =
    if enabled then
      ''
        ${pkgs.rsync}/bin/rsync -a --chmod=Du+w,Fu+w ${source}/ "$HOME/"
        ${pkgs.coreutils}/bin/mv "$new_manifest" "$manifest"
      ''
      + lib.optionalString (seed != null) ''
        ${pkgs.rsync}/bin/rsync -a --ignore-existing --chmod=Du+w,Fu+w ${seed}/ "$HOME/"
      ''
    else
      ''
        ${pkgs.coreutils}/bin/rm -f "$new_manifest" "$manifest"
      '';
in
{
  # Every prune runs before any install, so switching desktops cannot delete a file another component just wrote.
  "${name}Prune" = config.lib.dag.entryBetween [ "writeBoundary" ] [ "checkLinkTargets" ] ''
    ${setup}
    ${createManifest}

    if [ -e "$manifest" ]; then
      while IFS= read -r path; do
        case "$path" in
          \#*|"") continue ;;
        esac
        if ! ${pkgs.gnugrep}/bin/grep -Fxq -- "$path" "$new_manifest"; then
          ${pkgs.coreutils}/bin/rm -f "$HOME/$path"
        fi
      done < "$manifest"
    fi
  '';
  ${name} = config.lib.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
    ${setup}
    ${installFiles}
  '';
}
