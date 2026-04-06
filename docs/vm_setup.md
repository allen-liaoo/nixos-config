1. Make directory to store VM:
```
mkdir -p /var/lib/libvirt/images/NixOS-25.11/
```
2. Download NixOS minimal ISO to 
```
/var/lib/libvirt/images/
```
3. Create VM:
```
sudo virt-install --name guinea \
         --connect qemu:///session \
         --ram 8192 \
         --vcpus 2 \
         --disk path=/var/lib/libvirt/images/NixOS-25.11/guinea.x86_64.qcow2,size=20 \
         --network network=default,model=virtio,mac=52:54:00:ab:cd:ef \
         --graphics spice \
         --boot uefi \
         --features smm.state=off \
         --noautoconsole \
         --cdrom /var/lib/libvirt/images/nixos-minimal-x86_64-linux.iso
```
This disables secure boot and pins VM mac addr. I use sudo to skip manual setup of networking. To reset VM:
```
sudo virsh destroy guinea ; sudo virsh undefine guinea --remove-all-storage --nvram
```
3. Install OS and reboot (see install doc)
4. SSH into VM once OS is installed (statically set to `192.168.122.100`)

If SSH is not working:

3. Make VM console temporarily accessible in host (run in VM console):
```
sudo systemctl start serial-getty@ttyS0.service
```
4. Open console in host:
```
sudo virsh console guinea
```
I have to set stty dimensions to prevent vanishing lines:
```
stty rows 40 cols 181
```
