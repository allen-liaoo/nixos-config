# For btrfs subvolume declarations, see disko.nix
{ lib, ctx, ... }:

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
        # TODO: Change to module
        subvolume = (lib.optionalAttrs ctx.host.is.server {
          # servers only need to snapshot containers
          "@containers" = {};
        }) // (lib.optionalAttrs (!ctx.host.is.server) {
          # nonservers 
          "@" = {};
          "@home" = {};
        });
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
