#!/bin/bash

USERID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Enter MySQL db password:"
read -s mysql_root_password

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

dnf module disable nodejs:18 -y &>>$LOGFILE
VALIDATE $? "Disable Nodejs:18"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enable nodejs:20"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing Nodejs"

id expense &>>$LOGFILE

if [ $? -ne 0 ]
then
    useradd expense
else
    echo -e "User id expense already exists... $Y SKIPPING$N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating app Directory" 

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downlod backendzip file"
cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Unzip backend file"

cd /app

npm install &>>$LOGFILE
VALIDATE $? "Installing depenent libraries"

cp D:\DevOps\April2024_Siva\repos\expense-shell\backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Creating backend.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon reload"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Start backend service"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enable Backend Service"

mysql -h db.hasamahas.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Loading the Schema"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restart backend server"







