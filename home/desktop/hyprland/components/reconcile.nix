{
  config,
  lib,
  pkgs,
}:
{
  component,
  enabled,
  source,
  identity,
}:
let
  createManifest = lib.optionalString enabled ''
    {
      printf '# %s\n' '${identity}'
      cd ${source}
      ${pkgs.findutils}/bin/find . \( -type f -o -type l \) -printf '%P\n' | ${pkgs.coreutils}/bin/sort
    } > "$new_manifest"
  '';
  createEmptyManifest = lib.optionalString (!enabled) ''
    : > "$new_manifest"
  '';
  installFiles = lib.optionalString enabled ''
    ${pkgs.rsync}/bin/rsync -a --chmod=Du+w,Fu+w ${source}/ "$HOME/"
    ${pkgs.coreutils}/bin/mv "$new_manifest" "$manifest"
  '';
  removeManifest = lib.optionalString (!enabled) ''
    ${pkgs.coreutils}/bin/rm -f "$new_manifest" "$manifest"
  '';
in
config.lib.dag.entryAfter [ "writeBoundary" ] ''
  set -eu

  state_home="''${XDG_STATE_HOME:-$HOME/.local/state}"
  state_dir="$state_home/nix-config/hyprland-theme"
  manifest="$state_dir/${component}.manifest"
  new_manifest="$state_dir/${component}.manifest.new"
  ${pkgs.coreutils}/bin/mkdir -p "$state_dir"

  ${createManifest}
  ${createEmptyManifest}

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

  ${installFiles}
  ${removeManifest}
''
