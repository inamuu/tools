#!/bin/bash

LOGDIR=$(pwd)/mysqladmin_logs
LOGFILE=${LOGDIR}/$(date +%Y%m%d).log
DBHOST=$(grep host dbaccess.cnf | tail -1 | sed 's/host \= //')

[ ! -d ${LOGDIR} ] && mkdir -p ${LOGDIR}
[ ! -f "$(pwd)/dbaccess.cnf" ] && echo "dbacces.cnf does not exist" && exit 1

exec >> "${LOGFILE}"
exec 2>&1

while true ; do
    LANG=c date '+%Y/%m/%d %H:%M:%S'
    mysqladmin --defaults-extra-file=dbaccess.cnf ping
    dig ${DBHOST} +short
    echo ''
    sleep 2
done

