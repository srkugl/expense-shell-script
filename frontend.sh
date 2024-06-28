#!/bin/bash

source ./common.sh

check_root
update_packages

dnf install nginx -y >> $LOGFILE 2>&1
VALIDATE $? "Installing Nginx"

systemctl enable nginx >> $LOGFILE 2>&1
VALIDATE $? "Enabling Nginx"

systemctl start nginx >> $LOGFILE 2>&1
VALIDATE $? "Starting Nginx"

curl -I http://localhost | grep "200 OK" >> $LOGFILE 2>&1
VALIDATE $? "Checking Nginx default content"

rm -rf /usr/share/nginx/html/* >> $LOGFILE 2>&1
VALIDATE $? "Removing default Nginx content"

git clone https://github.com/srkugl/expense-frontend.git /usr/share/nginx/html >> "$LOGFILE" 2>&1
VALIDATE $? "Cloning frontend code from GitHub to Nginx directory"

curl -I http://localhost | grep "200 OK" >> "$LOGFILE" 2>&1
VALIDATE $? "Checking Nginx frontend content"

cat <<EOF > /etc/nginx/default.d/expense.conf
proxy_http_version 1.1;

location /api/ { proxy_pass http://expense.backend.test.ullagallu.cloud:8080/; }

location /health {
  stub_status on;
  access_log off;
}
EOF
VALIDATE $? "Creating Nginx reverse proxy configuration"

systemctl restart nginx >> "$LOGFILE" 2>&1
VALIDATE $? "Restarting Nginx"

echo -e "$G All tasks completed successfully! $N"





