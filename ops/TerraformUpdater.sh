#!/bin/bash

set -e

LATEST_VERSION=$(curl -s https://releases.hashicorp.com/terraform/ | grep terraform_ | egrep -v "rc|alpha|beta|oci" | head -1 | sed -e "s/<a .*\/\">//g" -e "s/<\/a>//g" -e "s/ //g" -e "s/terraform_//g")
CHECK_KERNEL=$(uname -s)

case ${CHECK_KERNEL} in
  Darwin)
    DLURL=https://releases.hashicorp.com/terraform/${LATEST_VERSION}/terraform_${LATEST_VERSION}_darwin_amd64.zip
    TERRAFORM_SRC="/usr/local/Cellar/terraform/terraform_${LATEST_VERSION}"
    ;;
  Linux)
    DLURL=https://releases.hashicorp.com/terraform/${LATEST_VERSION}/terraform_${LATEST_VERSION}_linux_amd64.zip
    TERRAFORM_SRC="/usr/local/bin/terraform_${LATEST_VERSION}"
    ;;
  *) exit;;
esac

if [ -z ${LATEST_VERSION} ];then exit;fi
if [ -f "${TERRAFORM_SRC}" ];then echo "Already installed terraform ${LATEST_VERSION}" && exit;fi

TMPFILE="/tmp/terraform_${LATEST_VERSION}"
wget ${DLURL} -O ${TMPFILE} && unzip ${TMPFILE}
mv terraform ${TERRAFORM_SRC}

TERRAFORM_PATH="/usr/local/bin/terraform"
if [ -f "${TERRAFORM_PATH}" ];then
  if [ -L "${TERRAFORM_PATH}" ];then
    unlink ${TERRAFORM_PATH}
    ln -s ${TERRAFORM_SRC} ${TERRAFORM_PATH}
  fi
else
    ln -s ${TERRAFORM_SRC} ${TERRAFORM_PATH}
fi

chmod u+x ${TERRAFORM_PATH}
terraform version
