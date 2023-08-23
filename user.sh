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
useradd roboshop &>> $LOGFILE
VALIDATE $? "Adding user"
else
echo -e "$Y user already exist $N"
fi

DIRECTORY=$(cd /app)
echo $DIRECTORY &>> $LOGFILE
if [ $? -ne 0 ]; then
mkdir /app &>> $LOGFILE
VALIDATE $? "Creating directory"
else
echo -e "$Y File already exist $N"
fi

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "Downloading user app code into tmp directory"

cd /app &>> $LOGFILE
VALIDATE $? "Getting into app directory"

unzip /tmp/user.zip
VALIDATE $? "Extracting catalogue.zip in app directory"

npm install &>> $LOGFILE
VALIDATE $? "Downloading dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "Creating & copying System user service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Loading the service"

systemctl enable user &>> $LOGFILE
VALIDATE $? "Enabling user"

systemctl start user &>> $LOGFILE
VALIDATE $? "Starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Creating MongoDB repo to install MongoDB client"

yum install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Installing MongoDB client to load schema/catalogue products"

mongo --host mongodb.devidevops.online </app/schema/user.js &>> $LOGFILE
VALIDATE $? "Loading schema"

