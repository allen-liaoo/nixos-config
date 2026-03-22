# For btrfs subvolume declarations, see disko.nix
{ lib, aln, ... }:

{
  boot.tmp.useTmpfs = true;
  #boot.tmp.tmpfsSize = "1G";

  # mount bbtrfs partition for btrbk
  fileSystems."/mnt/btrfsroot" = {
    device = "/dev/disk/by-label/btrfsroot"; # stable across reboots/renames
    fsType = "btrfs";
    options = [ 
      "subvol=/" "noatime" "compress=zstd"
      "nofail" # dont block boot if this fails
    ];
  };

  # automatic snapshots
  services.btrbk.instances.btrbk = {
    onCalendar = "daily";
    settings = {
      snapshot_preserve_min = "2d"; # preserve all snapshots within this period no matter the amount
      snapshot_preserve = "7d 4w 6m"; # keep 7 daily, 4 weekly, 6 monthly

      volume."/mnt/btrfsroot" = {
        snapshot_dir = ".snapshots";
        subvolume = {
          "@" = {};
          "@home" = {};
          #"@containers" = {};
        };
      };
    };
  };

  # integrity check
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };
}
