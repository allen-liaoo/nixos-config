{ config, lib, pkgs, aln, ... }:

{
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  boot.loader = {
    systemd-booti.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # LUKS devices
  boot.initrd.luks.devices = {
    cryptroot = {
      device = "/dev/disk/by-partlabel/disk-main-luks";
      allowDiscards = true;
    };
    cryptswap = {
      device = "/dev/disk/by-partlabel/disk-main-swap";
      allowDiscards = true;
    };
  };

  boot.tmp.useTmpfs = true;
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    # memoryPercent defaults to 50
  };

  users.users.${aln.inventory.users.allen.name}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPevSDBLs3jQWYE8sq2Dx6S2qQ4VzpKn5RvS1    zXkGfiW wcliaw610@gmail.com"
  ];
}
