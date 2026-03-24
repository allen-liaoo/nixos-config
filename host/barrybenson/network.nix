{ lib, config, pkgs, ... }:

{
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    wait-online.enable = true;
    networks."10-enp1s0" = {
      matchConfig.Name = "enp1s0";
      DHCP = "ipv4";
      linkConfig.RequiredForOnline = "routable";
      dns = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];
    };
  };

  # Need network-online for podman-user-wait-network-online.service
  systemd.targets.network-online.wantedBy = [ "multi-user.target" ];

  # wireguard tunnel to vps
  environment.systemPackages = with pkgs; [ wireguard-tools ];
  systemd.network.networks."20-wg_vps" = {
    matchConfig.Name = "wg_vps";
    address = [ "10.0.0.2/24" ]; # this server's wg ip
    #routingPolicyRules = [{
      #FirewallMark = 51820;
      #Table = 51820;
      #Priority = 100;
    #}];
    #routes = [{
      #Destination = "0.0.0.0/0";
      #Table = 51820;
    #}];
  };

  systemd.network.netdevs."20-wg_vps" = {
    netdevConfig = {
      Name = "wg_vps";
      Kind = "wireguard";
    };
    wireguardConfig = {
      PrivateKeyFile = config.sops.secrets.wg_privkey.path;
    };
    wireguardPeers = [{
      PublicKey = "CQvf4nOExaVkaiWpsxx0OctRU4N51xRYdKUoKteegQk=";
      Endpoint = "74.208.158.11:51820";
      AllowedIPs = [ "10.0.0.1/32" ];
      PersistentKeepalive = 25;
    }];
  };

  sops.secrets.wg_privkey = {
    key = "wg_privkey";
    group = "systemd-network"; # ensure privkey readable by systemd-network
    mode = "0440";
  };
}
