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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE
VALIDATE $? "Downloading NodeJS Repo"

yum install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing NodeJs"

USER=$(getent passwd | grep roboshop)
echo $USER &>> $LOGFILE

if [ $? -ne 0 ]; then
useradd roboshop
VALIDATE $? "Adding user"
else
echo -e "$Y user already exist $N"
fi

DIRECTORY=$(cd /app)
echo $DIRECTORY 
if [ $? -ne 0 ] ; then
mkdir /app 
VALIDATE $? "Creating directory"
else
echo -e "$Y File already exist $N"
fi

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "Downloading cart Artifact"

cd /app &>> $LOGFILE
VALIDATE $? "Getting into app directory"

unzip /tmp/cart.zip 
VALIDATE $? "Extracting cart Artifact"

npm install &>> $LOGFILE
VALIDATE $? "Downloading dependencies"

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "Creating & copying System cart service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon-reload"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "Enabling cart"

systemctl start cart &>> $LOGFILE
VALIDATE $? "Starting cart"

