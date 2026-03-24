{ lib, ... }:

# TODO: enable
lib.optionalAttrs false {
  # Use a fully custom nftables ruleset instead of the NixOS firewall abstraction.
  networking.firewall.enable = false;

  networking.nftables = {
    enable = true;
    checkRuleset = true;
    flushRuleset = true;
    tables = {
      internal_redirect = {
        family = "inet";
        content = ''
          chain prerouting {
              type nat hook prerouting priority -100; policy accept;

              # HTTP/S (reverse proxy)
              tcp dport 80 counter dnat to :8080
              tcp dport 443 counter dnat to :8443

              # Pihole DNS
              tcp dport 53 counter dnat to :55053
              udp dport 53 counter dnat to :55053
          }
        '';
      };

      tunnel_mark = {
        family = "inet";
        content = ''
          chain prerouting {
              type filter hook prerouting priority -150; policy accept;

              # Mark NEW connections arriving from wg0
              iifname "wg0" ct state new ct mark set 51820
          }

          chain output {
              type route hook output priority -150; policy accept;

              # Use connection mark for mark of reply packets.
              # This ensures replies get routed by table 51820 through vpn tunnel.
              ct mark 51820 meta mark set 51820
          }
        '';
      };

      global = {
        family = "inet";
        content = ''
          # Trusted ips
          set WG_SUBNETS {
              type ipv4_addr
              flags interval;
              elements = { 10.0.0.0/24, 10.0.10.0/24 }
          }

          # Rules for incoming from vps.
          # When a port is open to internal redirects but not to the public, use "ct status dnat".
          chain wg0_input_public {
              # HTTP/S (see internal_redirect)
              tcp dport { 8080, 8443 } counter accept

              # Minecraft
              tcp dport 25565 accept
          }

          # Private services (traffic from trusted wg ips)
          chain wg0_input_private {
              # Pihole DNS (see internal_redirect)
              ct status dnat tcp dport 55053 accept
              ct status dnat udp dport 55053 accept
          }

          chain input {
              # Drop all incoming except below
              type filter hook input priority 0; policy drop;

              # Allow established/related connections
              ct state { established, related } accept

              # Allow loopback traffic
              iif "lo" accept

              iifname "wg0" jump wg0_input_public

              # Prevent trusted IP spoofing
              iifname "wg0" ip saddr @WG_SUBNETS jump wg0_input_private

              # Allow SSH (port 22)
              tcp dport 22 accept

              # Allow ICMP (ping)
              ip protocol icmp limit rate 10/second accept
              ip6 nexthdr icmpv6 limit rate 10/second accept

              log prefix "DROP_INPUT: " limit rate 5/minute
              counter drop
          }

          # Drop all forwarding except established
          chain forward {
              type filter hook forward priority 0; policy drop;

              ct state { established, related } accept
          }

          # Accept all outgoing
          chain output {
              type filter hook output priority 0; policy accept;
          }
        '';
      };
    };
  };
}
