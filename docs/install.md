## NixOS Install
Assuming that the host machine is booted with NixOS minimal ISO, and an admin machine with access to this repository and can edit secrets is accompanying the host. Essentially, what is needed to bootstrap a host is (a) a local copy of this repository with host-specific configs, and (b) host ssh keys, which are used to decrypt secrets.
#### Setup
0. (admin) Setup configs by creating `/host/<hostname>/{disko,configuration,default}.nix`
1. Boot host with NixOS minimal ISO
2. Gain SSH access to host from admin machine  
    a. (host) Check ip with `ip a`  
    b. (host) Set password on host with `passwd`  
    c. SSH in: `ssh nixos@<ip>`
3. (host) Setup temporary git repository
```
git clone --recurse-submodules https://github.com/allen-liaoo/nix-config.git
cd nix-config
nix-shell -p just
```

#### Partition disks
4. Partition disks (might need to `lsblk` first and tweak `disko.nix`)
```
just disko <hostname>
```
#### Obtain ssh host key and hardware-configuration
5. (host) Generate host ssh key that will be used to boot (by sops nix). This will print an age key. Copy it.
```
just gen-install-host-key <hostname>
```
6. Generate hardware configuration on host
```
just gen-hardware-config
```
7. (admin) Update the secrets so they are decryptable by the host key generated

a. Edit `.sops.yaml` by adding the host and its age key.  
b. Add secrets for the host and its user. Include user age key and password. To create a new secret file:
```
# Enter dev shell which installs sops
just dev 
sops secrets/<path/to/secret/file>
```
   c. Update secret encryption and push changes
```
just sops-rekey
```
8. Copy hardware configuration to admin
9. Push on admin, and pull on host

#### Install
10. Install and reboot. Note that if using impermanence, second param shoud be true.
```
just os-install <hostname> <impermanent>
sudo reboot now
```

## Home Manger Install
### On NixOS
After installing NixOS and rebooting, the users with passwords should be created. We just need to install their home manager modules.
1. Clone repository
2. Switch home manager
```
just hm-switch
```
3. Switch repository to ssh (ssh keys to push to repo should automatically be detected)
```
just repo-switch-ssh
```

### Non-NixOS
> NOT TESTED
1. Clone repository
2. Drop age (private) key in `~/.config/sops/age/key.txt`
3. Switch home manager
4. Switch repository to ssh

#### xremap
Need to have sudo priviledge, or user is in `input` group, uinput kernel module is loaded, and `input` group has `uaccess`
```
sudo gpasswd -a YOUR_USER input
echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess", MODE:="0660", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/99-input.rules
```
Otherwise there is no way to use it.
