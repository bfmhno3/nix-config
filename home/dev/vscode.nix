{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.dev.vscode;
  python = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.json5 ]);
in
{
  options.myHome.dev.vscode.enable = lib.mkEnableOption "Visual Studio Code";
  config = lib.mkIf cfg.enable {
    programs.vscode.enable = true;

    home.activation.configureVSCodeFonts = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      ${python}/bin/python <<'PY'
      import json
      import os
      import stat
      import tempfile
      from pathlib import Path

      import json5

      settings = Path.home() / ".config/Code/User/settings.json"
      settings.parent.mkdir(parents=True, exist_ok=True)
      if settings.exists():
          with settings.open(encoding="utf-8") as source:
              data = json5.load(source)
          if not isinstance(data, dict):
              raise ValueError(f"{settings} must contain a JSON object")
      else:
          data = {}

      expected = {
          "editor.fontFamily": "'Maple Mono NF CN', monospace",
          "editor.fontLigatures": True,
          "terminal.integrated.fontFamily": "'Maple Mono NF CN', monospace",
          "terminal.integrated.fontLigatures.enabled": True,
      }
      data.update(expected)

      descriptor, temporary_name = tempfile.mkstemp(
          prefix="settings.json.", dir=settings.parent
      )
      temporary = Path(temporary_name)
      try:
          with os.fdopen(descriptor, "w", encoding="utf-8") as destination:
              json.dump(data, destination, ensure_ascii=False, indent=4)
              destination.write("\n")
              destination.flush()
              os.fsync(destination.fileno())
          if settings.exists():
              temporary.chmod(stat.S_IMODE(settings.stat().st_mode))
          temporary.replace(settings)
      finally:
          temporary.unlink(missing_ok=True)

      with settings.open(encoding="utf-8") as source:
          written = json.load(source)
      if any(written.get(key) != value for key, value in expected.items()):
          raise ValueError(f"Failed to configure VS Code fonts in {settings}")
      PY
    '';
  };
}
