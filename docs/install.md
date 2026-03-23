Assuming that the host machine is booted with NixOS minimal ISO, and an admin machine with access to this repository and can edit secrets is accompanying the host. Essentially, what is needed to bootstrap a host is (a) a local copy of this repository with host-specific configs, and (b) host ssh keys, which are used to decrypt secrets.

1. (admin) Setup configs by creating `/host/<hostname>/{disko,configuration,default}.nix`
2. Gain SSH access to host from admin machine  
    a. (host) Check ip with `ip a`  
    b. (host) Set password on host with `passwd`  
    c. SSH in: `ssh nixos@<ip>`
3. (host) Setup temporary git repository
```
git clone https://github.com/allen-liaoo/nix-config.git
cd nix-config
nix-shell -p just
```
4. Partition disks (might need to `lsblk` first and tweak `disko.nix`)
```
just disko <hostname>
```
5. (host) Generate host ssh key that will be used to boot (by sops nix). Note that if using impermanence, second param shoud be true. This will print an age key. Copy it.
```
just gen-install-host-key <hostname> <persist>
```
6. (admin) Update the secrets so they are decryptable by the host key generated

a. Edit `.sops.yaml` by adding the host and its age key. Make sure to add secrets for the host user, including user age key and password. To create a new secret file:
```
# enters dev shell which install sops
just dev 
sops secrets/<path/to/secret/file>
```
   b. Update secret encryption and push changes
```
just sops-rekey
git push
```
7. (host) Pull secret changes
8. Install and reboot
```
just os-install <hostname>
sudo reboot now
```

