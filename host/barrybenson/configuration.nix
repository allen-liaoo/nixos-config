{ pkgs, inventory, ... }:

{
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.grub = {
    enable = true;
    device = "nodev"; # "nodev" is used for UEFI
    efiSupport = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.tmp.useTmpfs = true;
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    # memoryPercent defaults to 50
  };

  users.users.${inventory.users.al.name}.openssh.authorizedKeys.keys = [
    inventory.users.allenl.data.ssh_pubkey # allenl can remote into al
  ];
}
