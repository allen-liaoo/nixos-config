{ inputs, config, lib, pkgs, aln, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];

  # Since I swapped MediaTek WIFI card with Intel AX210
  hardware.enableRedistributableFirmware = true;

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
  };

  # LUKS devices
  boot.initrd.luks.devices = {
    cryptroot = {
      device = lib.mkForce "/dev/disk/by-partlabel/disk-main-luks"; # conflicts with disko
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

  users.users.${aln.inventory.users.allenl.name}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPevSDBLs3jQWYE8sq2Dx6S2qQ4VzpKn5RvS1    zXkGfiW wcliaw610@gmail.com"
  ];
}
