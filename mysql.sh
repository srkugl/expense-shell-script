#!/bin/bash

source ./common.sh

check_root
update_packages


dnf install mysql-server -y >> $LOGFILE 2>&1
VALIDATE $? "Installing MySQL server"

systemctl enable mysqld >> $LOGFILE 2>&1
VALIDATE $? "Enabling MySQL service"

systemctl start mysqld >> $LOGFILE 2>&1
VALIDATE $? "Starting MySQL service"

mysql_secure_installation --set-root-pass ExpenseApp@1 >> $LOGFILE 2>&1
VALIDATE $? "Securing MySQL installation"

echo -e "$G All tasks completed successfully! $N"