1. Download NixOS minimal ISO
2. Create VM:
```
sudo virt-install --name guinea \
         --connect qemu:///session \
         --ram 8192 \
         --vcpus 2 \
         --disk path=$HOME/.local/share/libvirt/images/NixOS-25.11/guinea.x86_64.qcow2,size=20 \
         --network network=default,model=virtio,mac=52:54:00:ab:cd:ef \
         --graphics spice \
         --boot uefi \
         --features smm.state=off \
         --noautoconsole \
         --cdrom $HOME/.local/share/libvirt/images/nixos-minimal-25.11.7346.44bae273f9f8-x86_64-linux.iso
```
This disables secure boot and pins VM mac addr. I use sudo to skip manual setup of networking. To reset VM:
```
sudo virsh destroy guinea ; sudo virsh undefine guinea --remove-all-storage --nvram
```

3. Make VM console temporarily accessible in host (run in VM console):
```
sudo systemctl start serial-getty@ttyS0.service
```
4. Open console in host:
```
virsh console guinea
```
5. Manual setup 
```
git clone https://github.com/allen-liaoo/nixos-config.git ; stty rows 40 cols 181 ; export host=guinea 
```
6. Install gnumake (`nix-shell -p gnumake`)
7. Use Makefile (one-time use) targets
8. SSH into VM once OS is installed (statically set to `192.168.122.100`)