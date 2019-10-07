#!/bin/bash -x
vbmg () { VBoxManage.exe "$@"; }

# Nat Network Creation and Configuration

vbmg natnetwork remove --netname net_4640

vbmg natnetwork add \
--netname net_4640 \
--network "192.168.250.0/24" \
--enable \
--ipv6 off \
--dhcp off

vbmg natnetwork modify \
--netname net_4640 \
--port-forward-4 "ssh:tcp:[]:50022:[192.168.250.10]:22"

vbmg natnetwork modify \
--netname net_4640 \
--port-forward-4 "http:tcp:[]:50080:[192.168.250.10]:80"

vbmg natnetwork modify \
--netname net_4640 \
--port-forward-4 "https:tcp:[]:50443:[192.168.250.10]:443"

vbmg natnetwork modify \
--netname net_4640 \
--port-forward-4 "https:tcp:[]:50222:[192.168.250.200]:22"

# Virtual Machine Creation
VM_NAME="VM_ACIT4640"

vbmg unregistervm $VM_NAME --delete

vbmg createvm \
--name $VM_NAME \
--ostype RedHat_64 \
--register \
--basefolder "D:/VirtualBox VMs"

SED_PROGRAM="/^Config file:/ { s/^.*:\s\+\(\S\+\)/\1/; s|\\\\|/|gp }"
VBOX_FILE=$(vbmg showvminfo "$VM_NAME" | sed -ne "$SED_PROGRAM")
VM_DIR=$(dirname "$VBOX_FILE")
VM_STORAGE_CTL_NAME="${VM_NAME}_STORAGE_CLT"
VM_VDI_PATH="${VM_DIR}/${VM_NAME}.vdi"

vbmg modifyvm $VM_NAME \
--cpus 1 \
--memory 1024 \
--nic1 natnetwork \
--nat-network1 net_4640 \
--cableconnected1 on \
--audio none \
--boot1 disk \
--boot2 net

vbmg storagectl $VM_NAME --name $VM_STORAGE_CTL_NAME --add sata

vbmg storageattach $VM_NAME \
--storagectl "${VM_STORAGE_CTL_NAME}" \
--port 0 \
--type dvddrive \
--medium D:/CentOS-7-x86_64-Minimal-1810.iso

vbmg createmedium \
--filename "${VM_VDI_PATH}" \
--size 10240 \
--format VDI \
--variant Standard

vbmg storageattach $VM_NAME \
--storagectl $VM_STORAGE_CTL_NAME \
--port 1 \
--type hdd \
--medium "${VM_VDI_PATH}"

vbmg startvm PXE_4640

while /bin/true; do
        ssh -p 50222 -o ConnectTimeout=2s -o StrictHostKeyChecking=no -o IdentityFile=~/.shh/acit_admin_id_rsa -q admin@localhost exit
        if [ $? -ne 0 ]; then
                echo "PXE server is not up, sleeping..."
                sleep 2s
        else
                break
        fi
done

sleep 15s

vbmg startvm $VM_NAME

scp -r Files admin@PXE:/home/admin/
ssh admin@PXE "sudo mv -r /home/admin/Files /var/www/lighttpd/ ; sudo mv /var/www/lighttpd/Files/ks.cfg /var/www/lighttpd/ks.cfg"



