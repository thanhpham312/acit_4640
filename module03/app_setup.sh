# Add user:
adduser admin
passwd P@ssw0rd
usermod -aG wheel username

# Install additional programs:
yum install -y wget
yum install -y epel-release vim git tcpdump curl net-tools bzip2
yum update -y

# Set up ssh:
mkdir -p ~admin/.ssh/authorized_keys
/bin/cp -rf acit_admin_id_rsa.pub ~admin/.ssh/authorized_keys/
# wget https://acit4640.y.vu/docs/module02/resources/acit_admin_id_rsa.pub -P ~admin/.ssh/authorized_keys/

chown admin: ~admin/.ssh/
chmod u+r: ~admin/.ssh/
chown admin: ~admin/.ssh/authorized_keys/
chmod u+r: ~admin/.ssh/authorized_keys/
chown admin: ~admin/.ssh/authorized_keys/acit_admin_id_rsa.pub
chmod u+r: ~admin/.ssh/authorized_keys/acit_admin_id_rsa.pub

sed -r -i 's/^(%wheel\s+ALL=\(ALL\)\s+)(ALL)$/\1NOPASSWD: ALL/' /etc/sudoers

# Firewall:
firewall-cmd --zone=public --add-service=http
firewall-cmd --zone=public --add-service=https
firewall-cmd --zone=public --add-service=ssh

firewall-cmd --runtime-to-permanent

# Linux SE:
sed -r -i 's/SELINUX=(enforcing|disabled)/SELINUX=permissive/' /etc/selinux/config

# Web Service:

useradd -m -r todo-app && passwd -l todo-app
yum install -y nodejs npm
yum install -y mongodb-server
systemctl enable mongod && systemctl start mongod

# Application:
sudo -H -u todo-app bash -c "
mkdir app;
git clone https://github.com/timoguic/ACIT4640-todo-app.git app;
cd app;
npm install;"
/bin/cp -rf Files/database.js /home/todo-app/app/config
nginx -s reload

# NGINX
yum install -y nginx
systemctl enable nginx && systemctl start nginx
/bin/cp -rf Files/nginx.conf /etc/nginx/

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

# reboot -h now