#!/bin/bash
LOGFILE_DIR=/tmp
DATE=$(date +%F)
SCRIPT_NAME=$0
LOGFILE=$LOGFILE_DIR/$SCRIPT_NAME-$DATE.log
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2.....$R FAILURE $N"
        exit 1
    else
        echo -e "$2.....$G SUCCESS $N"
    fi
 }

 USERID=$(id -u)
 if [ $USERID -ne 0 ]; then
    echo -e "$R ERROR:Please run this script with root access $N"
    exit 1
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Creating & copying MongoDB repo file"

yum install mongodb-org -y &>> $LOGFILE
VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "Enabling MongoDB"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Updating listen address"

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarting MongoDB"
