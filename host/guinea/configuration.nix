{ config, lib, pkgs, ... }:

{
  time.timeZone = "US/Chicago";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

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
