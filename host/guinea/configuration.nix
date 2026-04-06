{ config, lib, pkgs, aln, ... }:

{
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Make network interfaces use predictable names (e.g. eth0, wlan0) instead of the default (e.g. enp1s0)
  boot.kernelParams = [ "net.ifnames=0" "biosdevname=0" ];

  # LUKS devices
  boot.initrd.luks.devices = {
    cryptroot = {
      device = lib.mkForce "/dev/disk/by-partlabel/disk-main-root";
      allowDiscards = true;
    };
  };

  boot.tmp.useTmpfs = true;
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    # memoryPercent defaults to 50, adjust as needed
  };

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

  # for debugging purposes
  users.users.root.password = "fgh";
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  users.users.${aln.inventory.users.pig.name}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPevSDBLs3jQWYE8sq2Dx6S2qQ4VzpKn5RvS1zXkGfiW wcliaw610@gmail.com"
  ];
}
