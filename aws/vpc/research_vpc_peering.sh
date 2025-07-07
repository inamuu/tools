#!/bin/bash

AWS_PROFILE_LIST=$(cat ~/.aws/config | egrep "profile" | sed -E 's/(\[|\]|profile )//g')

for i in $(echo ${AWS_PROFILE_LIST});do
  printf "\nAWS Account: $i\n"
  aws ec2 describe-vpc-peering-connections --query "VpcPeeringConnections[*].{PeeringConnectionId:VpcPeeringConnectionId,Requester:RequesterVpcInfo.VpcId,Accepter:AccepterVpcInfo.VpcId,Status:Status.Code}" --output table --no-cli-pager --profile $i
  aws ec2 describe-vpcs --query "Vpcs[*].{VpcId:VpcId,Name:Tags[?Key=='Name'].Value|[0]}" --output table --no-cli-pager --profile $i
done
