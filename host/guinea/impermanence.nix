{ lib, aln, ... }:

# Impermanence only wipes the root subvolume on boot,
# any other top level subvolumes (declared in disko.nix) will persist
# - If data is large and noisy, put it in its own subvolume (i.e. @containers, @snapshots)
# - Otherwise, if it is meaningful for system state, put in root volume and persist (i.e. /etc/ssh, /var/lib/nixos)

# BTRFS:
# Impermanence assumes the btrfs structure:
# - Root btrfs volume (not OS root) is labeled "btrfsroot"
# - Root subvolume (mapped to /) is named "@"
# - All subvolumes one wants to persist does not have the root subvolume @ as its parent (ok: another top level subvolume)

# sops-nix
# sops-nix requires the ssh host keys to exist at boot to work. 
# See end of this file
let
  disk_root = "btrfsroot";
  root_subvol = "@";
in 
lib.optionalAttrs (aln.ctx.host.hasTags [ "impermanent" ]) {
  # Need to mark all btrfs subvolumes who are source or target of persistence bind mounts as neededForBoot
  # Otherwiswe there will be no subvolume to bind mount from/to
  fileSystems."/persist".neededForBoot = true;

  #  Reset root subvolume on boot
  boot.initrd.postResumeCommands = lib.mkAfter ''
    # Mount the raw btrfs top-level somewhere temporary
    mkdir /btrfs_tmp
    mount /dev/disk/by-label/${disk_root} /btrfs_tmp

    # If a previous root subvolume exists, archive it with a timestamp
    if [[ -e /btrfs_tmp/${root_subvol} ]]; then
      mkdir -p /btrfs_tmp/old_roots
      timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/${root_subvol})" "+%Y-%m-%-d_%H:%M:%S")
      mv /btrfs_tmp/${root_subvol} "/btrfs_tmp/old_roots/$timestamp"
    fi

    # Delete archived roots older than 30 days
    # Has to recurse because btrfs won't delete a subvolume with nested subvolumes
    delete_subvolume_recursively() {
      IFS=$'\n'
      for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
        delete_subvolume_recursively "/btrfs_tmp/$i"
      done
      btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
      delete_subvolume_recursively "$i"
    done

    # Create a fresh empty root subvolume for this boot
    btrfs subvolume create /btrfs_tmp/${root_subvol}
    umount /btrfs_tmp
    # Now NixOS mounts this fresh /root subvolume as /
  '';

  # below paths shoud only contain data that are under root subvolume
  # NOTE: do not persist both a file and its parent directory
  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/lib/nixos" # nixos state

      "/var/log" # system logs
      "/var/lib/systemd/coredump" # crash dumps
      "/var/lib/systemd/timers"
    ] ++ 
    lib.optionals (aln.ctx.host.is.server) [
      "/var/lib/systemd/network" 
      #"/var/lib/containers" # since this is on separate subvolume, no need to persist it as it wont be wiped
    ] ++
    lib.optionals (!aln.ctx.host.is.server) [
      "/var/lib/bluetooth"
      "/etc/NetworkManager/system-connections"
      "/var/lib/cups" # printer
    ] ++
    # for each user NOT using impermanence, persist their home directory
    lib.concatMap (user: lib.optionals (!user.hasTags [ "impermanent" ]) [
      { directory = "/home/${user.name}"; user = user.name; mode = "0700"; }
    ]) aln.ctx.host.users;

    files = [
      "/etc/machine-id"  # stable machine identity

      # these are the only files necessary to persist on initial install,
      # the rest of the configs can be generated from the config with these keys
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];

    # persist specific directories of users using impermanence
    users = lib.mergeAttrsList (map (user: {
      ${user.name} = lib.optionalAttrs (user.hasTags [ "impermanent" ]) {
        directories = [
            { directory = ".ssh"; mode = "0700"; }
            { directory = ".config/sops"; mode = "0700"; }
            "nix-config"
          ];
        files = [];
      };
    }) aln.ctx.host.users);
  };

  # When using impermanence, the host key is stored in the persist volume
  # when sops-nix tries to read it, so we need to point it to the new location
  sops.age.sshKeyPaths = [
    "/persist/etc/ssh/ssh_host_ed25519_key" 
  ];
  # We don't need to add /persist path to sshd's hostKeys generation because initial install
  # takes care of generating the host keys in persist volume
  # subsequent generation in /etc will be wiped and replaced by the one in persist on each boot
}
