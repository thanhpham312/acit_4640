#!/bin/bash -x
vbmg () { VBoxManage.exe "$@"; }

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
