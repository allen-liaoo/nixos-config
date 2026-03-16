{ config, lib, pkgs, hostName, ... }:

{
  imports = [
    ./../common/configuration.nix

    ./disko.nix
    ./hardware-configuration.nix
    ./sops.nix
  ];

  nix.settings = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];
  };

  time.timeZone = "US/Chicago";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  environment.systemPackages = with pkgs; [
    age
    btop
    curl
    dig             # in: dnsutils or bind 
    git
    home-manager
    iproute2        # ip, ss
    iputils         # ping, tracepath
    just
    lsof
    nmap
    procps          # ps, top
    sops
    tcpdump
    traceroute
    vim
    wget
    whois
    unzip
    util-linux
    zip
  ];

  # Make network interfaces use predictable names (e.g. eth0, wlan0) instead of the default (e.g. enp1s0)
  boot.kernelParams = [ "net.ifnames=0" "biosdevname=0" ];

  # Make VM IP predictable
  networking.useDHCP = false;
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    networks."10-eth0" = {
      matchConfig.Name = "eth0";
      address = [ "192.168.122.100/24" ];
      gateway = [ "192.168.122.1" ];
      dns = [ "8.8.8.8" "1.1.1.1" ];
      linkConfig.RequiredForOnline = "routable";
    };
  };

  networking.hostName = hostName;

  users.mutableUsers = false;
  users.users."pig" = { # TODO: pass in users attr per host?
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    linger = true;
    password = "123";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPevSDBLs3jQWYE8sq2Dx6S2qQ4VzpKn5RvS1zXkGfiW wcliaw610@gmail.com"
    ];
  };
}
