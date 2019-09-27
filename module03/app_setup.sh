#!bin/bash -x

# Add user:
useradd -p $(openssl passwd -1 P@ssw0rd) admin
usermod -aG wheel admin

# Install additional programs:
yum install -y epel-release vim git tcpdump curl net-tools bzip2
yum update -y

# Set up ssh:
mkdir /home/admin/.ssh/
/bin/cp -rf acit_admin_id_rsa.pub /home/admin/.ssh/authorized_keys
chown admin:admin -R /home/admin/.ssh/

sed -r -i 's/^(%wheel\s+ALL=\(ALL\)\s+)(ALL)$/\1NOPASSWD: ALL/' /etc/sudoers

# Firewall:
firewall-cmd --zone=public --add-service=http
firewall-cmd --zone=public --add-service=https
firewall-cmd --zone=public --add-service=ssh

firewall-cmd --runtime-to-permanent

# Linux SE:
setenforce 0
sed -r -i 's/SELINUX=(enforcing|disabled)/SELINUX=permissive/' /etc/selinux/config

# Web Service:

useradd -m -r todo-app && passwd -l todo-app
yum install -y nodejs npm
yum install -y mongodb-server
systemctl enable mongod && systemctl start mongod

# Application:
su - todo-app
mkdir app
git clone https://github.com/timoguic/ACIT4640-todo-app.git app;
cd app
npm install

exit

/bin/cp -rf Files/database.js /home/todo-app/app/config
chmown todo-app:todo-app -R /home/todo-app/app/config/database.js
chmod -R 755 /home/todo-app/

# NGINX
yum install -y nginx
systemctl enable nginx && systemctl start nginx
/bin/cp -rf Files/nginx.conf /etc/nginx/
nginx -s reload

# NodeJS as a Deamon:
/bin/cp -rf Files/todoapp.service /lib/systemd/system
systemctl daemon-reload
systemctl enable todoapp && systemctl start todoapp


# Guest Additions:

# yum install -y kernel-devel kernel-headers gcc make
# mkdir -p /media/cdrom
# mount /dev/cdrom /media/cdrom
# cd /media/cdrom && sh VBoxLinuxAdditions.run
# cd /root && umount /media/cdrom

reboot -h now