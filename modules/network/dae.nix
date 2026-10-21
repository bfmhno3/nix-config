{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.network.dae;
  daeConfig = pkgs.writeText "config.dae" ''
    global {
      tproxy_port: 12345
      tproxy_port_protect: true
      pprof_port: 0
      bpf_conn_state_map_size: 262144
      so_mark_from_dae: 0
      log_level: info
      disable_waiting_network: false
      disable_thp: true
      # No lan_interface: this host is a client, not a router.
      wan_interface: auto
      auto_config_kernel_parameter: true
      tcp_check_url: 'http://cp.cloudflare.com,1.1.1.1,2606:4700:4700::1111'
      tcp_check_http_method: HEAD
      udp_check_dns: 'dns.google:53,8.8.8.8,2001:4860:4860::8888'
      check_interval: 30s
      check_tolerance: 50ms
      dial_mode: ip
      allow_insecure: false
      sniffing_timeout: 30ms
      tls_implementation: tls
      # tls_implementation: utls
      utls_imitate: chrome_auto
      tls_fragment: false
      tls_fragment_length: '50-100'
      tls_fragment_interval: '10-20'
      mptcp: false
      # Bootstrap and fallback resolvers run before DNS routing is ready, so
      # they stay plaintext. Normal lookups use the encrypted upstreams below.
      bootstrap_resolver: '223.5.5.5:53'
      bandwidth_max_tx: '200 mbps'
      bandwidth_max_rx: '1 gbps'
      fallback_resolver: '223.5.5.5:53'
    }

    # Airport subscriptions are intentionally absent: their IP ranges are
    # dirty. Keep them on the router and use them only for manual uploads and
    # downloads while connected to the router network.
    node {
      # Full node URIs come from secrets/dae.yaml. Node names stay here
      # because group filters and routing reference them.
      air_reality_443: '${config.sops.placeholder.air_reality_443_uri}'
      air_direct_2053: '${config.sops.placeholder.air_direct_2053_uri}'
      air_hy2_8443: '${config.sops.placeholder.air_hy2_8443_uri}'
    }

    dns {
      # Keep both A and AAAA answers.
      ipversion_prefer: 0

      # Security over latency: never serve stale cache entries.
      optimistic_cache: false

      # All normal upstreams use DoT or DoH.
      upstream {
        cn_dot: 'tls://dns.alidns.com:853'
        overseas_google: 'https://dns.google/dns-query'
        overseas_cloudflare: 'https://cloudflare-dns.com/dns-query'
      }
      routing {
        request {
          qname(geosite:category-ads-all) -> reject
          qname(geosite:cn) -> cn_dot
          fallback: overseas_google
        }
        response {
          upstream(overseas_google) -> accept
          # Re-check answers that point at private addresses, except for CN
          # domains.
          ip(geoip:private) && !qname(geosite:cn) -> overseas_cloudflare
          fallback: accept
        }
      }
    }

    group {
      # Own nodes only. REALITY and Hysteria2 exit through the residential IP;
      # the direct VPS node is penalized so it only wins when that path fails.
      air {
        filter: name(air_reality_443, air_hy2_8443)
        filter: name(air_direct_2053) [add_latency: 800ms]
        policy: min_moving_avg
        check_interval: 30s
        tcp_check_url: 'http://cp.cloudflare.com,1.1.1.1'
        udp_check_dns: 'dns.google:53,8.8.8.8'
      }
    }

    routing {
      # Keep the VPS addresses direct so dae does not proxy its own transport
      # and SSH to these hosts stays usable.
      dip(52.253.112.206) -> direct
      dip(35.212.255.156) -> direct

      pname(NetworkManager) -> direct

      dip(224.0.0.0/3, 'ff00::/8') -> direct
      dip('fe80::/10', 'fc00::/7') -> direct
      dip(geoip:private) -> direct

      domain(geosite:category-ads-all) -> block

      # Only CN domains are direct. IP-only CN destinations also go through
      # the own nodes on purpose; this host does not split by CN IP ranges.
      domain(geosite:cn) -> direct

      # Disable QUIC so common HTTPS traffic falls back to TCP.
      l4proto(udp) && dport(443) -> block

      fallback: air
    }
  '';
in
{
  options.mySystem.network.dae = {
    enable = lib.mkEnableOption "dae transparent proxy and daed dashboard";
    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Start dae at boot; when false, start it manually with systemctl.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = ../../secrets/dae.yaml;
      secrets = {
        air_reality_443_uri = { };
        air_direct_2053_uri = { };
        air_hy2_8443_uri = { };
      };
      templates."dae-config.dae" = {
        file = daeConfig;
        restartUnits = [ "dae.service" ];
      };
    };

    services.dae = {
      enable = true;
      package = inputs.dae.packages.${pkgs.stdenv.hostPlatform.system}.dae-unstable;
      configFile = config.sops.templates."dae-config.dae".path;
      assets = with pkgs; [
        v2ray-geoip
        v2ray-domain-list-community
      ];
      openFirewall = {
        enable = false;
        port = 12345;
      };

      # disableTxChecksumIpGeneric = true;
    };

    systemd.services.dae.wantedBy = lib.mkIf (!cfg.autoStart) (lib.mkForce [ ]);
  };
}
