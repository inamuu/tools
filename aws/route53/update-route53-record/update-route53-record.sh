#!/bin/bash

ZONE_NAME='ここにドメイン名'
IMPORT_FILE='import.txt'
ROLLBACK_FILE='rollback.txt'

function usage {
    cat <<EOF
$(basename "${0}") is a tool for update route53 records.

Usage:
    $(basename "${0}") help
    $(basename "${0}") backup
    $(basename "${0}") upsert
    $(basename "${0}") rollback
EOF
}

function check_readline {
    /bin/echo -n "Do you want to continue? [y|N]: "
    read -r str
    case ${str} in
        [Yy]|[Yy][Ee][Ss])
        printf "=== Start command ===\n"
    ;;
    *)
        echo "Cancel command"
        exit 1
    ;;
esac
}

function backup {
    check_readline
    if [ -e "$(PWD)/files/backup_${ZONE_NAME}_$(date +%Y%m%d).zone" ];then
        mv "$(PWD)"/files/backup_${ZONE_NAME}_"$(date +%Y%m%d)".{zone,before.zone}
    fi
    cli53 export ${ZONE_NAME} | tee "$(PWD)"/files/backup_${ZONE_NAME}_"$(date +%Y%m%d)".zone
}

function upsert {
    check_readline
    cli53 import --upsert --file ${IMPORT_FILE} ${ZONE_NAME}
    cli53 export ${ZONE_NAME} | tee "$(PWD)"/files/backup_${ZONE_NAME}_"$(date +%Y%m%d)"_updated.zone
}

function rollback {
    check_readline
    cli53 import --upsert --file ${ROLLBACK_FILE} ${ZONE_NAME}
    cli53 export ${ZONE_NAME} | tee "$(PWD)"/files/backup_${ZONE_NAME}_"$(date +%Y%m%d)"_updated.zone
}

case ${1} in
    help|--help|-h) usage;;
    backup) backup ;;
    upsert) upsert ;;
    rollback) rollback ;;
    *)
        echo "[ERROR] Invalid subcommand '${1}'"
        usage
        exit 1
    ;;
esac
