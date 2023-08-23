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

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
VALIDATE $? "Installing redis rpm file"

yum module enable redis:remi-6.2 -y &>> $LOGFILE
VALIDATE $? "Enabling the 6.2 version of redis"

yum install redis -y &>> $LOGFILE
VALIDATE $? "Installing REDIS"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf &>> $LOGFILE
VALIDATE $? "Updating listen address"

systemctl enable redis &>> $LOGFILE
VALIDATE $? "Enabling redis"

systemctl start redis &>> $LOGFILE
VALIDATE $? "Starting redis"