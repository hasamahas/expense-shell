#!/bin/bash

USERID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
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
dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing MySQL server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "start  MySQL server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling MySQL server"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#VALIDATE $? "Setting up root password"
 mysql -h db.hasamahas.online -uroot -pExpenseApp@1 -e 'show databases;' &>>$LOGFILE

 if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
    VALIDATE $? "Mysql root password setup"
else
    echo -e "Mysql root password is already setup... $Y SKIPPING $N "

fi







