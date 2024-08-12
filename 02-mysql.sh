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
        echo -e "$2... $R FAILURE$N"
    else
        echo -e "$2... $G SUCCESS$N"
    fi
}

if [$USERID -ne 0 ]
then
    echo "Please run this command with root access"
else
    echo "you are super user"
fi


dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing MySQL server"

systemctl start mysqld -y &>>$LOGFILE
VALIDATE $? "Start MySQL server"

systemctl enable mysqld -y &>>$LOGFILE
VALIDATE $? "Enable MySQL Server"

mysql -h db.hasamahas.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE

if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "MySQL root Password is setup... $G SUCCESS$N"
else
    echo -e "MySQL root password is already setup...$Y SKIPPING$N"
fi