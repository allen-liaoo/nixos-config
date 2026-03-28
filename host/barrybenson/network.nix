{ lib, config, pkgs, ... }:

let
  eth_intf = "enp1s0";
  wg_intf = "wg_vps";
  podman_intf = "podman0";
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

  # Firewall
  networking.firewall.enable = false; # use our own fw
  networking.nftables = {
    enable = true;
    checkRuleset = true;
    #flushRuleset = true; # do not flush, or podman's fw get flushed
  };
  networking.nftables.tables.global = { # table for global firewall no matter the interface
    family = "inet";
    content = ''
      chain input {
        type filter hook input priority 30; policy drop;
        ct state { established, related } accept
        iif "lo" accept
        ip protocol icmp limit rate 10/second accept
        ip6 nexthdr icmpv6 limit rate 10/second accept
        tcp dport 22 accept # ssh
      }
    '';
  };

  # Podman default bridge behavior with published port:
  # - Ingress: in prerouting, dnat to podman0 interface and container ip based on port, hence packets go through forward hook
  # - Egress: from podman0, masqueraded for egress traffic, or simply accepted for inter-container traffic
  # So both inbound/outbound goes through prerouting -> forward -> postrouting
  networking.nftables.tables.podman_global = {
    family = "inet";
    content = ''
      set WG_SUBNETS { # trusted ips
        type ipv4_addr
        flags interval;
        elements = { 10.0.0.0/24, 10.0.10.0/24 }
      }
      chain wg_input {
        tcp dport { 80, 443 } accept
      }
      chain forward {
        type filter hook forward priority 30; policy drop;
        ct state { established, related } accept
        # Allow wg inbound traffic to access containers at specific ports
        iifname "${wg_intf}" oifname "${podman_intf}" jump wg_input
        # Allow traffic from podman bridge outbound (to internet, tunnel, or inter-container)
        iifname "${podman_intf}" accept
      }
    '';
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
        # mark conn from wg if conn new
        iifname "${wg_intf}" ct state new ct mark set ${toString wg_mark} # mark conn if conn new
        # mark meta of packet outgoing from podman in if conn marked (note: doing this in output will be useless in bridge mode)
        iifname "${podman_intf}" ct mark ${toString wg_mark} meta mark set ${toString wg_mark}
      }
    '';
  };
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
      Destination = "0.0.0.0/0"; # default route for any traffic
      Gateway = "10.0.0.1"; # go to vps ip
    }];
  };
  environment.systemPackages = with pkgs; [ wireguard-tools ];

  sops.secrets.wg_privkey = {
    key = "wg_privkey";
    group = "systemd-network"; # ensure privkey readable by systemd-network
    mode = "0440";
  };
}
