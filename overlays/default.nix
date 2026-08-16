final: prev:
(import ../pkgs { pkgs = final; })
// {
  segger-jlink = prev.segger-jlink.override { headless = true; };
}
