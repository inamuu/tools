#!/bin/bash

####################################
# DB パラメーター確認スクリプト
####################################

TARGET_LIST=$(dirname ${0})/mysql_list.txt
if [ ! -e "${TARGET_LIST}" ];then 
  echo "mysql_list.txtを作成してください"
  exit 10
fi 

read -p "Enter DB User: " DBUSER
read -sp "Enter DB Password: " DBPASS
tty -s && echo
read -p "Enter DB Port(3306): " DBPORT
read -p "Enter DB Host(127.0.0.1): " DBHOST

echo "\nDBと疎通チェックします\n---"
sleep 1

CHECK_CONNECT=$(MYSQL_PWD=${DBPASS} mysqladmin ping -h ${DBHOST:-127.0.0.1} -u ${DBUSER} -P ${DBPORT:-3306})

if [ "${CHECK_CONNECT}" != "mysqld is alive" ];then
  exit 20
else
  echo "${CHECK_CONNECT}\n"
fi

LOGFILE=$(dirname ${0})/${DBHOST:-127.0.0.1}-${DBPORT:-3306}.log

echo "DBのパラメーターをチェックします\n---"
sleep 1

for i in $(cat ${TARGET_LIST});do
  RES=$(MYSQL_PWD=${DBPASS} mysql -h ${DBHOST:-127.0.0.1} -u ${DBUSER} -P ${DBPORT:-3306} -N -e "show global variables like \"$i\"")
  echo ${RES}
done | tee ${LOGFILE}

echo "\ndone!"

