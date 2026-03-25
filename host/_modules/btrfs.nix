# For btrfs subvolume declarations, see disko.nix
{ lib, aln, ... }:

# ASSUMES btrfs partition root has label "btrfsroot"
let
  disk_root = "btrfsroot";
in 
{
  # mount btrfs partition for btrbk
  fileSystems."/mnt/${disk_root}" = {
    device = "/dev/disk/by-label/${disk_root}"; # stable across reboots/renames
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

      volume."/mnt/${disk_root}" = {
        snapshot_dir = "@snapshots";
        subvolume = lib.optionalAttrs aln.ctx.host.is.server {
          # servers use impermance, only need to snapshot containers
          "@containers" = {};
        } // (lib.optionalAttrs (!aln.ctx.host.is.server)) {
          # nonservers - no impermanence 
          "@" = {};
          "@home" = {};
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
