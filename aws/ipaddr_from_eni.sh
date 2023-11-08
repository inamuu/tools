#!/bin/bash

IPLIST="/tmp/iplist.txt"
ENILIST="/tmp/enilist.txt"

create_ip_list() {
    FILECHECK=$(find $(PWD) -type f -name "*.csv")
    if [ -f "${FILECHECK}" ];then
        cat ${FILECHECK} | awk -F',' '{print $1}' | egrep '[0-9].*' > ${IPLIST}
    else
        printf "CSVファイルが見つかりません"
        exit 1
    fi
}

get_eni_list() {
    saml2aws login
    aws ec2 describe-network-interfaces --query "NetworkInterfaces[]" --output json > ${ENILIST}
}

check_eni_info() {
    cat ${ENILIST} | jq -c ".[] | select(.PrivateIpAddress == \"${1}\") | { \"PrivateIpAddress\": .PrivateIpAddress, \"NetworkInterfaceId\": .NetworkInterfaceId, \"Groups\":.Groups[], \"InstanceId\": .Attachment.InstanceId, \"Description\":.Description }"
}

instance_check(){
    INSTANCEID=$(echo $@ | jq ".InstanceId" | sed 's/\"//g')
    if [ -n "${INSTANCEID}" ];then
        aws ec2 describe-instances --instance-ids ${INSTANCEID} | jq -c "[.Reservations[].Instances[].Tags[] | {(.Key): .Value}] | add"
    fi
}

check_ip_list() {
    for i in $(cat ${IPLIST});
    do
        CHECKIP=$(grep "\"$i\"" ${ENILIST})
        if [ -n "${CHECKIP}" ];then
            printf "\n### $i\n"
            RES=$(check_eni_info $i)
            echo ${RES} | jq -c
            instance_check ${RES}
        else
            printf "\n### $i\n見つかりませんでした\n"
        fi
    done
}

main() {
    create_ip_list
    get_eni_list
    check_ip_list
}

main

