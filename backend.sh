#!/bin/bash

source ./common.sh

check_root
update_packages

dnf module disable nodejs -y >> $LOGFILE 2>&1
VALIDATE $? "Disabling default NodeJS module"

dnf module enable nodejs:20 -y >> $LOGFILE 2>&1
VALIDATE $? "Enabling NodeJS 20 module"

dnf install nodejs -y >> $LOGFILE 2>&1
VALIDATE $? "Installing NodeJS 20"

useradd expense >> $LOGFILE 2>&1
VALIDATE $? "Adding user 'expense'"

mkdir /app >> $LOGFILE 2>&1
VALIDATE $? "Creating /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip >> $LOGFILE 2>&1
VALIDATE $? "Downloading backend code"

cd /app >> $LOGFILE 2>&1
unzip /tmp/backend.zip >> $LOGFILE 2>&1
VALIDATE $? "Unzipping backend code"

npm install >> $LOGFILE 2>&1
VALIDATE $? "Installing application dependencies"

cat <<EOF > /etc/systemd/system/backend.service
[Unit]
Description=Backend Service

[Service]
User=expense
Environment=DB_HOST="expense.db.test.ullagallu.cloud"
ExecStart=/bin/node /app/index.js
SyslogIdentifier=backend

[Install]
WantedBy=multi-user.target
EOF
VALIDATE $? "Creating backend service file"

dnf install mysql -y >> $LOGFILE 2>&1
VALIDATE $? "Installing MySQL client"

mysql -h expense.db.test.ullagallu.cloud -uroot -pExpenseApp@1 < /app/schema/backend.sql >> $LOGFILE 2>&1
VALIDATE $? "Loading database schema"

systemctl daemon-reload >> $LOGFILE 2>&1
VALIDATE $? "Reloading systemd daemon"

systemctl start backend >> $LOGFILE 2>&1
VALIDATE $? "Starting backend service"

systemctl enable backend >> $LOGFILE 2>&1
VALIDATE $? "Enabling backend service"

echo -e "$G All tasks completed successfully! $N"
