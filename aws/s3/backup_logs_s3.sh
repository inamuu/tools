#!/bin/bash

BACKUP_PATH="/var/www/app/logs/"
S3_PATH="s3://exmaple-backup/logs/"

aws s3 sync $BACKUP_PATH $S3_PATH --delete

