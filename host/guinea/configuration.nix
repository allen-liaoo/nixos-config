{ config, lib, pkgs, ... }:

{
  time.timeZone = "US/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

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
    wait-online.enable = true;
    networks."10-eth0" = {
      matchConfig.Name = "eth0";
      address = [ "192.168.122.100/24" ];
      gateway = [ "192.168.122.1" ];
      dns = [ "8.8.8.8" "1.1.1.1" ];
      linkConfig.RequiredForOnline = "routable";
    };
  };
  # Need network-online for podman-user-wait-network-online.service
  systemd.targets.network-online.wantedBy = [ "multi-user.target" ];

  users.mutableUsers = false;

  users.users."pig" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    linger = true;
    hashedPasswordFile = config.sops.secrets.passwd_pig.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPevSDBLs3jQWYE8sq2Dx6S2qQ4VzpKn5RvS1zXkGfiW wcliaw610@gmail.com"
    ];

    # required for rootless container w multiple users
    autoSubUidGidRange = true;
  };

  # to enable podman & podman systemd generator
  # virtualisation.quadlet.enable = true;
}
