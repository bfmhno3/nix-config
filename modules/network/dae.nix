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
      lan_interface: br-lan
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
      bootstrap_resolver: '223.5.5.5:53'
      bandwidth_max_tx: '200 mbps'
      bandwidth_max_rx: '1 gbps'
      fallback_resolver: '223.5.5.5:53'
    }

    # Nix manages this configuration; daed runs its bundled dae daemon.
    # Add private subscriptions through daed or a separate root-managed file.
    subscription {
      # my_sub: 'https-file://your-subscription.example/sub'
    }

    node {
      # socks5: 'socks5://user:password@host:port'
      # http: 'http://user:password@host:port'
      # ss: 'ss://...'
      # vmess: 'vmess://...'
      # vless: 'vless://...'
      # trojan: 'trojan://...'
      # tuic: 'tuic://...'
      # hysteria2: 'hysteria2://...'
    }

    dns {
      # True dual-stack: 0 keeps both A and AAAA DNS answers.
      ipversion_prefer: 0
      upstream {
        cn_dot: 'tls://dns.alidns.com:853'
        cn_doh: 'https://doh.pub/dns-query'
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
          ip(geoip:private) && !qname(geosite:cn) -> overseas_cloudflare
          fallback: accept
        }
      }
    }

    group {
      # 默认自动选择：过滤套餐信息、公告等非节点条目
      proxy {
        filter: !name(regex: '(?i)(到期|过期|剩余|流量|套餐|重置|订阅|官网|公告|Traffic|Expire|Remaining)')
        policy: min_moving_avg
        check_interval: 180s
      }

      hk {
        filter: name(regex: '(?i)(🇭🇰|香港|Hong.?Kong|(^|[^A-Za-z])HKG?([^A-Za-z]|$))')
        policy: min_moving_avg
        check_interval: 120s
      }

      tw {
        filter: name(regex: '(?i)(🇹🇼|台湾|台灣|台北|臺北|高雄|Taiwan|Taipei|(^|[^A-Za-z])(TW|TPE|KHH)([^A-Za-z]|$))')
        policy: min_moving_avg
        check_interval: 120s
      }

      jp {
        filter: name(regex: '(?i)(🇯🇵|日本|东京|東京|大阪|Japan|Tokyo|Osaka|(^|[^A-Za-z])(JP|NRT|HND|KIX)([^A-Za-z]|$))')
        policy: min_moving_avg
        check_interval: 120s
      }

      sg {
        filter: name(regex: '(?i)(🇸🇬|新加坡|狮城|獅城|Singapore|(^|[^A-Za-z])(SG|SIN)([^A-Za-z]|$))')
        policy: min_moving_avg
        check_interval: 120s
      }

      us {
        filter: name(regex: '(?i)(🇺🇸|美国|美國|United.?States|USA|Los.?Angeles|San.?Jose|Seattle|New.?York|Dallas|(^|[^A-Za-z])(US|LAX|SFO|SJC|SEA|JFK|DFW)([^A-Za-z]|$))')
        policy: min_moving_avg
        check_interval: 120s
      }

      kr {
        filter: name(regex: '(?i)(🇰🇷|韩国|韓國|首尔|首爾|South.?Korea|Korea|Seoul|(^|[^A-Za-z])(KR|ICN|GMP)([^A-Za-z]|$))')
        policy: min_moving_avg
        check_interval: 120s
      }

      uk {
        filter: name(regex: '(?i)(🇬🇧|英国|英國|伦敦|倫敦|United.?Kingdom|Great.?Britain|London|(^|[^A-Za-z])(UK|GB|LHR|LON|MAN)([^A-Za-z]|$))')
        policy: min_moving_avg
        check_interval: 120s
      }

      de {
        filter: name(regex: '(?i)(🇩🇪|德国|德國|法兰克福|法蘭克福|Germany|Frankfurt|(^|[^A-Za-z])(DE|FRA)([^A-Za-z]|$))')
        policy: min_moving_avg
        check_interval: 120s
      }

      download {
        filter: name(regex: '(?i)(0[.]0[1-9]|0[.]1)')
        policy: min_moving_avg
        check_interval: 600s
      }
    }

    routing {
      pname(NetworkManager) -> direct

      dip(224.0.0.0/3, 'ff00::/8') -> direct
      dip('fe80::/10', 'fc00::/7') -> direct
      dip(geoip:private) -> direct

      domain(geosite:category-ads-all) -> block

      # AI 服务统一使用美国节点
      domain(geosite:openai) -> us
      domain(geosite:google-gemini) -> us
      domain(suffix: anthropic.com, claude.ai) -> us
      domain(geosite:category-ai-!cn) -> us

      # 有地区限制的流媒体
      domain(geosite:bahamut) -> tw
      domain(suffix: bilibili.tv, biliintl.com) -> tw
      domain(geosite:youtube) -> us
      domain(geosite:netflix, geosite:disney, geosite:hbo, geosite:primevideo, geosite:spotify) -> us

      # 不强制地区，由延迟策略自动选择
      domain(geosite:github) -> proxy
      domain(geosite:category-social-media-!cn, geosite:category-communication) -> proxy
      domain(geosite:steam, geosite:category-games) -> proxy

      domain(geosite:category-game-platforms-download, geosite:category-public-tracker) -> download

      domain(geosite:cn) -> direct
      dip(geoip:cn) -> direct

      # 禁用 QUIC，使常见 HTTPS 流量回落 TCP
      l4proto(udp) && dport(443) -> block

      fallback: proxy
    }
  '';
in
{
  options.mySystem.network.dae.enable = lib.mkEnableOption "dae transparent proxy and daed dashboard";

  config = lib.mkIf cfg.enable {
    services.dae = {
      enable = true;
      package = inputs.dae.packages.${pkgs.system}.dae-unstable;
      configFile = "/etc/dae/config.dae";
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

    environment.etc."dae/config.dae" = {
      source = daeConfig;
      mode = "0400";
    };
  };
}
