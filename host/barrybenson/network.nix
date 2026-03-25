{ lib, config, pkgs, ... }:

let
  eth_intf = "enp1s0";
  wg_intf = "wg_vps";
  wg_mark = 51820;
  wg_table = 1000;
in
{
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    wait-online.enable = true;
    networks."10-${eth_intf}" = {
      matchConfig.Name = "${eth_intf}";
      DHCP = "ipv4";
      linkConfig.RequiredForOnline = "routable";
      dns = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];
    };
  };

  # Need network-online for podman-user-wait-network-online.service
  systemd.targets.network-online.wantedBy = [ "multi-user.target" ];

  # firewall
  networking.firewall.enable = false; # use our own fw
  networking.nftables = {
    enable = true;
    checkRuleset = true;
    #flushRuleset = true; # do not flush, or podman's fw get flushed
    tables = {
      global = {
        family = "inet";
        content = ''
          set WG_SUBNETS { # trusted ips
              type ipv4_addr
              flags interval;
              elements = { 10.0.0.0/24, 10.0.10.0/24 }
          }
          chain wg_input {
            tcp dport { 8080, 8443 } accept
          }
          chain input {
            type filter hook input priority 0; policy drop;
            ct state { established, related } accept
            iif "lo" accept
            ip protocol icmp limit rate 10/second accept
            ip6 nexthdr icmpv6 limit rate 10/second accept
            tcp dport 22 accept # ssh
            iifname "${wg_intf}" ip saddr @WG_SUBNETS jump wg_input
          }
          chain forward {
            type filter hook forward priority 0; policy drop;
          }
          chain output {
            type filter hook output priority 0; policy accept;
          }
        '';
      };
      internal_redirect = {
        family = "inet";
        content = ''
          chain prerouting {
            type nat hook prerouting priority -100; policy accept;
            tcp dport 80 counter dnat to :8080
            tcp dport 443 counter dnat to :8443
          };
        '';
      };
    };
  };

  # Wireguard
  # Goal: For any outgoing packet in reply to incoming packets from wg tunnel,
  # route back through wg tunnel. Otherwise route through open internet
  # To achieve this, we mark the new connections established from tunnel
  # Then conditionally mark outgoing packets if the connection is marked
  # The outgoing packet mark determines the routing table to lookup, which determines the route
  networking.nftables.tables.wg_mark = {
    family = "inet";
    content = ''
      chain prerouting {
        type filter hook prerouting priority -150; policy accept;
        iifname "${wg_intf}" ct state new ct mark set ${toString wg_mark} # mark conn if conn new
      }

      chain output {
        type route hook output priority -150; policy accept;
        ct mark ${toString wg_mark} meta mark set ${toString wg_mark} # mark outgoing packet based on conn mark
      }
    '';
  };
  # Wireguard conf
  systemd.network.netdevs."20-${wg_intf}" = {
    netdevConfig = {
      Name = wg_intf;
      Kind = "wireguard";
    };
    wireguardConfig = {
      PrivateKeyFile = config.sops.secrets.wg_privkey.path;
      RouteTable = "off"; # dont configure route for outgoing packets destined for AllowedIPs
      # Don't configure FirewallMark (which marks out outgoing packets) 
    };
    wireguardPeers = [{
      # vps
      PublicKey = "CQvf4nOExaVkaiWpsxx0OctRU4N51xRYdKUoKteegQk=";
      Endpoint = "74.208.158.11:51820";
      AllowedIPs = [ "0.0.0.0/0" ]; # this wouldve route everything through tunnel if RouteTable is not off
      PersistentKeepalive = 25;
    }];
  };
  # Wireguard network routing
  systemd.network.networks."20-${wg_intf}" = {
    matchConfig.Name = "${wg_intf}";
    address = [ "10.0.0.2/24" ]; # this server's wg ip
    routingPolicyRules = [{
      FirewallMark = wg_mark; # for any packet marked
      Table = wg_table; # use this table
      Priority = 100; # low priority = high number
    }];
    routes = [{
      Table = wg_table; # route traffic of this table
      Destination = "10.0.0.1"; # to vps ip
    }];
  };
  environment.systemPackages = with pkgs; [ wireguard-tools ];

  sops.secrets.wg_privkey = {
    key = "wg_privkey";
    group = "systemd-network"; # ensure privkey readable by systemd-network
    mode = "0440";
  };
}
