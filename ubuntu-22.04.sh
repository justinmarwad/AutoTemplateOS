name="AutoUbuntu2204"
password="$(openssl passwd -1 'password')" 
ssh_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3zgAB9nMNlOwgDssWQBfVvhuVcHS0amnWRe/aUx74//p6XRYrfypa+rTCMrjxJU9zlR1L+d6KVzuGtlCqtCIR+25ssXeOTIf5+Kk1v8Ig5J9F0iOI2fselnG1BzdSBy2YseqC/AMhAluY2Za9u07tEtRdutuESlyMm6HIWts/O7VNS9P8x+rLdpXnXxjF7sCqevL8FmRnyPdq49poeX4BYblyB5eU/Ia0xWLej9GBV17/ZSClIOCxxkyYeRFbtOtBRjriKuoB4DMQDNuHG9bopNHLJErTphGug2DjTYrZyclIowUVA8fjX7/fu2xL5HL2wpokDF3JtEbQt3duegAj1hAHLnyJF5mgqucWIzp+wf8xqNw/ilT8qnI0SIZl7hrR2tv40Hkqpu4LiZ3etRsbXPxcDc5j6/gsToQc2kNKlHNLlbLdZWlkIirT6XjS12bCdOgIL+r9iH3GZSwFYpr2EouWiFykI+QkYlQ58ZQls3TsIPA4A6HOdNcojiZ9FGvRRr69quobJdu/CXPMOwwn4WvL1KR4ZcUeVOwEisJUm7b9RKNJ1mO2KpIKW6btG612qcCuT+pZUJSkenDF5cpvV2q9TUe0RXwEDuy4O7qyA/vZhXF6WfsOfV+eFli6dZW8jU1QxhF8ybRTqdORUGvresgi9ME8ySi0p5mGGgUiiQ== user@host"

image="jammy-server-cloudimg-amd64.img"

vmid=9999 
mem=2048
cpu=2
proxmox_volume="gfs-volume-proxmox" 


# [1] Install Required Libraries

# if package not installed, then install it
if [ ! -f /usr/bin/virt-customize ]; then
    apt update -y; apt install libguestfs-tools -y; apt install linux-image-generic -y
fi

# [2] Get Latest Image

# if image doesn't exist, then download it 
if [ ! -f $image ]; then
    wget https://cloud-images.ubuntu.com/jammy/current/$image -O $image
fi

# [3] Install Packages  
virt-customize -a $image --install qemu-guest-agent

# [4] Add User + SSH Keys
virt-customize -a $image --run-command 'useradd -m user -p $password'
# virt-customize -a $image --ssh-inject user:file:authorized_keys # copy users ssh key from file to the image
virt-customize -a $image --ssh-inject user:string:ssh_key # copy users ssh key as string to the image

# [5] Add Specs 
qm create $vmid --name "$name" --memory $mem --cores $cpu --net0 virtio,bridge=vmbr0

qm importdisk $vmid $image $proxmox_volume --format qcow2  # import disk
qm set $vmid --scsihw virtio-scsi-pci --scsi0 $proxmox_volume:vm-$vmid-disk-0 # change device of disk to scsi (otherwise it will be an unused disk)
qm set $vmid --boot c --bootdisk scsi0

qm set $vmid --ide2 $proxmox_volume:cloudinit
qm set $vmid --serial0 socket --vga serial0
qm set $vmid --agent enabled=1

# [6] Create Template 
qm template $vmid

# [7] Cleanup
rm $image

echo "[+] Done!"
