#!/bin/bash

set -eux

PASSWORD=XXXX
DBHOST=XXXX
BACKUPDIR="/XXXX"

test ! -d ${BACKUPDIR} \
&& mkdir -p ${BACKUPDIR} \
&& echo "Created Backupdir: ${BACKUPDIR}"

if [ $# -eq 1 ]; then
  mysqldump -u root -p${PASSWORD} -h ${DBHOST} -B $1 | /bin/gzip > /mnt/backup/database/$1.$(date +%w).sql.gz
else
  echo "Pleaes type an argument that backup db name"
  exit 1
fi

