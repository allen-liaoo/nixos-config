Assuming that the host machine is booted with NixOS minimal ISO, and `host/hostname/{disko,configuration}.nix` files have been made. An admin machine with access to this repository and can edit secrets is accompanying the host.

```
git clone https://github.com/allen-liaoo/nix-config.git
cd nix-config
nix-shell -p just

just disko hostname
just os-install
reboot

# on startup, at console
cd nix-config
just os-setup

# then, one can ssh into the machine if configuration.nix is setup correctly

just gen-host-key
# This grabs the key at /etc/ssh/ssh_host_ed25519_key
# and returns an age key

# in admin machine, add age key to .sops.yaml, add corresponding secrets,
# run "sops updateKeys" on relevant secret files, and push changes

# then, git pull in host, and
just os-switch
just hm-switch
just repo-switch-ssh
```
