{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.network.searxng;
in
{
  options.mySystem.network.searxng.enable = lib.mkEnableOption "local SearXNG search service";

  config = lib.mkIf cfg.enable {
    services.searx = {
      enable = true;
      configureUwsgi = false;
      configureNginx = false;
      openFirewall = false;
      environmentFile = "/var/lib/searx/searx.env";
      settings = {
        use_default_settings = true;
        server = {
          bind_address = "127.0.0.1";
          port = 8888;
          secret_key = "$SEARXNG_SECRET";
        };
        search.formats = [
          "html"
          "json"
        ];
      };
    };

    systemd.services = {
      searx-secret = {
        description = "Generate the local SearXNG secret";
        serviceConfig = {
          Type = "oneshot";
          User = "searx";
          Group = "searx";
          StateDirectory = "searx";
          StateDirectoryMode = "0700";
          UMask = "0077";
          RemainAfterExit = true;
        };
        script = ''
          if ! test -s /var/lib/searx/searx.env; then
            temporary="$(${pkgs.coreutils}/bin/mktemp /var/lib/searx/searx.env.XXXXXX)"
            printf 'SEARXNG_SECRET=%s\n' "$(${pkgs.openssl}/bin/openssl rand -hex 32)" > "$temporary"
            ${pkgs.coreutils}/bin/mv "$temporary" /var/lib/searx/searx.env
          fi
        '';
      };

      searx-init = {
        requires = [ "searx-secret.service" ];
        after = [ "searx-secret.service" ];
      };
    };
  };
}
