{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.dev.omp;
  upstream = inputs.omp.packages.${pkgs.stdenv.hostPlatform.system}.default;
  # omp resolves eval, LSP, and DAP binaries from PATH. Each entry below is
  # user-scoped for that reason; moving one to system packages is safe as long
  # as its binary name stays available on PATH.
  # Language toolchains (cargo, rustc, gcc, cmake) stay in the project dev
  # shells; rust-analyzer and clangd use whatever toolchain the launching shell
  # provides.
  # gh, git, bun, ast-grep, ripgrep, and jq come from home/core or
  # home/dev/tools.nix and are intentionally not duplicated here.
  python = pkgs.python3.withPackages (
    ps: with ps; [
      debugpy # Python DAP adapter (`python -m debugpy.adapter`)
      matplotlib # Figure rendering in eval output
      numpy # Array operations; dependency of pandas and matplotlib
      pandas # DataFrame and Series table views
      pillow # PIL.Image rendering in eval output
      polars # DataFrame and Series table views
    ]
  );
  lsp = with pkgs; [
    bash-language-server # Shell LSP
    clang-tools # clangd for C/C++ and clang-format; uses project compile flags
    nixd # Nix LSP
    pyright # Python type checker LSP
    ruff # Python linter and formatter LSP
    rust-analyzer # Rust LSP; uses cargo/rustc from the launching dev shell
    shellcheck # Shell diagnostics consumed by bash-language-server
    typescript-language-server # JavaScript and TypeScript LSP
    vscode-langservers-extracted # JSON, CSS, HTML, and ESLint LSPs
    yaml-language-server # YAML LSP
  ];
  debug = with pkgs; [
    gdb # GDB DAP adapter for C, C++, and Rust; also provided by myHome.dev.gdb
    lldb # LLDB and lldb-dap for C, C++, and Rust
  ];
  gated = pkgs.writeShellScriptBin "omp" ''
    if [ -t 0 ]; then
      read -r -p "Is your egress IP clean? [y/N] " answer
      case "''${answer,,}" in
        y | yes) ;;
        *)
          echo "omp: launch cancelled."
          exit 1
          ;;
      esac
    fi
    exec ${upstream}/bin/omp "$@"
  '';
in
{
  imports = [ inputs.omp.homeManagerModules.default ];

  options.myHome.dev.omp.enable = lib.mkEnableOption "Oh My Pi coding agent";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.chromium # Browser tool (Puppeteer executable)
      python # Python eval, debugpy, and rich output
    ]
    ++ lsp
    ++ debug;
    programs.omp = {
      enable = true;
      package = gated;
    };
  };
}
