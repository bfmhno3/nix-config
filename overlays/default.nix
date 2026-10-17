final: prev:
prev.lib.composeManyExtensions [
  (import ./packages.nix)
  (import ./qq.nix)
  (import ./wechat.nix)
  (import ./segger-jlink.nix)
] final prev
