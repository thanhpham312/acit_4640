#!/bin/bash -x

# Add user
configure_users () {
    useradd -m -r todo-app && passwd -l todo-app
    chown midterm:midterm -R /midterm
}

configure_security () {
    setenforce 0
    sed -r -i 's/SELINUX=(enforcing|disabled)/SELINUX=permissive/' /etc/selinux/config
    firewall-cmd --zone=public --add-port=80/tcp
    firewall-cmd --runtime-to-permanent
}

configure_todoapp () {
    su - todo-app bash -c "
    mkdir app;
    git clone https://github.com/timoguic/ACIT4640-todo-app.git app;
    cd app;
    npm install;
    "
    /bin/cp -rf /home/admin/database.js /home/todo-app/app/config
    chown todo-app:todo-app -R /home/todo-app/app/config/database.js
    chmod -R 755 /home/todo-app/
}

configure_services () {
    /bin/cp -rf /home/admin/nginx.conf /etc/nginx/
    /bin/cp -rf /home/admin/todoapp.service /lib/systemd/system
    systemctl daemon-reload
    systemctl enable nginx && systemctl start nginx
    systemctl enable mongod && systemctl start mongod
    systemctl enable todoapp && systemctl start todoapp
}

configure_users
configure_security
configure_todoapp
configure_services