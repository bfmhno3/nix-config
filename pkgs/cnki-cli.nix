{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "cnki-cli";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "azazo1";
    repo = "cnki-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FJn/tEn4MVnVQd4QQb5YLogoVyLZlCfV211A+t9p0ok=";
  };

  subPackages = [ "cmd/cnki" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/azazo1/cnki-cli/internal/buildinfo.version=v${finalAttrs.version}"
  ];

  vendorHash = "sha256-jLccsZpZOuaO9o9iyFx2tiHkT0w1IYMi9Cml4j7K6HQ=";

  meta = {
    description = "Command-line client for searching and exporting CNKI literature";
    homepage = "https://github.com/azazo1/cnki-cli";
    license = lib.licenses.mit;
    mainProgram = "cnki";
    platforms = lib.platforms.unix;
  };
})
